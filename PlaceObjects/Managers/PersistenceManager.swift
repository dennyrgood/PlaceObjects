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
    
    @Published var placedObjects: [PlacedObject] = []
    @Published var iCloudSyncEnabled: Bool = false
    @Published var syncStatus: SyncStatus = .idle
    
    private let localStorageKey = "PlacedObjectsData"
    private let container: CKContainer
    private let database: CKDatabase
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case failed(Error)
    }
    
    init() {
        // Initialize CloudKit container
        self.container = CKContainer(identifier: "iCloud.com.placeobjects.app")
        self.database = container.privateCloudDatabase
        
        // Load from local storage
        loadFromLocalStorage()
        
        // Check iCloud availability
        checkiCloudStatus()
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
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.iCloudSyncEnabled = false
                    return
                }
                
                switch status {
                case .available:
                    self?.iCloudSyncEnabled = true
                    self?.syncFromiCloud()
                case .noAccount, .restricted, .couldNotDetermine:
                    self?.iCloudSyncEnabled = false
                @unknown default:
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
        
        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.syncStatus = .failed(error)
                    print("Failed to sync from iCloud: \(error)")
                    return
                }
                
                guard let records = records else {
                    self?.syncStatus = .success
                    return
                }
                
                var syncedObjects: [PlacedObject] = []
                for record in records {
                    if let data = record["data"] as? Data,
                       let object = try? JSONDecoder().decode(PlacedObject.self, from: data) {
                        syncedObjects.append(object)
                    }
                }
                
                // Merge with local objects (prefer newer versions)
                self?.mergeObjects(syncedObjects)
                self?.syncStatus = .success
            }
        }
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
        
        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            guard let records = records, error == nil else { return }
            
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
        iCloudSyncEnabled.toggle()
        
        if iCloudSyncEnabled {
            syncFromiCloud()
        }
    }
}
