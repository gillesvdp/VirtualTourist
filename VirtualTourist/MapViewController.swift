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
    let flickrApi = FlickrAPI()
    
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
                mapView.addAnnotation(pinAnnotation)
                downloadPhotos(newPin)
                ConstantStrings.sharedInstance.downloadingStatus = true
            }
        }
    }
    
    // MARK: MapView Delegate
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showImageCollection, sender: views.last)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showImageCollection, sender: view)
    }
    
    // MARK: General functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConstantStrings.sharedInstance.showImageCollection {
            let destinationVC = segue.destinationViewController as! ImagesViewController
            if let selectedPin = sender as? MKAnnotationView {
                
                // Define selectedPin
                let selectedPinLongitude = (selectedPin.annotation?.coordinate.longitude)!
                let selectedPinLatitude = (selectedPin.annotation?.coordinate.latitude)!
                let arrayOfExistingPins = CoreDataStackManager.sharedInstance.fetchPins() as [Pin]
                print(arrayOfExistingPins.count)
                for pin in arrayOfExistingPins {
                    if pin.latitude == selectedPinLatitude && pin.longitude == selectedPinLongitude {
                        destinationVC.selectedPin = pin
                    }
                }
                
                // Inform of download status
                destinationVC.downloadingPictures = ConstantStrings.sharedInstance.downloadingStatus
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let arrayOfExistingPins = CoreDataStackManager.sharedInstance.fetchPins()
        print("There are \(arrayOfExistingPins.count) annotations")
        
        // Transforming Pins into MKAnnotations.
        var arrayOfAnnotations = [MKAnnotation]()
        if arrayOfExistingPins.count > 0 {
            for pin in arrayOfExistingPins {
                let lat = pin.latitude as! Double
                let long = pin.longitude as! Double
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                arrayOfAnnotations.append(annotation)
            }
        }
        mapView.showAnnotations(arrayOfAnnotations, animated: true)
        mapView.addAnnotations(arrayOfAnnotations)
    }
    
    override func viewWillAppear(animated: Bool) {
        longPressOutlet.enabled = true
    }
    
    func downloadPhotos(selectedPin: Pin) {
        flickrApi.getPhotos(selectedPin.latitude as! Double, pinLongitude: selectedPin.longitude as! Double,
            completionHandler: {(photoUrlArray, errorString) -> Void in
                guard errorString == nil else {
                    print(errorString)
                    return
                }
                CoreDataStackManager.sharedInstance.downloadAndSavePhotos(selectedPin, photoUrlArray: photoUrlArray!)
        })
    }
    
}

