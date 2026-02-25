import SwiftUI

struct SocialLoginButton: View {
    let provider: SocialProvider
    let action: () -> Void

    enum SocialProvider {
        case apple
        case google

        var label: String {
            switch self {
            case .apple: "Continue with Apple"
            case .google: "Continue with Google"
            }
        }

        var icon: String {
            switch self {
            case .apple: "apple.logo"
            case .google: "globe"
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: provider.icon)
                    .font(.title3)
                Text(provider.label)
                    .font(Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.glass)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        SocialLoginButton(provider: .apple) { }
        SocialLoginButton(provider: .google) { }
    }
    .padding()
    .sereneBloomBackground()
}
#endif
