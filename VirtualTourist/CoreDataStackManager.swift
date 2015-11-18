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
    func saveNewAnnotation(pinAnnotation: MKAnnotation) {
        
        let pinInCoreData = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: sharedContext)
        
        pinInCoreData.setValue(pinAnnotation.coordinate.longitude, forKey: "longitude")
        pinInCoreData.setValue(pinAnnotation.coordinate.latitude, forKey: "latitude")
        
        saveContext()
    }
    
    func loadAnnotations() -> [MKPointAnnotation] {
        var funcReturn = [MKPointAnnotation]()
        
        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try sharedContext.executeFetchRequest(request)
            if results.count > 0 {
                
                for pin in results {
                    
                    let lat = pin.valueForKey("latitude") as! Double
                    let long = pin.valueForKey("longitude") as! Double
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    funcReturn.append(annotation)
                }
            }
        } catch {
            print("error")
        }
        return funcReturn
    }
    
    func downloadAndSavePhoto(url: String) {
        let imageInCoreData = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: sharedContext)
        
        // Saving WebUrl
        imageInCoreData.setValue(url, forKey: "photoWebUrl")
        
        // Saving file locally & localUrl of the file
        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: url)!)!)
        let fileManager = NSFileManager.defaultManager()
        let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let unique = NSDate.timeIntervalSinceReferenceDate()
        let photoLocalUrl = docsDir.URLByAppendingPathComponent("\(unique).jpg").path!
        let imageJpg = UIImageJPEGRepresentation(image!, 1.0)
        
        NSKeyedArchiver.archiveRootObject(imageJpg!, toFile: photoLocalUrl)
        imageInCoreData.setValue(photoLocalUrl, forKey: "photoLocalUrl")
        
        saveContext()
    }
    
    //// Functions for PhotoAlbum
    func countCells() -> Int {
        var funcReturn = Int()
        
        let request = NSFetchRequest(entityName: "Photo")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try sharedContext.executeFetchRequest(request)
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
            let results = try sharedContext.executeFetchRequest(request)
            let photoLocalUrl = results[id].valueForKey("photoLocalUrl") as! String
            let imageData = UIImage(data: (NSKeyedUnarchiver.unarchiveObjectWithFile(photoLocalUrl) as! NSData))
            funcReturn = imageData!
        } catch {
            print("error accessing hard core data")
        }
        return funcReturn
    }
}