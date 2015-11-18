//
//  Pin.swift
//  VirtualTourist
//
//  Created by Gilles on 11/18/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
    
    struct Keys {
        static let longitude = 0.0 as Double
        static let latitude = 0.0 as Double
        static let photos = NSSet()
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lon: Double , lat: Double, photoSet: NSSet, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        longitude = lon
        latitude = lat
        photos = photoSet
    }

}
