//
//  Pin.swift
//  VirtualTourist
//
//  Created by Gilles on 11/19/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSOrderedSet?

    struct Keys {
        static let longitude = "longitude"
        static let latitude = "latitude"
        static let photos = "photos"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lon: Double , lat: Double, photoSet: NSOrderedSet, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        longitude = lon
        latitude = lat
        photos = photoSet
    }
    
}
