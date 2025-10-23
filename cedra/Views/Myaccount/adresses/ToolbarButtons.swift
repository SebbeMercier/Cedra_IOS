//
//  ToolbarButtons.swift
//  cedra
//
//  Created by Sebbe Mercier on 11/10/2025.
//

import SwiftUI

struct ToolbarButtons: ToolbarContent {
    let hasCompany: Bool
    @Binding var selectedAddressId: String?
    let onAdd: () -> Void
    let onContinue: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Ajouter", action: onAdd)
        }
        ToolbarItem(placement: .bottomBar) {
            Button("Continuer", action: onContinue)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(selectedAddressId == nil)
        }
    }
}
