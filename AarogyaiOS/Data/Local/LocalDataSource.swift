import Foundation
import SwiftData
import OSLog

@ModelActor
actor LocalDataSource {

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            CachedReport.self,
            CachedUser.self,
            CachedEmergencyContact.self
        ])
        let config = ModelConfiguration("AarogyaCache", isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [config])
    }

    // MARK: - Generic Fetch

    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        try modelContext.fetch(descriptor)
    }

    func fetchOne<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T? {
        var limited = descriptor
        limited.fetchLimit = 1
        return try modelContext.fetch(limited).first
    }

    func fetchCount<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> Int {
        try modelContext.fetchCount(descriptor)
    }

    // MARK: - Insert

    func insert<T: PersistentModel>(_ model: T) throws {
        modelContext.insert(model)
        try modelContext.save()
    }

    func insertBatch<T: PersistentModel>(_ models: [T]) throws {
        for model in models {
            modelContext.insert(model)
        }
        try modelContext.save()
    }

    // MARK: - Delete

    func delete<T: PersistentModel>(_ model: T) throws {
        modelContext.delete(model)
        try modelContext.save()
    }

    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        try modelContext.delete(model: type)
        try modelContext.save()
    }

    // MARK: - Save

    func save() throws {
        try modelContext.save()
    }

    // MARK: - Report Helpers

    func fetchCachedReports() throws -> [CachedReport] {
        let descriptor = FetchDescriptor<CachedReport>(
            sortBy: [SortDescriptor(\.uploadedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchCachedReport(id: String) throws -> CachedReport? {
        let descriptor = FetchDescriptor<CachedReport>(
            predicate: #Predicate { $0.reportId == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func syncReports(_ reports: [Report]) throws {
        try modelContext.delete(model: CachedReport.self)
        for report in reports {
            modelContext.insert(CachedReport(from: report))
        }
        try modelContext.save()
    }

    // MARK: - User Helpers

    func fetchCachedUser(id: String) throws -> CachedUser? {
        let descriptor = FetchDescriptor<CachedUser>(
            predicate: #Predicate { $0.userId == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func syncUser(_ user: User) throws {
        if let existing = try fetchCachedUser(id: user.id) {
            modelContext.delete(existing)
        }
        modelContext.insert(CachedUser(from: user))
        try modelContext.save()
    }

    // MARK: - Emergency Contact Helpers

    func fetchCachedEmergencyContacts() throws -> [CachedEmergencyContact] {
        let descriptor = FetchDescriptor<CachedEmergencyContact>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func syncEmergencyContacts(_ contacts: [EmergencyContact]) throws {
        try modelContext.delete(model: CachedEmergencyContact.self)
        for contact in contacts {
            modelContext.insert(CachedEmergencyContact(from: contact))
        }
        try modelContext.save()
    }
}
