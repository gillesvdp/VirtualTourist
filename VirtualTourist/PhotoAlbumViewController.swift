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

    let context = CoreDataStackManager.sharedInstance.sharedContext
    
    
    // MARK: IBOutlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCellController
        
        let request = NSFetchRequest(entityName: "Photo")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            let photoLocalUrl = results[indexPath.row].valueForKey("photoLocalUrl") as! String
            let imageData = UIImage(data: (NSKeyedUnarchiver.unarchiveObjectWithFile(photoLocalUrl) as! NSData))
            cell.imageView.image = imageData
        } catch {
            print("error accessing hard core data")
        }
        return cell
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var solution = Int()
        
        let request = NSFetchRequest(entityName: "Photo")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            solution = results.count
        } catch {
            print("error accessing hard core data")
        }
        return solution
    }
}





