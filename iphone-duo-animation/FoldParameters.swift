//
//  FoldParameters.swift
//  iphone-duo-animation
//
//  Created by Avineet Singh on 11/9/26.
//

import SwiftUI

nonisolated struct FoldParameters: Equatable {
    var eyeDistanceMM: CGFloat = 320
    var pointsPerMM: CGFloat = 6
    var blurSpread: CGFloat = 0.12
    var dimRate: CGFloat = 0.015
    var eyeDistancePoints: CGFloat { eyeDistanceMM * pointsPerMM }
}
