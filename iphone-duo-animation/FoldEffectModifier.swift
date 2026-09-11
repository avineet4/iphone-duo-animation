//
//  FoldEffectModifier.swift
//  iphone-duo-animation
//
//  Created by Avineet Singh on 11/9/26.
//

import SwiftUI

// MARK: - Modifier

private struct FoldEffectModifier: ViewModifier {
    let angle: Double
    let parameters: FoldParameters

    func body(content: Content) -> some View {
        content
            .compositingGroup()
            .visualEffect { [angle, parameters] content, _ in
                content.layerEffect(
                    ShaderLibrary.duoFold(
                        .boundingRect,
                        .float(angle),
                        .float(parameters.eyeDistancePoints),
                        .float(parameters.blurSpread),
                        .float(parameters.dimRate)
                    ),
                    maxSampleOffset: .zero,
                    isEnabled: abs(angle) > 1e-4
                )
            }
    }
}


// MARK: - View extension

extension View {
    func foldEffect(
        angle: Double,
        parameters: FoldParameters = FoldParameters()
    ) -> some View {
        modifier(FoldEffectModifier(angle: angle, parameters: parameters))
    }
}
