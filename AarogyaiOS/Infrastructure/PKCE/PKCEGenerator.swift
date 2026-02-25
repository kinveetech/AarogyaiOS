import Foundation
import CryptoKit

enum PKCEGenerator {
    static func generateCodeVerifier(length: Int = 64) -> String {
        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        var verifier = ""
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<allowedCharacters.count)
            let character = allowedCharacters[allowedCharacters.index(allowedCharacters.startIndex, offsetBy: randomIndex)]
            verifier.append(character)
        }
        return verifier
    }

    static func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func generateState(length: Int = 32) -> String {
        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        var state = ""
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<allowedCharacters.count)
            let character = allowedCharacters[allowedCharacters.index(allowedCharacters.startIndex, offsetBy: randomIndex)]
            state.append(character)
        }
        return state
    }
}
