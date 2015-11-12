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
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
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
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if let _ = errorString {
                        print(errorString!)
                        
                    } else {
                        var count = 1
                        for url in photoUrlArray! {
                            if let imageData = NSData(contentsOfURL: NSURL(string: url)!) {
                                let imageData = UIImage(data: imageData)
                                DataBuffer.sharedInstance.imagesArray.append(imageData!)
                                print("Downloading image \(count) / \(photoUrlArray!.count)")
                                count += 1
                            }
                        }
                        print("All images downloaded in dataBuffer")
                        //self.sendDataNotification("imagesReceived")
                        self.performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: nil)
                    }
                })
        })
        
        
        mapView.addAnnotation(pinAnnotation)
    }
    
    
    private func sendDataNotification(notificationName: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }
    
    
    // MARK: MapView Delegate
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        //performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: nil)
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

