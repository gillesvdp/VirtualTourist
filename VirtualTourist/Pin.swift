//
//  Pin.swift
//  VirtualTourist
//
//  Created by Gilles on 11/18/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData

// @objc(Pin)

class Pin: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    struct Keys {
        static let latitude = 0.0 as Double
        static let longitude = 0.0 as Double
        static let photos = NSSet()
    }
    
    override convenience init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: Double , lon: Double, photoSet: NSSet, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        latitude = lat
        longitude = lon
        photos = photoSet
    }

}
