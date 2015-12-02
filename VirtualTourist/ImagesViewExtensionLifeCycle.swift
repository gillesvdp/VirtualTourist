//
//  ImagesViewExtensionLifeCycle.swift
//  VirtualTourist
//
//  Created by Gilles on 12/2/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import MapKit


extension ImagesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editBtnPressed")
        
        mapView.delegate = self
        
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        let space: CGFloat = 2.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        fetchedResultsController.delegate = self
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let _ = selectedPin else {
            // Unexpected error: no pin was sent to this view controller.
            self.showAlertViewController("Error", errorMessage: "Please go back to the map and try again with another pin.")
            return
        }
        
        deleteInstructionLabel.hidden = true
        
        // Set region of the mapView
        let lat = selectedPin!.latitude as! Double
        let long = selectedPin!.longitude as! Double
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
            
        let center = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
        let span = MKCoordinateSpan(
            latitudeDelta: 0.2,
            longitudeDelta: 0.2
        )
        mapView.region = MKCoordinateRegion(center: center, span: span)
        
        // Launch Fetched Results Controller
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        // NSNotificationCenter
        notificationCenter.addObserverForName("downloadedOnePhoto", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {_ in
            if let _ = self.navigationItem.rightBarButtonItem {
                self.navigationItem.rightBarButtonItem!.enabled = false
            }
            self.bottomBtnOutlet.enabled = false
            self.bottomBtnOutlet.title = "Downloading photos (\(ConstantStrings.sharedInstance.imagesDownloaded) / \(ConstantStrings.sharedInstance.totalImagesToDownload))"
        })
        notificationCenter.addObserverForName("finishedDownloadingPhotos", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {_ in
            if let _ = self.navigationItem.rightBarButtonItem {
                self.navigationItem.rightBarButtonItem!.enabled = true
            }
            self.bottomBtnOutlet.title = "New collection"
            self.bottomBtnOutlet.enabled = true
        })
        
        // Automatically download photos if no photos associated with the Pin are stored locally
        if ConstantStrings.sharedInstance.downloadingStatus == true {
            if let _ = self.navigationItem.rightBarButtonItem {
                self.navigationItem.rightBarButtonItem!.enabled = false
            }
            self.bottomBtnOutlet.enabled = false
            self.bottomBtnOutlet.title = "Downloading photos"
        } else {
            if let _ = self.navigationItem.rightBarButtonItem {
                self.navigationItem.rightBarButtonItem!.enabled = true
            }
            self.bottomBtnOutlet.enabled = true
            self.bottomBtnOutlet.title = "New collection"
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self)
    }
}