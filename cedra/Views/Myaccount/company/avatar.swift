//
//  avatar.swift
//  cedra
//
//  Created by Sebbe Mercier on 21/08/2025.
//

import SwiftUI

struct Avatar: View {
    let name: String
    var size: CGFloat = 44

    var body: some View {
        Text(initials(from: name))
            .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(backgroundColor(for: name))
            .clipShape(Circle())
            .accessibilityLabel(Text("Avatar \(name)"))
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .prefix(2)
        let initials = parts.compactMap { $0.first?.uppercased() }.joined()
        return initials.isEmpty ? "?" : initials
    }

    private func backgroundColor(for name: String) -> Color {
        let palette: [Color] = [
            .blue, .purple, .teal, .indigo,
            .orange, .pink, .mint, .cyan,
            .red, .green
        ]
        let h = abs(name.unicodeScalars.reduce(0, { ($0 << 5) &+ Int($1.value) &+ 17 }))
        return palette[h % palette.count].opacity(0.9)
    }
}
