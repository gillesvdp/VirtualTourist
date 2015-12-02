//
//  ImagesViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 11/21/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ImagesViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    let flickrApi = FlickrAPI()
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var selectedPin : Pin?
    var downloadingPictures : Bool!
    
    @IBOutlet weak var deleteInstructionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var bottomBtnOutlet: UIBarButtonItem!
        
    @IBAction func bottomBtnPressed(sender: AnyObject) {
        replacePhotos()
    }
    
    //// NSFetchedResultsController
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
        case .Delete:
            self.collectionView!.deleteSections(NSIndexSet(index: sectionIndex))
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView!.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView!.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView!.reloadItemsAtIndexPaths([indexPath])
            }
            }, completion: nil)
    }
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    lazy var sharedContext: NSManagedObjectContext = {
        CoreDataStackManager.sharedInstance.sharedContext!
    }()
    
    // MARK: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        // Add a sort descriptor.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoUniqueId", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.selectedPin!);
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
    
    
    
    
    
    
    
    // Photos management
    
    func downloadPhotos() {
        if let _ = selectedPin {
            flickrApi.getPhotos(selectedPin!.latitude as! Double, pinLongitude: selectedPin!.longitude as! Double, pageNumber: nil,
                completionHandler: {(photoUrlArray, errorString) -> Void in
                    guard errorString == nil else {
                        print(errorString)
                        return
                    }
                    
                    guard photoUrlArray!.count > 0 else {
                        self.showAlertViewController("Error", errorMessage: "No images could be found near this location.")
                        return
                    }
                    
                    CoreDataStackManager.sharedInstance.downloadAndSavePhotos(self.selectedPin!, photoUrlArray: photoUrlArray!)
            })
        }
    }
    
    func deleteSelectedPhoto() {
        var photosToDelete = [Photo]()
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for indexPath in selectedIndexes {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor.whiteColor()
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        selectedIndexes = [NSIndexPath]()
        CoreDataStackManager.sharedInstance.saveContext()
    }
    
    func replacePhotos() {
        let alert = UIAlertController(title: "Refresh Photo Collection", message: "WARNING: Refreshing the collection with new photos from Flickr will delete the current set of photos associated with this Pin.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK, download new photos", style: .Destructive, handler: {
            UIAlertAction -> Void in
            
            // In case we are currently in edit mode, reset the screen into normal mode
            if let btn = self.navigationItem.rightBarButtonItem {
                if btn.title == "Done" {
                    btn.title = "Edit"
                    self.deleteInstructionLabel.hidden = true
                }
            }
            
            self.bottomBtnOutlet.enabled = false
            self.deleteAllPhotos()
            self.downloadPhotos()
        })
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance.saveContext()
        selectedIndexes = [NSIndexPath]()
    }
    
    func editBtnPressed(){
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {
            self.navigationItem.rightBarButtonItem?.title = "Done"
            deleteInstructionLabel.hidden = false
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            deleteInstructionLabel.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails" {
            let destinationVC = segue.destinationViewController as! DetailsViewController
            let cell = sender as! ImageCell
            destinationVC.photo = cell.photo
            
        }
    }
    
    func showAlertViewController(title: String, errorMessage: String) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
