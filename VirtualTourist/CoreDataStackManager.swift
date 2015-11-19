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

class CoreDataStackManager {
    
    static var sharedInstance = CoreDataStackManager()
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var sharedContext: NSManagedObjectContext {
        return appDel.managedObjectContext
    }
    
    func saveContext() -> Bool {
        var funcReturn = Bool()
        
        do {
            try sharedContext.save()
            funcReturn = true
        } catch {
            funcReturn = false
            print(error)
        }
        return funcReturn
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
        
        var count = 1
        for photoWebUrl in photoUrlArray {
            
            //let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
            //let newQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            //dispatch_async(newQueue, {
                let image = UIImage(data: NSData(contentsOfURL: NSURL(string: photoWebUrl)!)!)
                let fileManager = NSFileManager.defaultManager()
                let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
                let unique = NSDate.timeIntervalSinceReferenceDate()
                let photoLocalUrl = docsDir.URLByAppendingPathComponent("\(unique).jpg").path!
                let imageJpg = UIImageJPEGRepresentation(image!, 1.0)
                
                NSKeyedArchiver.archiveRootObject(imageJpg!, toFile: photoLocalUrl)
                
                let newPhoto = Photo(localUrl: photoLocalUrl, webUrl: photoWebUrl, context: self.sharedContext)
                newPhoto.pin = selectedPin
                
                print("\(count) / \(photoUrlArray.count)")
                count += 1
                self.saveContext()
            //})
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