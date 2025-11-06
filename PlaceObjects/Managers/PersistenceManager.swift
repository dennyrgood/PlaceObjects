//
//  PersistenceManager.swift
//  PlaceObjects
//
//  Handles local persistence and iCloud synchronization of placed objects
//

import Foundation
import CloudKit

/// Manages persistence of placed objects with local and iCloud storage
class PersistenceManager: ObservableObject {
    
    // MARK: - Constants
    
    /// CloudKit container identifier - can be configured for different environments
    static let cloudKitContainerIdentifier = "iCloud.com.placeobjects.app"
    
    // MARK: - Published Properties
    
    @Published var placedObjects: [PlacedObject] = []
    @Published var iCloudSyncEnabled: Bool = false
    @Published var syncStatus: SyncStatus = .idle
    
    private let localStorageKey = "PlacedObjectsData"
    private lazy var container: CKContainer = {
        return CKContainer(identifier: Self.cloudKitContainerIdentifier)
    }()
    private lazy var database: CKDatabase = {
        return container.privateCloudDatabase
    }()
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case failed(Error)
    }
    
    init() {
        // Load from local storage immediately (no CloudKit dependency)
        loadFromLocalStorage()
        
        // Only check iCloud if explicitly enabled by user
        // Don't check automatically to avoid simulator issues
        print("PersistenceManager initialized - iCloud sync disabled by default")
    }
    
    // MARK: - Local Storage
    
    /// Save objects to local storage
    func saveToLocalStorage() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(placedObjects)
            UserDefaults.standard.set(data, forKey: localStorageKey)
        } catch {
            print("Failed to save to local storage: \(error)")
        }
    }
    
    /// Load objects from local storage
    func loadFromLocalStorage() {
        guard let data = UserDefaults.standard.data(forKey: localStorageKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            placedObjects = try decoder.decode([PlacedObject].self, from: data)
        } catch {
            print("Failed to load from local storage: \(error)")
        }
    }
    
    /// Add a new placed object
    func addObject(_ object: PlacedObject) {
        placedObjects.append(object)
        saveToLocalStorage()
        
        if iCloudSyncEnabled {
            syncToiCloud(object)
        }
    }
    
    /// Update an existing object
    func updateObject(_ object: PlacedObject) {
        if let index = placedObjects.firstIndex(where: { $0.id == object.id }) {
            placedObjects[index] = object
            saveToLocalStorage()
            
            if iCloudSyncEnabled {
                syncToiCloud(object)
            }
        }
    }
    
    /// Remove an object
    func removeObject(_ object: PlacedObject) {
        placedObjects.removeAll { $0.id == object.id }
        saveToLocalStorage()
        
        if iCloudSyncEnabled {
            deleteFromiCloud(object)
        }
    }
    
    /// Clear all objects
    func clearAllObjects() {
        placedObjects.removeAll()
        saveToLocalStorage()
        
        if iCloudSyncEnabled {
            clearFromiCloud()
        }
    }
    
    // MARK: - iCloud Sync
    
    private func checkiCloudStatus() {
        // Add timeout to prevent hanging in simulator
        let timeoutWorkItem = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                print("iCloud status check timed out - disabling iCloud sync")
                self?.iCloudSyncEnabled = false
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5.0, execute: timeoutWorkItem)
        
        container.accountStatus { [weak self] status, error in
            timeoutWorkItem.cancel() // Cancel timeout if we got a response
            
            DispatchQueue.main.async {
                if let error = error {
                    print("iCloud status check error: \(error.localizedDescription)")
                    self?.iCloudSyncEnabled = false
                    return
                }
                
                switch status {
                case .available:
                    print("iCloud available - enabling sync")
                    self?.iCloudSyncEnabled = true
                    self?.syncFromiCloud()
                case .noAccount:
                    print("No iCloud account - sync disabled")
                    self?.iCloudSyncEnabled = false
                case .restricted:
                    print("iCloud restricted - sync disabled")
                    self?.iCloudSyncEnabled = false
                case .couldNotDetermine:
                    print("Could not determine iCloud status - sync disabled")
                    self?.iCloudSyncEnabled = false
                case .temporarilyUnavailable:
                    print("iCloud temporarily unavailable - sync disabled")
                    self?.iCloudSyncEnabled = false
                @unknown default:
                    print("Unknown iCloud status - sync disabled")
                    self?.iCloudSyncEnabled = false
                }
            }
        }
    }
    
    private func syncToiCloud(_ object: PlacedObject) {
        syncStatus = .syncing
        
        let record = CKRecord(recordType: "PlacedObject", recordID: CKRecord.ID(recordName: object.id.uuidString))
        
        // Encode object data
        if let data = try? JSONEncoder().encode(object) {
            record["data"] = data as CKRecordValue
            record["name"] = object.name as CKRecordValue
            record["createdAt"] = object.createdAt as CKRecordValue
            
            database.save(record) { [weak self] _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.syncStatus = .failed(error)
                        print("Failed to sync to iCloud: \(error)")
                    } else {
                        self?.syncStatus = .success
                    }
                }
            }
        }
    }
    
    private func syncFromiCloud() {
        syncStatus = .syncing
        
        let query = CKQuery(recordType: "PlacedObject", predicate: NSPredicate(value: true))
        
        database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let matchResults):
                    let records = matchResults.matchResults.compactMap { try? $0.1.get() }
                    self?.processRecordsFromiCloud(records)
                    self?.syncStatus = .success
                case .failure(let error):
                    self?.syncStatus = .failed(error)
                    print("Failed to sync from iCloud: \(error)")
                }
            }
        }
    }
    
    private func processRecordsFromiCloud(_ records: [CKRecord]) {
        var syncedObjects: [PlacedObject] = []
        for record in records {
            if let data = record["data"] as? Data,
               let object = try? JSONDecoder().decode(PlacedObject.self, from: data) {
                syncedObjects.append(object)
            }
        }
        
        // Merge with local objects (prefer newer versions)
        mergeObjects(syncedObjects)
    }
    
    private func deleteFromiCloud(_ object: PlacedObject) {
        let recordID = CKRecord.ID(recordName: object.id.uuidString)
        
        database.delete(withRecordID: recordID) { _, error in
            if let error = error {
                print("Failed to delete from iCloud: \(error)")
            }
        }
    }
    
    private func clearFromiCloud() {
        let query = CKQuery(recordType: "PlacedObject", predicate: NSPredicate(value: true))
        
        database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { [weak self] result in
            guard case .success(let matchResults) = result else { return }
            
            let records = matchResults.matchResults.compactMap { try? $0.1.get() }
            let recordIDs = records.map { $0.recordID }
            let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
            
            self?.database.add(deleteOperation)
        }
    }
    
    private func mergeObjects(_ cloudObjects: [PlacedObject]) {
        var mergedObjects = placedObjects
        
        for cloudObject in cloudObjects {
            if let index = mergedObjects.firstIndex(where: { $0.id == cloudObject.id }) {
                // Keep the newer version
                if cloudObject.lastModified > mergedObjects[index].lastModified {
                    mergedObjects[index] = cloudObject
                }
            } else {
                // Add new object from cloud
                mergedObjects.append(cloudObject)
            }
        }
        
        placedObjects = mergedObjects
        saveToLocalStorage()
    }
    
    /// Toggle iCloud sync
    func toggleiCloudSync() {
        if !iCloudSyncEnabled {
            // User is turning it ON - check status first
            print("User enabling iCloud sync - checking status...")
            checkiCloudStatus()
        } else {
            // User is turning it OFF
            print("User disabled iCloud sync")
            iCloudSyncEnabled = false
        }
    }
}
