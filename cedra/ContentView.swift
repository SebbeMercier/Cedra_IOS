//
//  ContentView.swift
//  cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//


import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0   // ✅ 0 = Accueil, 2 = Panier, 3 = Profil
    @State private var showLogo = true
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // Contenu principal avec crossfade quand selectedTab change
                ZStack {
                    switch selectedTab {
                    case 0:
                        home(selectedTab: $selectedTab) 
                    case 2:
                        CartView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                    case 3:
                        MyAccount()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                    default:
                        home(selectedTab: $selectedTab)
                    }
                }
                .id(selectedTab)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)

                Navbar(selectedTab: $selectedTab)        // ✅ même type partout
            }
            .edgesIgnoringSafeArea(.bottom)

            if showLogo {
                Color.white.ignoresSafeArea()
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) { scale = 1.2 }
                        withAnimation(.easeIn(duration: 0.5).delay(0.8)) { opacity = 0.0 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                            showLogo = false
                        }
                    }
            }
        }
        .preferredColorScheme(.light)
    }
}


#Preview {
    ContentView()
}
