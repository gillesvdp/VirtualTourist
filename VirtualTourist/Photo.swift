//
//  Photo.swift
//  VirtualTourist
//
//  Created by Gilles on 11/19/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData


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
    
}
