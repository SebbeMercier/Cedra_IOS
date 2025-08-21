//
//  home.swift
//  cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import SwiftUI
import UIKit

struct home: View {            // <- tu peux garder `home` si tu veux
    @Binding var selectedTab: Int
    @State private var isSearching = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)

                Spacer()

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        selectedTab = 2        // Panier
                    }
                } label: {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                .buttonStyle(NavTapButtonStyle())
                .padding(.trailing, 20)

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        selectedTab = 3        // Profil
                    }
                } label: {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                .buttonStyle(NavTapButtonStyle())
                .padding(.trailing, 15)
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.white)

            // Barre de recherche
            ZStack {
                Color.red
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    Text("Rechercher un produit...").foregroundColor(.gray)
                    Spacer()
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .onTapGesture { isSearching = true }
            }
            .frame(height: 50)

            // Contenu
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    productSection(title: "Promotions")
                    productSection(title: "Nouveautés")
                    productSection(title: "Meilleures ventes")
                }
            }
            .background(Color(.systemGray6))
        }
        .fullScreenCover(isPresented: $isSearching) {
            SearchView().preferredColorScheme(.light)
        }
    }

    @ViewBuilder
    func productSection(title: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
                .padding(.top, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(1..<6) { i in
                        VStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 120, height: 120)
                                .overlay(Text("Image \(i)").foregroundColor(.gray))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)

                            Text("Produit \(i)").font(.subheadline).foregroundColor(.black)
                            Text("\(i * 10) €").foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }
}
