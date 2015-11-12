//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UICollectionViewController, MKMapViewDelegate {

    var  texts = ["1", "2", "3"]
    
    // MARK: IBOutlets
    
   
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I am loaded")
        
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        //flowLayout.minimumInteritemSpacing = space
        //flowLayout.itemSize = CGSizeMake(dimension, dimension * 2)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imagesReceived", name: "imagesReceived", object: nil)
    }

    func imagesReceived() {
        collectionView!.reloadData()
    }
   
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print("numberOfSectionsInCollectionView")
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection")
        return DataBuffer.sharedInstance.imagesArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) 
        //cell.label.text = texts[indexPath.row]
        //cell.backgroundColor = UIColor.redColor()
        print(DataBuffer.sharedInstance.imagesArray[indexPath.row])
        return cell
    }
}