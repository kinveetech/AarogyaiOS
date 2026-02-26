import Testing
import Foundation
@testable import AarogyaiOS

@Suite("ErrorResponse")
struct ErrorResponseTests {
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    @Test func decodesCodeField() throws {
        let json = #"{"code":"registration_required","message":"Please register."}"#
        let response = try decoder.decode(ErrorResponse.self, from: Data(json.utf8))
        #expect(response.code == "registration_required")
        #expect(response.error == nil)
        #expect(response.errorCode == "registration_required")
    }

    @Test func decodesErrorField() throws {
        let json = #"{"error":"registration_required","message":"User registration is required."}"#
        let response = try decoder.decode(ErrorResponse.self, from: Data(json.utf8))
        #expect(response.code == nil)
        #expect(response.error == "registration_required")
        #expect(response.errorCode == "registration_required")
    }

    @Test func errorCodePrefersCodeOverError() throws {
        let json = #"{"code":"from_code","error":"from_error","message":"Both present."}"#
        let response = try decoder.decode(ErrorResponse.self, from: Data(json.utf8))
        #expect(response.errorCode == "from_code")
    }

    @Test func errorCodeIsNilWhenBothAbsent() throws {
        let json = #"{"message":"No code or error."}"#
        let response = try decoder.decode(ErrorResponse.self, from: Data(json.utf8))
        #expect(response.errorCode == nil)
    }

    @Test func decodesFieldErrors() throws {
        let json = #"{"message":"Validation failed.","errors":[{"field":"email","message":"Invalid email"}]}"#
        let response = try decoder.decode(ErrorResponse.self, from: Data(json.utf8))
        #expect(response.errors?.count == 1)
        #expect(response.errors?.first?.field == "email")
        #expect(response.errors?.first?.message == "Invalid email")
    }

    @Test func decodesEmptyBody() throws {
        let json = #"{}"#
        let response = try decoder.decode(ErrorResponse.self, from: Data(json.utf8))
        #expect(response.code == nil)
        #expect(response.error == nil)
        #expect(response.message == nil)
        #expect(response.errors == nil)
        #expect(response.errorCode == nil)
    }
}
