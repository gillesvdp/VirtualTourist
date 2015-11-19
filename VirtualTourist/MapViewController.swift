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
        if sender.state == UIGestureRecognizerState.Began {
            longPressOutlet.enabled = false
            longPressOutlet.conformsToProtocol(MKMapViewDelegate)
            let touchPoint = longPressOutlet.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = newCoordinates
            mapView.addAnnotation(pinAnnotation)
            
            flickrApi.getPhotos(pinAnnotation,
                completionHandler: {(photoUrlArray, errorString) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if let _ = errorString {
                            print(errorString!)
                        } else {
                            CoreDataStackManager.sharedInstance.downloadAndSavePhotos(pinAnnotation, photoUrlArray: photoUrlArray!)
                        }
                    })
            })
        }
    }
    
    // MARK: MapView Delegate
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        //performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: nil)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: view)
    }
    
    // MARK: General functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConstantStrings.sharedInsance.showPhotoAlbum {
            let destinationVC = segue.destinationViewController as! PhotoAlbumViewController
            if let selectedPin = sender as? MKAnnotationView {
                destinationVC.selectedPinLongitude = (selectedPin.annotation?.coordinate.longitude)!
                destinationVC.selectedPinLatitude = (selectedPin.annotation?.coordinate.latitude)!
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
}

