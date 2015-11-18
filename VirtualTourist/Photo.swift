//
//  Photo.swift
//  VirtualTourist
//
//  Created by Gilles on 11/16/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    struct Keys {
        static let photoLocalUrl = ""
        static let photoWebUrl = ""
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(localUrl: String , webUrl: String, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        photoLocalUrl = localUrl
        photoWebUrl = webUrl
    }
}

