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
    
    lazy var sharedContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
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
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            print(error)
        }
        
        return coordinator
    }()
    
    func saveContext () {
        if sharedContext.hasChanges {
            do {
                try sharedContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    //// Functions for MapView
    func fetchPins() -> [Pin] {
        var funcReturn = [Pin]()
        
        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try sharedContext.executeFetchRequest(request) as! [Pin]
            funcReturn = results
        } catch {
            print("error")
        }
        return funcReturn
    }
    
    func saveNewPin(newPinLongitude: Double, newPinLatitude: Double) -> Pin {
        let newPin = Pin(lon: newPinLongitude, lat: newPinLatitude, photoSet: [], context: sharedContext)
        saveContext()
        return newPin
    }
    
    func downloadAndSavePhotos(selectedPin: Pin, photoUrlArray: [String]) {
        // Saving the photoWebUrl in CoreData
        for webUrl in photoUrlArray {
            let newPhoto = Photo(uniqueId: "", localUrl: "", webUrl: webUrl, context: self.sharedContext)
            newPhoto.pin = selectedPin
        }
        self.saveContext()
        
        // Start downloading images
        ConstantStrings.sharedInstance.downloadingStatus = true
        ConstantStrings.sharedInstance.imagesDownloaded = 0
        ConstantStrings.sharedInstance.totalImagesToDownload = selectedPin.photos!.count
        for photo in selectedPin.photos! {
            let photo = photo as! Photo
            photo.downloadAndSaveImage(selectedPin)
            
            
            ConstantStrings.sharedInstance.imagesDownloaded += 1
            NSNotificationCenter.defaultCenter().postNotificationName("downloadedOnePhoto", object: self)
        }
        ConstantStrings.sharedInstance.downloadingStatus = false
        ConstantStrings.sharedInstance.imagesDownloaded = 0
        ConstantStrings.sharedInstance.totalImagesToDownload = 0
        NSNotificationCenter.defaultCenter().postNotificationName("finishedDownloadingPhotos", object: self)
        self.saveContext()
    }
    
    //// Functions for PhotoAlbum
    func deletePhotosOfPin(selectedPin: Pin) {
        for photo in selectedPin.photos! {
            if let photo = photo as? Photo {
                CoreDataStackManager.sharedInstance.sharedContext.deleteObject(photo)
            }
        }
        CoreDataStackManager.sharedInstance.saveContext()
    }
}