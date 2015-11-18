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
}