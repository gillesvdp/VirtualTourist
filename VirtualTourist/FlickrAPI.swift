//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import MapKit

class FlickrAPI : NSObject, MKMapViewDelegate{
    
    func getPhotosUsingCompletionHandler(pin: MKAnnotation,
        completionHandler: (errorString: String?) -> Void) {
            
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        let flickrSearchURL = "\(ConstantStrings.flickrUrl)&api_key=\(ConstantStrings.flickrApiKey)"
        let request = NSMutableURLRequest(URL: NSURL(string: flickrSearchURL)!)
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if let _ = error {
                completionHandler(errorString: "Check your network")
                
            } else {
                var error: NSError?
                let result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary?
                if let result = result {
                    if let dictResult = result["photos"] as! NSDictionary? {
                        if let totalPages = dictResult["pages"] as? Int {
                            let pageLimit = min(totalPages, 40)
                            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                            self.getPhotosWithPageUsingCompletionHandler(pin, pageNumber: randomPage, completionHandler: completionHandler)
                        }
                    }
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }
}
