//
//  CoreDataStackManager.swift
//  VirtualTourist
//
//  Created by Gilles on 11/18/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let SQLITE_FILE_NAME = "VirtualTourist.sqlite"

class CoreDataStackManager {
    
    static var sharedInstance = CoreDataStackManager()
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    lazy var sharedContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("VirtualTourist", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("VirtualTourist.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            if coordinator == nil {
                coordinator = nil
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = failureReason
                dict[NSUnderlyingErrorKey] = error
                error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                print(error)
            }
        } catch {
            print(error)
        }
        return coordinator
    }()
    
    func saveContext() {
        if let _ = sharedContext {
            if sharedContext!.hasChanges {
                do {
                    try sharedContext!.save()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //// Functions for MapView
    func fetchPins() -> [Pin] {
        var funcReturn = [Pin]()
        
        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try sharedContext!.executeFetchRequest(request) as! [Pin]
            funcReturn = results
        } catch {
            print("error")
        }
        return funcReturn
    }
    
    func saveNewPin(newPinLongitude: Double, newPinLatitude: Double) -> Pin {
        let newPin = Pin(lon: newPinLongitude, lat: newPinLatitude, photoSet: [], context: sharedContext!)
        saveContext()
        return newPin
    }
    
    func downloadAndSavePhotos(selectedPin: Pin, photoUrlArray: [String]) {
        // Saving the photoWebUrl in CoreData
        for webUrl in photoUrlArray {
            let newPhoto = Photo(webUrl: webUrl, context: self.sharedContext!)
            newPhoto.pin = selectedPin
        }
        saveContext()
        
        // Start downloading images
        ConstantStrings.sharedInstance.downloadingStatus = true
        ConstantStrings.sharedInstance.imagesDownloaded = 0
        ConstantStrings.sharedInstance.totalImagesToDownload = selectedPin.photos!.count
        for photo in selectedPin.photos! {
            let photo = photo as! Photo
            photo.downloadPhoto(selectedPin)
            
            ConstantStrings.sharedInstance.imagesDownloaded += 1
            NSNotificationCenter.defaultCenter().postNotificationName("downloadedOnePhoto", object: self)
            saveContext()
        }
        ConstantStrings.sharedInstance.downloadingStatus = false
        ConstantStrings.sharedInstance.imagesDownloaded = 0
        ConstantStrings.sharedInstance.totalImagesToDownload = 0
        NSNotificationCenter.defaultCenter().postNotificationName("finishedDownloadingPhotos", object: self)
    }
    
    //// Functions for PhotoAlbum
    func deletePhotosOfPin(selectedPin: Pin) {
        for photo in selectedPin.photos! {
            if let photo = photo as? Photo {
                CoreDataStackManager.sharedInstance.sharedContext!.deleteObject(photo)
            }
        }
        CoreDataStackManager.sharedInstance.saveContext()
    }
}