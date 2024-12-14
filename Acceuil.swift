import SwiftUI
import UIKit

struct Accueil: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                VStack {
                  
                    NavigationLink(destination: DrawingView()) {
                        Text("WhiteBoard")
                            .font(.custom("AnimeAce2.0BB-Bold", size: 20))
                            .foregroundColor(.purple)
                            .fontWeight(.bold)
                            .padding(10)
                            .background(
                                BlurBackground()
                            )
                    }
                    .padding(10)
                }
                Spacer()
            }
                }
            Image("background")
                .resizable()
                .scaledToFill()
            }
        }
    }

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
    }
}

struct BlurBackground: View {
  
    var body: some View {
        BlurView()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
            .cornerRadius(10)
            .shadow(color: .gray, radius: 5, x: 0, y: 2)
    }
}

struct StyledButton: View {
    let systemImage: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()  // Action du bouton
        }) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.pink, .purple]),
                        startPoint: .leading,
                        endPoint: .top
                    )
                )
                .padding(10)
                .background(
                    BlurBackground()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isPressed ? Color.white : Color.clear, lineWidth: 8)
                )
        }
    }
}
