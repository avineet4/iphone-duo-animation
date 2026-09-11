//
//  FoldMotionModel.swift
//  iphone-duo-animation
//
//  Created by Avineet Singh on 11/9/26.
//

import CoreMotion
import Observation
import simd

@Observable
@MainActor
final class FoldMotionModel {

    // MARK: - Public State

    var tiltAngle: Double {
        liveTilt
    }

    private(set) var isMotionAvailable: Bool
    private(set) var liveTilt: Double = 0

    var screenX = SIMD3<Double>(1, 0, 0)
    var screenY = SIMD3<Double>(0, 1, 0)

    // MARK: - Motion

    @ObservationIgnored
    private let manager = CMMotionManager()

    @ObservationIgnored
    private var zeroRef: simd_double3x3?

    @ObservationIgnored
    private var rowsFirst: Bool?

    @ObservationIgnored
    private let smoothing = 0.72

    @ObservationIgnored
    private let lookAhead = 0.040

    // MARK: - Initialization

    init() {
        isMotionAvailable = manager.isDeviceMotionAvailable
    }

    // MARK: - Control

    func start() {
        guard isMotionAvailable,
              !manager.isDeviceMotionActive
        else {
            return
        }

        manager.deviceMotionUpdateInterval = 1.0 / 120.0

        manager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: .main
        ) { [weak self] motion, _ in

            guard let motion else {
                return
            }

            MainActor.assumeIsolated {
                self?.handleMotion(motion)
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }

    func recalibrate() {
        zeroRef = nil
        liveTilt = 0
    }

    // MARK: - Screen Axes

    func setScreenAxes(
        x: SIMD3<Double>,
        y: SIMD3<Double>
    ) {
        screenX = x
        screenY = y
    }

    // MARK: - Motion Processing

    private func handleMotion(_ motion: CMDeviceMotion) {
        let deviceToWorld = resolvedMatrix(motion)

        guard let ref = zeroRef else {
            zeroRef = deviceToWorld
            return
        }

        let delta = ref.transpose * deviceToWorld

        let normal = delta.columns.2

        let measured = atan2(
            simd_dot(normal, screenX),
            normal.z
        )

        let rotationRate = SIMD3<Double>(
            motion.rotationRate.x,
            motion.rotationRate.y,
            motion.rotationRate.z
        )

        let predicted = measured + simd_dot(rotationRate, screenY) * lookAhead

        liveTilt += (predicted - liveTilt) * smoothing
    }

    // MARK: - Rotation Matrix

    private func resolvedMatrix(
        _ motion: CMDeviceMotion
    ) -> simd_double3x3 {

        let m = motion.attitude.rotationMatrix

        let asRows = simd_double3x3(rows: [
            SIMD3(m.m11, m.m12, m.m13),
            SIMD3(m.m21, m.m22, m.m23),
            SIMD3(m.m31, m.m32, m.m33)
        ])

        if rowsFirst == nil {
            let gravity = simd_normalize(
                SIMD3(
                    motion.gravity.x,
                    motion.gravity.y,
                    motion.gravity.z
                )
            )

            let down = SIMD3<Double>(0, 0, -1)

            let rowScore = simd_dot(gravity, asRows * down)

            let columnScore = simd_dot(gravity, asRows.transpose * down)

            if abs(rowScore - columnScore) > 0.2 {
                rowsFirst = rowScore > columnScore
            }
        }

        return (rowsFirst ?? true) ? asRows.transpose : asRows
    }
}
