import Testing
import Foundation
@testable import AarogyaiOS

@Suite("AccessGrantMapper")
struct AccessGrantMapperTests {

    @Test func toDomainMapsAllFields() {
        let dto = AccessGrantResponse(
            id: "grant-abc",
            patientId: "patient-1",
            grantedToUserId: "doctor-1",
            grantedToUserName: "Dr. Smith",
            grantedByUserId: "patient-1",
            grantedByUserName: "Jane Doe",
            grantReason: "Follow-up consultation",
            allReports: true,
            reportIds: nil,
            status: "active",
            startsAt: "2026-01-01T00:00:00.000Z",
            expiresAt: "2026-03-01T00:00:00.000Z",
            revokedAt: nil,
            createdAt: "2026-01-01T00:00:00.000Z"
        )

        let grant = AccessGrantMapper.toDomain(dto)

        #expect(grant.id == "grant-abc")
        #expect(grant.patientId == "patient-1")
        #expect(grant.grantedToUserId == "doctor-1")
        #expect(grant.grantedToUserName == "Dr. Smith")
        #expect(grant.grantedByUserId == "patient-1")
        #expect(grant.grantedByUserName == "Jane Doe")
        #expect(grant.grantReason == "Follow-up consultation")
        #expect(grant.scope.allReports)
        #expect(grant.scope.reportIds.isEmpty)
        #expect(grant.status == .active)
        #expect(grant.expiresAt != nil)
        #expect(grant.revokedAt == nil)
    }

    @Test func toDomainMapsNilGrantedByUserName() {
        let dto = AccessGrantResponse(
            id: "grant-1",
            patientId: "patient-1",
            grantedToUserId: "doctor-1",
            grantedToUserName: "Dr. Smith",
            grantedByUserId: "patient-1",
            grantedByUserName: nil,
            grantReason: nil,
            allReports: false,
            reportIds: ["report-1", "report-2"],
            status: "active",
            startsAt: "2026-01-01T00:00:00.000Z",
            expiresAt: nil,
            revokedAt: nil,
            createdAt: "2026-01-01T00:00:00.000Z"
        )

        let grant = AccessGrantMapper.toDomain(dto)

        #expect(grant.grantedByUserName == nil)
        #expect(!grant.scope.allReports)
        #expect(grant.scope.reportIds.count == 2)
        #expect(grant.expiresAt == nil)
    }

    @Test func toDomainMapsNilGrantedToUserName() {
        let dto = AccessGrantResponse(
            id: "grant-1",
            patientId: "patient-1",
            grantedToUserId: "doctor-1",
            grantedToUserName: nil,
            grantedByUserId: "patient-1",
            grantedByUserName: "Jane Doe",
            grantReason: nil,
            allReports: true,
            reportIds: nil,
            status: "active",
            startsAt: "2026-01-01T00:00:00.000Z",
            expiresAt: nil,
            revokedAt: nil,
            createdAt: "2026-01-01T00:00:00.000Z"
        )

        let grant = AccessGrantMapper.toDomain(dto)

        #expect(grant.grantedToUserName == nil)
        #expect(grant.grantedByUserName == "Jane Doe")
    }

    @Test func toDomainMapsRevokedStatus() {
        let dto = AccessGrantResponse(
            id: "grant-1",
            patientId: "patient-1",
            grantedToUserId: "doctor-1",
            grantedToUserName: "Dr. Smith",
            grantedByUserId: "patient-1",
            grantedByUserName: nil,
            grantReason: nil,
            allReports: true,
            reportIds: nil,
            status: "revoked",
            startsAt: "2026-01-01T00:00:00.000Z",
            expiresAt: "2026-02-01T00:00:00.000Z",
            revokedAt: "2026-01-15T00:00:00.000Z",
            createdAt: "2026-01-01T00:00:00.000Z"
        )

        let grant = AccessGrantMapper.toDomain(dto)

        #expect(grant.status == .revoked)
        #expect(grant.revokedAt != nil)
    }

    @Test func toDomainMapsExpiredStatus() {
        let dto = AccessGrantResponse(
            id: "grant-1",
            patientId: "patient-1",
            grantedToUserId: "doctor-1",
            grantedToUserName: nil,
            grantedByUserId: "patient-1",
            grantedByUserName: nil,
            grantReason: nil,
            allReports: true,
            reportIds: nil,
            status: "expired",
            startsAt: "2025-01-01T00:00:00.000Z",
            expiresAt: "2025-02-01T00:00:00.000Z",
            revokedAt: nil,
            createdAt: "2025-01-01T00:00:00.000Z"
        )

        let grant = AccessGrantMapper.toDomain(dto)

        #expect(grant.status == .expired)
    }

    @Test func toDomainDefaultsUnknownStatusToActive() {
        let dto = AccessGrantResponse(
            id: "grant-1",
            patientId: "patient-1",
            grantedToUserId: "doctor-1",
            grantedToUserName: nil,
            grantedByUserId: "patient-1",
            grantedByUserName: nil,
            grantReason: nil,
            allReports: true,
            reportIds: nil,
            status: "unknown_status",
            startsAt: "2026-01-01T00:00:00.000Z",
            expiresAt: nil,
            revokedAt: nil,
            createdAt: "2026-01-01T00:00:00.000Z"
        )

        let grant = AccessGrantMapper.toDomain(dto)

        #expect(grant.status == .active)
    }

    @Test func toDomainMapsNilReportIdsToEmptyArray() {
        let dto = AccessGrantResponse(
            id: "grant-1",
            patientId: "patient-1",
            grantedToUserId: "doctor-1",
            grantedToUserName: nil,
            grantedByUserId: "patient-1",
            grantedByUserName: nil,
            grantReason: nil,
            allReports: false,
            reportIds: nil,
            status: "active",
            startsAt: "2026-01-01T00:00:00.000Z",
            expiresAt: nil,
            revokedAt: nil,
            createdAt: "2026-01-01T00:00:00.000Z"
        )

        let grant = AccessGrantMapper.toDomain(dto)

        #expect(grant.scope.reportIds.isEmpty)
    }
}
