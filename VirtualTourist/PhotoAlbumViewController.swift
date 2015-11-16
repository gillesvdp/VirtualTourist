//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    
    var managedObjectContext: NSManagedObjectContext?
    
    
    
    // MARK: IBOutlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    
    // ask the `NSFetchedResultsController` for the section
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as UICollectionViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    
    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(cell: UITableViewCell,
        atIndexPath indexPath: NSIndexPath) {
            let item = self.fetchedResultsController.objectAtIndexPath(indexPath) as Item
            cell.textLabel.text = item.name
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject object: AnyObject,
        atIndexPath indexPath: NSIndexPath,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath) {
            switch type {
            case .Insert:
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            case .Update:
                let cell = self.tableView.cellForRowAtIndexPath(indexPath)
                self.configureCell(cell!, atIndexPath: indexPath)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            case .Move:
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
        
        var fetchedResultsController: NSFetchedResultsController {
            // return if already initialized
            if self._fetchedResultsController != nil {
                return self._fetchedResultsController!
            }
            let managedObjectContext = self.managedObjectContext!
            
            let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: managedObjectContext)
            let sort = NSSortDescriptor(key: "photoWebUrl", ascending: true)
            let req = NSFetchRequest()
            req.entity = entity
            req.sortDescriptors = [sort]
            
            /* NSFetchedResultsController initialization
            a `nil` `sectionNameKeyPath` generates a single section */
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            self._fetchedResultsController = aFetchedResultsController
            
            // perform initial model fetch
            var e: NSError?
            if !self._fetchedResultsController!.performFetch(&e) {
                println("fetch error: \(e!.localizedDescription)")
                abort();
            }
            
            return self._fetchedResultsController!
        }
        var _fetchedResultsController: NSFetchedResultsController?
}





