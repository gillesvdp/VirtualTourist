//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gilles on 11/16/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var photoLocalUrl: String?
    @NSManaged var photoWebUrl: String?

}