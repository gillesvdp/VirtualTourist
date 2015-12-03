//
//  MapViewExtensionLifeCycle.swift
//  VirtualTourist
//
//  Created by Gilles on 12/2/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        longPressOutlet.enabled = true
        
        let arrayOfExistingPins = CoreDataStackManager.sharedInstance.fetchPins()
        var arrayOfAnnotations = [MKAnnotation]()
        if arrayOfExistingPins.count > 0 {
            for pin in arrayOfExistingPins {
                let lat = pin.latitude 
                let long = pin.longitude
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MapCustomPin()
                annotation.coordinate = coordinate
                annotation.pin = pin
                
                arrayOfAnnotations.append(annotation)
            }
        }
        mapView.addAnnotations(arrayOfAnnotations)
        
        if let _ = defaults.valueForKey("mapViewRegion") {
            let mapViewRegion = defaults.valueForKey("mapViewRegion") as! [String: Double]
            let center = CLLocationCoordinate2D(
                latitude: mapViewRegion["latitude"]!,
                longitude: mapViewRegion["longitude"]!
            )
            let span = MKCoordinateSpan(
                latitudeDelta: mapViewRegion["latitudeDelta"]!,
                longitudeDelta: mapViewRegion["longitudeDelta"]!
            )
            mapView.region = MKCoordinateRegion(center: center, span: span)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        defaults.setValue([
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
            ],
            forKey: "mapViewRegion")
    }
}