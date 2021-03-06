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
    
    let flickrApi = FlickrAPI()
    var selectedPinLatitude = Double()
    var selectedPinLongitude = Double()
    
    var selectedPin : Pin!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCellController
        
        if photo.photoLocalUrl == "" {
            cell.imageView.image = UIImage(named: "downloading")
        } else {
            cell.imageView.image = UIImage(data: NSKeyedUnarchiver.unarchiveObjectWithFile(photo.photoLocalUrl!) as! NSData)
        }
        
        return cell
    }
    
    func downloadPhotos() {
        flickrApi.getPhotos(selectedPin.latitude as! Double, pinLongitude: selectedPin.longitude as! Double,
            completionHandler: {(photoUrlArray, errorString) -> Void in
                guard errorString == nil else {
                    print(errorString)
                    return
                }
                CoreDataStackManager.sharedInstance.downloadAndSavePhotos(self.selectedPin, photoUrlArray: photoUrlArray!)
        })
    }
    
    override func viewDidLoad() {
        if selectedPin.photos?.count == 0 {
            downloadPhotos()
        }
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        fetchedResultsController.delegate = self
        collectionView!.allowsMultipleSelection = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "downloadNewSetOfPhotos")
    }
    
    func downloadNewSetOfPhotos() {
        let alert = UIAlertController(title: "Warning", message: "Downloading new photos will delete the current set of photos associated with this Pin", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK, Download new photos", style: .Destructive, handler: {
            UIAlertAction -> Void in
            
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
        CoreDataStackManager.sharedInstance.sharedContext
    }()

    // MARK: - Fetched Results Controller

    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        // Add a sort descriptor.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoUniqueId", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.selectedPin);
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
}





