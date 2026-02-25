import Foundation
import Testing
@testable import AarogyaiOS

@Suite("DeepLinkHandler")
@MainActor
struct DeepLinkHandlerTests {
    @Test func parseCustomSchemeReports() {
        let url = URL(string: "aarogya://reports")!
        let link = DeepLinkHandler.parse(url: url)
        guard case .reports = link else {
            Issue.record("Expected .reports, got \(String(describing: link))")
            return
        }
    }

    @Test func parseCustomSchemeReportDetail() {
        let url = URL(string: "aarogya://reports/report-123")!
        let link = DeepLinkHandler.parse(url: url)
        guard case .reportDetail(let id) = link else {
            Issue.record("Expected .reportDetail, got \(String(describing: link))")
            return
        }
        #expect(id == "report-123")
    }

    @Test func parseCustomSchemeAccessGrants() {
        let url = URL(string: "aarogya://access-grants")!
        let link = DeepLinkHandler.parse(url: url)
        guard case .accessGrants = link else {
            Issue.record("Expected .accessGrants, got \(String(describing: link))")
            return
        }
    }

    @Test func parseCustomSchemeEmergency() {
        let url = URL(string: "aarogya://emergency")!
        let link = DeepLinkHandler.parse(url: url)
        guard case .emergency = link else {
            Issue.record("Expected .emergency, got \(String(describing: link))")
            return
        }
    }

    @Test func parseCustomSchemeSettings() {
        let url = URL(string: "aarogya://settings")!
        let link = DeepLinkHandler.parse(url: url)
        guard case .settings = link else {
            Issue.record("Expected .settings, got \(String(describing: link))")
            return
        }
    }

    @Test func parseUniversalLinkReportDetail() {
        let url = URL(string: "https://app.aarogya.kinvee.in/reports/rpt-456")!
        let link = DeepLinkHandler.parse(url: url)
        guard case .reportDetail(let id) = link else {
            Issue.record("Expected .reportDetail, got \(String(describing: link))")
            return
        }
        #expect(id == "rpt-456")
    }

    @Test func parseUnknownURLReturnsNil() {
        let url = URL(string: "https://other.example.com/path")!
        let link = DeepLinkHandler.parse(url: url)
        #expect(link == nil)
    }

    @Test func parseNotificationRouteReports() {
        let link = DeepLinkHandler.parse(notificationRoute: "reports/rpt-789")
        guard case .reportDetail(let id) = link else {
            Issue.record("Expected .reportDetail, got \(String(describing: link))")
            return
        }
        #expect(id == "rpt-789")
    }

    @Test func parseNotificationRouteEmergency() {
        let link = DeepLinkHandler.parse(notificationRoute: "emergency")
        guard case .emergency = link else {
            Issue.record("Expected .emergency, got \(String(describing: link))")
            return
        }
    }

    @Test func parseNotificationRouteUnknownReturnsNil() {
        let link = DeepLinkHandler.parse(notificationRoute: "unknown")
        #expect(link == nil)
    }
}
