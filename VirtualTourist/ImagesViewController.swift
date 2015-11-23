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

class ImagesViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let flickrApi = FlickrAPI()
    let center = NSNotificationCenter.defaultCenter()
    var selectedPin : Pin!
    var downloadingPictures : Bool!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var bottomBtnOutlet: UIBarButtonItem!
    
    
    //// View Management
    
    @IBAction func bottomBtnPressed(sender: AnyObject) {
        bottomBtnOutlet.enabled = false
        self.bottomBtnOutlet.title = "Select a photo to be deleted"
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionView setup
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 2.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        // Set up Navigation Bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "replacePhotos")
        
        // Start FetchedResultsController
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // NSNotificationCenter
        center.addObserverForName("downloadedOnePhoto", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {_ in
            self.bottomBtnOutlet.title = "Downloading photos (\(ConstantStrings.sharedInstance.imagesDownloaded) / \(ConstantStrings.sharedInstance.totalImagesToDownload))"
        })
        center.addObserverForName("finishedDownloadingPhotos", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {_ in
            self.bottomBtnOutlet.title = "Select a photo to be deleted"
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = true
        })
        
        // Automatically download photos if no photos are associated with the Pin
        if ConstantStrings.sharedInstance.downloadingStatus == true {
            self.bottomBtnOutlet.enabled = false
            self.bottomBtnOutlet.title = "Downloading photos"
            self.navigationItem.rightBarButtonItem?.enabled = false
        } else {
            self.bottomBtnOutlet.enabled = false
            self.bottomBtnOutlet.title = "Select a photo to be deleted"
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // NSNotification Center
        center.removeObserver(self)
    }
    
    func replacePhotos() {
        let alert = UIAlertController(title: "Refresh Photo Collection", message: "WARNING: Refreshing the collection with new photos from Flickr will delete the current set of photos associated with this Pin.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK, download new photos", style: .Destructive, handler: {
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
    
    
    
    //// CollectionView Management
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ImageCell
        
        if photo.photoLocalUrl == "" {
            cell.imageView.image = UIImage(named: "downloading")
        } else {
            if let completeLocalUrl = photo.completeLocalUrl() {
                if let imageData = NSData(contentsOfFile: completeLocalUrl) {
                    if let image = UIImage(data: imageData) {
                        cell.imageView.image = image
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        bottomBtnOutlet.enabled = true
        self.bottomBtnOutlet.title = "Confirm deletion"
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        selectedIndexes.append(indexPath)
        cell?.backgroundColor = UIColor.redColor()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell?.backgroundColor = UIColor.whiteColor()
        }
        if selectedIndexes.count == 0 {
            bottomBtnOutlet.enabled = false
            self.bottomBtnOutlet.title = "Select a photo to be deleted"
        }
    }
    
    func downloadPhotos() {
        flickrApi.getPhotos(selectedPin.latitude as! Double, pinLongitude: selectedPin.longitude as! Double, pageNumber: nil,
            completionHandler: {(photoUrlArray, errorString) -> Void in
                guard errorString == nil else {
                    print(errorString)
                    return
                }
                CoreDataStackManager.sharedInstance.downloadAndSavePhotos(self.selectedPin, photoUrlArray: photoUrlArray!)
        })
    }
}
