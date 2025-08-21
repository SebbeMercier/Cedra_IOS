import SwiftUI

struct Navbar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var cartManager: CartManager   // ✅ nom clair

    var body: some View {
        HStack {
            Spacer()
            navButton(icon: "house.fill", label: "Accueil", tab: 0)
            Spacer()
            navButton(icon: "cart.fill", label: "Panier", tab: 2, badge: cartManager.totalItems())
            Spacer();
            navButton(icon: "person.fill", label: "Profil", tab: 3);
            Spacer()
        }
        .padding(.top, 35)
        .padding(.bottom, 5)
        .background(Color(.systemGray6))
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.gray),
            alignment: .top
        )
    }

    private func navButton(icon: String, label: String, tab: Int, badge: Int = 0) -> some View {
        let isActive = selectedTab == tab

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                selectedTab = tab
            }
        } label: {
            VStack {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isActive ? .red : .black)
                        .scaleEffect(isActive ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isActive)

                    if badge > 0 {
                        Text("\(badge)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 12, y: -10)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: badge)
                    }
                }

                Text(label)
                    .font(.caption)
                    .foregroundColor(isActive ? .red : .black)
                    .animation(.easeInOut(duration: 0.2), value: isActive)
            }
            .offset(y: -30)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
    }
}

// pour les boutons header de home

struct NavTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
