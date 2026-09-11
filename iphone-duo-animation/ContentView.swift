//
//  ContentView.swift
//  iphone-duo-animation
//
//  Created by Avineet Singh on 11/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var motion = FoldMotionModel()

    var body: some View {
        GeometryReader { geo in
            let insets = geo.safeAreaInsets
            let fullWidth  = geo.size.width  + insets.leading + insets.trailing
            let fullHeight = geo.size.height + insets.top     + insets.bottom

            Image("Duo_iPhone")
                .resizable()
                .scaledToFill()
                .frame(width: fullWidth, height: fullHeight)
                .clipped()
                .foldEffect(angle: motion.tiltAngle)
                .ignoresSafeArea()
        }
        .onAppear  { motion.start() }
        .onDisappear { motion.stop() }
    }
}

#Preview {
    ContentView()
}
