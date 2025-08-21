//
//  SplashView.swift
//  cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var glow: Double = 0.0
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color.white.ignoresSafeArea()
                
                Image("logo") // ton logo dans Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .shadow(color: .red.opacity(glow), radius: 10)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) {
                            scale = 1.0
                        }
                        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            glow = 0.8
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeIn(duration: 0.5)) {
                                isActive = true
                            }
                        }
                    }
            }
        }
    }
}



#Preview {
    SplashView()
}
