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
        
        print("Instantiating the applicationDocumentsDirectory property")
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        print("Instantiating the managedObjectModel property")
        
        let modelURL = NSBundle.mainBundle().URLForResource("VirtualTourist", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        print("Instantiating the persistentStoreCoordinator property")
        
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        print("sqlite path: \(url.path!)")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    func saveContext () {
        if sharedContext.hasChanges {
            do {
                try sharedContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror)")
                //abort()
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
    
    func saveNewPin(newPinLongitude: Double, newPinLatitude: Double) {
        _ = Pin(lon: newPinLongitude, lat: newPinLatitude, photoSet: [], context: sharedContext)
        saveContext()
    }
    
    func downloadAndSavePhotos(selectedPin: Pin, photoUrlArray: [String]) {
        
        // Saving the photoWebUrl in CoreData
        for webUrl in photoUrlArray {
            let newPhoto = Photo(uniqueId: "", localUrl: "", webUrl: webUrl, context: self.sharedContext)
            newPhoto.pin = selectedPin
            self.saveContext()
        }
        
        // Start downloading images
        for photo in selectedPin.photos! {
            // Downloading image
            let photo = photo as! Photo
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: photo.photoWebUrl!)!)!)
            
            // Storing the image locally
            let fileManager = NSFileManager.defaultManager()
            let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
            let unique = NSDate.timeIntervalSinceReferenceDate()
            let photoLocalUrl = docsDir.URLByAppendingPathComponent("\(unique).jpg").path!
            let imageJpg = UIImageJPEGRepresentation(image!, 1.0)
            NSKeyedArchiver.archiveRootObject(imageJpg!, toFile: photoLocalUrl)
            
            // Storing the image localUrl in CoreData
            photo.photoUniqueId = "\(unique)"
            photo.photoLocalUrl = photoLocalUrl
            self.saveContext()
        }
    }
    
    //// Functions for PhotoAlbum
    func imageForCell(selectedPin: Pin, id: Int) -> UIImage {
        var funcReturn = UIImage()
        
        var photoArray = [Photo]()
        for photo in selectedPin.photos! {
            photoArray.append(photo as! Photo)
        }
        let photoLocalUrl = photoArray[id].photoLocalUrl! as String
        print(photoLocalUrl)
        let imageData = UIImage(data: (NSKeyedUnarchiver.unarchiveObjectWithFile(photoLocalUrl) as! NSData))
        funcReturn = imageData!
        
        return funcReturn
    }
    func imageForCell2(photoLocalUrl: String) -> UIImage {
        var funcReturn = UIImage()
        
        print(photoLocalUrl)
        let imageData = UIImage(data: (NSKeyedUnarchiver.unarchiveObjectWithFile(photoLocalUrl) as! NSData))
        funcReturn = imageData!
        
        return funcReturn
    }
}