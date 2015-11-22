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
    
    func downloadPhoto(selectedPin: Pin) {
        // Downloading image
        let photo = self
        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: photo.photoWebUrl!)!)!)
        
        // Storing the image locally
        let unique = NSDate.timeIntervalSinceReferenceDate()
        let photoLocalUrl = "\(unique).jpg"
        let imageJpg = UIImageJPEGRepresentation(image!, 1.0)
        
        photo.photoUniqueId = "\(unique)"
        photo.photoLocalUrl = photoLocalUrl        
        imageJpg!.writeToFile(completeLocalUrl()!, atomically:  true)
    }
    
    override func prepareForDeletion() {
        // Delete from Disk, before being removed from CoreData
        let fileManager = NSFileManager.defaultManager()
        let path = self.completeLocalUrl()
        do {
            try fileManager.removeItemAtPath(path!)
        } catch {
            print(error)
        }
    }
    
    func completeLocalUrl() -> String? {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(photoLocalUrl!)
        return fullURL.path
    }
}
