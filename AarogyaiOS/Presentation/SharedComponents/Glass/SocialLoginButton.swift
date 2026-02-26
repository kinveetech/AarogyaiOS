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
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                providerIcon
                Text(provider.label)
                    .font(Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.glass)
    }

    @ViewBuilder
    private var providerIcon: some View {
        switch provider {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.title3)
        case .google:
            GoogleLogo(size: 20)
        }
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
