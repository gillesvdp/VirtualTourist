//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Variables
    let flickrApi = FlickrAPI()
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    

    
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
                            var count = 1
                            for url in photoUrlArray! {
                                if let imageData = NSData(contentsOfURL: NSURL(string: url)!) {
                                    
                                    
                                    let imageData = UIImage(data: imageData)
                                    DataBuffer.sharedInstance.imagesArray.append(imageData!)
                                    
                                    
                                    
                                    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                    let context: NSManagedObjectContext = appDel.managedObjectContext
                                    
                                    let imageInCoreData = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context)
                                    
                                    imageInCoreData.setValue(imageData, forKey: "photoData")
                                    
                                    do {
                                        try context.save()
                                    } catch {
                                        print("Error with context")
                                    }
                                    
                                    print("Downloaded image \(count) / \(photoUrlArray!.count)")
                                    count += 1
                                }
                            }
                            print("All images downloaded in dataBuffer")
                            //self.sendDataNotification("imagesReceived")
                            self.performSegueWithIdentifier(ConstantStrings.sharedInsance.showPhotoAlbum, sender: nil)
                        }
                    })
            })

            
            saveNewAnnotation(pinAnnotation)
            
            mapView.addAnnotation(pinAnnotation)
            
        }
    }
    
    func saveNewAnnotation(pinAnnotation: MKAnnotation) {
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let pinInCoreData = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: context)
        
        pinInCoreData.setValue(pinAnnotation.coordinate.longitude, forKey: "longitude")
        pinInCoreData.setValue(pinAnnotation.coordinate.latitude, forKey: "latitude")
        
        do {
            try context.save()
        } catch {
            print("Error with context")
        }
    }
    
    func loadAnnotations() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                
                for pin in results {
                    print(pin)
                    let lat = pin.valueForKey("latitude") as! Double
                    let long = pin.valueForKey("longitude") as! Double
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    mapView.addAnnotation(annotation)
                    
                }
            }
            
            
            
        } catch {
            "error"
        }
        
        
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
        loadAnnotations()
        
        
        
    }



}

