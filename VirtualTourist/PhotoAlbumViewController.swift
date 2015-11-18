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

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCellController
        cell.imageView.image = CoreDataStackManager.sharedInstance.imageForCell(indexPath.row)
        return cell
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreDataStackManager.sharedInstance.countCells()
    }
}





