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
        return selectedPin.photos!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCellController
        cell.imageView.image = CoreDataStackManager.sharedInstance.imageForCell(selectedPin, id: indexPath.row)
        return cell
    }
    
    func checkWhichPin() {
        let arrayOfExistingPins = CoreDataStackManager.sharedInstance.fetchPins() as [Pin]
        print(arrayOfExistingPins.count)
        for pin in arrayOfExistingPins {
            if pin.latitude == selectedPinLatitude && pin.longitude == selectedPinLongitude {
                selectedPin = pin
            }
        }
    }
    
    func downloadPhotos() {
        flickrApi.getPhotos(selectedPin.latitude as! Double, pinLongitude: selectedPin.longitude as! Double,
            completionHandler: {(photoUrlArray, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let _ = errorString {
                        print(errorString!)
                    } else {
                        CoreDataStackManager.sharedInstance.downloadAndSavePhotos(self.selectedPin, photoUrlArray: photoUrlArray!)
                        self.collectionView?.reloadData()
                    }
                })
        })
        
    }
    
    override func viewDidLoad() {
        checkWhichPin()
        if selectedPin.photos?.count == 0 {
            downloadPhotos()
        }
    }
}





