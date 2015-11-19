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
    
    var selectedPinLatitude = Double()
    var selectedPinLongitude = Double()
    
    var selectedPin : Pin!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return CoreDataStackManager.sharedInstance.countCells()
        return selectedPin.photos!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCellController
        cell.imageView.image = CoreDataStackManager.sharedInstance.imageForCell(selectedPin, id: indexPath.row)
        return cell
    }
    
    func checkWhichPin() {
        let arrayOfExistingPins = CoreDataStackManager.sharedInstance.fetchPins() as [Pin]
        for pin in arrayOfExistingPins {
            if pin.latitude == selectedPinLatitude && pin.longitude == selectedPinLongitude {
                selectedPin = pin
            }
        }
    }
    
    override func viewDidLoad() {
        checkWhichPin()
    }
}





