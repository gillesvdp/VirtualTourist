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
    
    @NSManaged var id: String
    @NSManaged var webUrl: String
    @NSManaged var localUrl: String?
    @NSManaged var pin: Pin

    var loadUpdateHandler: (() -> Void)?
    
    struct Keys {
        static let id = "id"
        static let webUrl = "webUrl"
        static let localUrl = "localUrl"
        static let pin = "pin"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(webUrl: String, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.id = "\(NSDate.timeIntervalSinceReferenceDate())"
        self.webUrl = webUrl
    }
    
    func downloadPhoto(selectedPin: Pin) {
        // Download the image
        let photo = self
        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: photo.webUrl)!)!)
        
        // Storing the image locally
        let imageJpg = UIImageJPEGRepresentation(image!, 1.0)
        photo.localUrl = "\(self.id).jpg"
        imageJpg!.writeToFile(completeLocalUrl()!, atomically:  true)
        
        loadUpdateHandler?()
    }
    
    override func prepareForDeletion() {
        // Delete from Disk, before being removed from CoreData
        if let path = self.completeLocalUrl() {
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtPath(path)
            } catch {
                print(error)
            }
        }
    }
    
    func completeLocalUrl() -> String? {
        var funcReturn : String?
        if let _ = self.localUrl {
            let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
            let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(localUrl!)
            funcReturn = fullURL.path
        }
        return funcReturn
    }
}
