//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UICollectionViewController {

    var  texts = ["1", "2", "3"]
    

    // MARK: IBOutlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I am loaded")
        
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 2.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension * 2)
        flowLayout.scrollDirection = .Vertical
        
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
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCellController
        
        
        cell.imageView.image = retrieveImages(indexPath.row)
        
        
        //cell.imageView.image = DataBuffer.sharedInstance.imagesArray[indexPath.row]
        
        //cell.label.text = texts[indexPath.row]
        //cell.backgroundColor = UIColor.redColor()
        //print(DataBuffer.sharedInstance.imagesArray[indexPath.row])
        return cell
    }
    
    func retrieveImages(variable: Int) -> UIImage {
        var finalResult = UIImage()
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Photo")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                let image = results[variable].valueForKey("photoData") as! UIImage
                finalResult = image
            }
        } catch {
            print("error 2")
        }
        return finalResult

    }
}






