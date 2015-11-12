//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Variables
    let flickrApi = FlickrAPI()
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPressOutlet: UILongPressGestureRecognizer!
    
    // MARK: Actions
    @IBAction func longPressPressed(sender: AnyObject) {
        longPressOutlet.enabled = false
        longPressOutlet.conformsToProtocol(MKMapViewDelegate)
        let touchPoint = longPressOutlet.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = newCoordinates
        pinAnnotation.title = "Title of annotation"
        
        
        
        flickrApi.getPhotos(pinAnnotation,
            completionHandler: {(photoUrlArray, errorString) -> Void in
                if let _ = errorString {
                    print(errorString!)
                } else {
                    for url in photoUrlArray! {
                        print(url)
                    }
                }
        })
        
        mapView.addAnnotation(pinAnnotation)
    }
    
    
    
    // MARK: MapView Delegate
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        // Load Flickr pictures
        print("Pin was added")
        
        // Move to the next screen
        // performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: nil)
        
    }
    
    // MARK: General functions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConstantStrings.sharedInsance.showPhotoAlbum {
            // Send over the location tapped so the new map can load with this one in focus
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        
    }



}

