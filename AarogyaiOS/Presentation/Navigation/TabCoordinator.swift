import SwiftUI

enum AppTab: String, CaseIterable, Sendable {
    case reports
    case access
    case emergency
    case settings
}

struct TabCoordinator: View {
    @State private var selectedTab: AppTab = .reports

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Reports", systemImage: "doc.text", value: .reports) {
                NavigationStack {
                    PlaceholderView(title: "Reports")
                }
            }

            Tab("Access", systemImage: "person.2", value: .access) {
                NavigationStack {
                    PlaceholderView(title: "Access Grants")
                }
            }

            Tab("Emergency", systemImage: "phone.fill", value: .emergency) {
                NavigationStack {
                    PlaceholderView(title: "Emergency Contacts")
                }
            }

            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    PlaceholderView(title: "Settings")
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

private struct PlaceholderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title)
            .navigationTitle(title)
    }
}
