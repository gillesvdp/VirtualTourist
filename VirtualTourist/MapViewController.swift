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
            //CoreDataStackManager.sharedInstance.saveNewAnnotation(pinAnnotation)
            mapView.addAnnotation(pinAnnotation)
        }
    }
    
    // MARK: MapView Delegate
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        //performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: nil)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: nil)
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
        
        for annotation in CoreDataStackManager.sharedInstance.loadAnnotations() {
            mapView.addAnnotation(annotation)
        }
    }
}

