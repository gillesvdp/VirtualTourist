//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Variables
    let defaults = NSUserDefaults()
    let flickrApi = FlickrAPI()
    var selectedPin: Pin?
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPressOutlet: UILongPressGestureRecognizer!
    
    // MARK: Actions
    @IBAction func longPressPressed(sender: UILongPressGestureRecognizer) {
        if ConstantStrings.sharedInstance.downloadingStatus == true {
            let alert = UIAlertController(title: "Warning", message: "The app is still downloading pictures. Please wait until all pictures are downloaded before adding a new location to the map.", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            if sender.state == UIGestureRecognizerState.Began {
                longPressOutlet.enabled = false
                longPressOutlet.conformsToProtocol(MKMapViewDelegate)
                let touchPoint = longPressOutlet.locationInView(mapView)
                let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                
                let pinAnnotation = MKPointAnnotation()
                pinAnnotation.coordinate = newCoordinates
                let newPin = CoreDataStackManager.sharedInstance.saveNewPin(pinAnnotation.coordinate.longitude, newPinLatitude: pinAnnotation.coordinate.latitude)
                selectedPin = newPin
                mapView.addAnnotation(pinAnnotation)
                downloadPhotos(newPin)
                ConstantStrings.sharedInstance.downloadingStatus = true
                performSegueWithIdentifier(ConstantStrings.sharedInstance.showImageCollection, sender: nil)
            }
        }
    }
    
    // MARK: MapView Delegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? MapCustomPin {
            self.selectedPin = annotation.pin
        }
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showImageCollection, sender: view)
    }
    
    
    
    // MARK: General functions
    
    func downloadPhotos(selectedPin: Pin) {
        flickrApi.getPhotos(selectedPin.latitude as! Double, pinLongitude: selectedPin.longitude as! Double, pageNumber: nil,
            completionHandler: {(photoUrlArray, errorString) -> Void in
                guard errorString == nil else {
                    print(errorString)
                    return
                }
                CoreDataStackManager.sharedInstance.downloadAndSavePhotos(selectedPin, photoUrlArray: photoUrlArray!)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConstantStrings.sharedInstance.showImageCollection {
            let destinationVC = segue.destinationViewController as! ImagesViewController
            destinationVC.selectedPin = selectedPin
        }
    }
}

