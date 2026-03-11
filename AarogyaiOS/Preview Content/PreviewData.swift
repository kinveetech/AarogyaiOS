import Foundation

#if DEBUG
enum PreviewData {
    static let user = User(
        id: "usr_preview_001",
        firstName: "Priya",
        lastName: "Sharma",
        email: "priya@example.com",
        phone: "+919876543210",
        address: "Mumbai, Maharashtra",
        bloodGroup: .oPositive,
        dateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15)),
        gender: .female,
        role: .patient,
        registrationStatus: .approved,
        isAadhaarVerified: true,
        aadhaarRefToken: nil,
        doctorProfile: nil,
        labTechProfile: nil,
        createdAt: .now.addingTimeInterval(-86400 * 30),
        updatedAt: .now
    )

    static let report = Report(
        id: "rpt_preview_001",
        reportNumber: "RPT-2025-001234",
        title: "Complete Blood Count",
        reportType: .bloodTest,
        status: .extracted,
        patientId: "usr_preview_001",
        doctorId: nil,
        doctorName: "Dr. Anil Gupta",
        labName: "PathKind Labs",
        collectedAt: .now.addingTimeInterval(-86400),
        reportedAt: .now.addingTimeInterval(-43200),
        uploadedAt: .now.addingTimeInterval(-3600),
        notes: nil,
        fileStorageKey: "reports/preview.pdf",
        fileType: "application/pdf",
        fileSizeBytes: 1_240_000,
        checksumSha256: nil,
        parameters: [
            ReportParameter(
                id: "param_001",
                code: "HGB",
                name: "Hemoglobin",
                numericValue: 14.2,
                textValue: nil,
                unit: "g/dL",
                referenceRange: "13.0-17.0",
                isAbnormal: false
            ),
            ReportParameter(
                id: "param_002",
                code: "WBC",
                name: "WBC Count",
                numericValue: 11500,
                textValue: nil,
                unit: "cells/μL",
                referenceRange: "4000-11000",
                isAbnormal: true
            )
        ],
        extraction: nil,
        highlightParameter: "WBC Count: 11500 cells/μL",
        createdAt: .now.addingTimeInterval(-3600),
        updatedAt: .now
    )

    static let accessGrant = AccessGrant(
        id: "ag_preview_001",
        patientId: "usr_preview_001",
        grantedToUserId: "usr_doctor_001",
        grantedToUserName: "Dr. Anil Gupta",
        grantedByUserId: "usr_preview_001",
        grantReason: "Follow-up consultation",
        scope: AccessScope(allReports: false, reportIds: ["rpt_preview_001"]),
        status: .active,
        startsAt: .now.addingTimeInterval(-86400),
        expiresAt: .now.addingTimeInterval(86400 * 7),
        revokedAt: nil,
        createdAt: .now.addingTimeInterval(-86400)
    )

    static let emergencyAccessGrant = EmergencyAccessGrant(
        grantId: "ea_preview_001",
        emergencyContactId: "ec_preview_001",
        startsAt: .now,
        expiresAt: .now.addingTimeInterval(86400),
        purpose: "Medical emergency - patient unresponsive"
    )

    static let emergencyContact = EmergencyContact(
        id: "ec_preview_001",
        name: "Rahul Sharma",
        phone: "+919876543211",
        relationship: .spouse,
        isPrimary: true,
        createdAt: .now.addingTimeInterval(-86400 * 60),
        updatedAt: .now
    )

    static let reports: [Report] = [
        report,
        Report(
            id: "rpt_preview_002",
            reportNumber: "RPT-2025-001235",
            title: "Lipid Profile",
            reportType: .bloodTest,
            status: .uploaded,
            patientId: "usr_preview_001",
            doctorId: nil,
            doctorName: nil,
            labName: "SRL Diagnostics",
            collectedAt: nil,
            reportedAt: nil,
            uploadedAt: .now.addingTimeInterval(-86400 * 3),
            notes: "Fasting sample",
            fileStorageKey: nil,
            fileType: nil,
            fileSizeBytes: nil,
            checksumSha256: nil,
            parameters: [],
            extraction: nil,
            highlightParameter: nil,
            createdAt: .now.addingTimeInterval(-86400 * 3),
            updatedAt: .now.addingTimeInterval(-86400 * 3)
        )
    ]
}
#endif
