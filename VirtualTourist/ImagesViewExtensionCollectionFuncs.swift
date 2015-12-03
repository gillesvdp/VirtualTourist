//
//  ImagesViewExtensionCollectionFuncs.swift
//  VirtualTourist
//
//  Created by Gilles on 12/2/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import UIKit

extension ImagesViewController {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ImageCell
        cell.photo = photo
        
        if photo.localUrl == nil {
            cell.imageView.image = UIImage(named: "downloading")
            photo.loadUpdateHandler = { [unowned self] () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadItemsAtIndexPaths([indexPath])
                })
            }
        } else {
            photo.loadUpdateHandler = nil
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
        if let btn = self.navigationItem.rightBarButtonItem {
            if btn.title == "Done" {
                selectedIndexes.append(indexPath)
                deleteSelectedPhoto()
            }
            else {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCell
                performSegueWithIdentifier("showDetails", sender: cell)
            }
        }
        
    }
    
}