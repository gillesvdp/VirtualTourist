//
//  Photo.swift
//  VirtualTourist
//
//  Created by Gilles on 11/19/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Photo: NSManagedObject {
    
    @NSManaged var photoUniqueId: String?
    @NSManaged var photoLocalUrl: String?
    @NSManaged var photoWebUrl: String?
    @NSManaged var pin: Pin?

    struct Keys {
        static let photoUniqueId = "photoUniqueId"
        static let photoLocalUrl = "photoLocalUrl"
        static let photoWebUrl = "photoWebUrl"
        static let pin = "pin"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(uniqueId: String, localUrl: String , webUrl: String, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        photoUniqueId = uniqueId
        photoLocalUrl = localUrl
        photoWebUrl = webUrl
    }
    
    func downloadAndSaveImage(selectedPin: Pin) {
        // Downloading image
        let photo = self
        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: photo.photoWebUrl!)!)!)
        
        // Storing the image locally
        let fileManager = NSFileManager.defaultManager()
        let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let unique = NSDate.timeIntervalSinceReferenceDate()
        let photoLocalUrl = docsDir.URLByAppendingPathComponent("\(unique).jpg").path!
        let imageJpg = UIImageJPEGRepresentation(image!, 1.0)
        imageJpg?.writeToFile(photoLocalUrl, atomically: true)
        
        // Storing the image localUrl in CoreData
        photo.photoLocalUrl = photoLocalUrl
        photo.photoUniqueId = "\(unique)"
        
    }
    
    override func prepareForDeletion() {
        // Delete from Disk, before being removed from CoreData
        let fileManager = NSFileManager.defaultManager()
        let path = self.photoLocalUrl
        do {
            try fileManager.removeItemAtPath(path!)
        } catch {
            print(error)
        }
    }
    
}
