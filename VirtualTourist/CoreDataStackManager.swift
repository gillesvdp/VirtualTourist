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
import MapKit

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
    
    func loadAnnotations() -> [Pin] {
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
    
    func downloadAndSavePhotos(pinAnnotation: MKAnnotation, photoUrlArray: [String]) {
        
        var photoArray = [Photo]()
        
        var count = 1
        for photoWebUrl in photoUrlArray {
            
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: photoWebUrl)!)!)
            let fileManager = NSFileManager.defaultManager()
            let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
            let unique = NSDate.timeIntervalSinceReferenceDate()
            let photoLocalUrl = docsDir.URLByAppendingPathComponent("\(unique).jpg").path!
            let imageJpg = UIImageJPEGRepresentation(image!, 1.0)
            
            NSKeyedArchiver.archiveRootObject(imageJpg!, toFile: photoLocalUrl)
            
            let newPhoto = Photo(localUrl: photoLocalUrl, webUrl: photoWebUrl, context: self.sharedContext)
            photoArray.append(newPhoto)
            
            print("\(count) / \(photoUrlArray.count)")
            count += 1
        }
        
        let photoSet = NSSet(array: photoArray)
        _ = Pin(lon: pinAnnotation.coordinate.longitude, lat: pinAnnotation.coordinate.latitude, photoSet: photoSet, context: sharedContext)
        
        saveContext()
    }
    
    //// Functions for PhotoAlbum
    func countCells() -> Int {
        var funcReturn = Int()
        
        let request = NSFetchRequest(entityName: "Photo")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try sharedContext.executeFetchRequest(request) as! [Photo]
            funcReturn = results.count
        } catch {
            print("error accessing hard core data")
        }
        return funcReturn
    }
    
    func imageForCell(id: Int) -> UIImage {
        var funcReturn = UIImage()
        
        let request = NSFetchRequest(entityName: "Photo")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try sharedContext.executeFetchRequest(request) as! [Photo]
            let photoLocalUrl = results[id].photoLocalUrl as String!
            let imageData = UIImage(data: (NSKeyedUnarchiver.unarchiveObjectWithFile(photoLocalUrl) as! NSData))
            funcReturn = imageData!
        } catch {
            print("error accessing hard core data")
        }
        return funcReturn
    }
}