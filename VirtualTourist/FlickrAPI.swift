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
    
    func getPhotos(pin: MKAnnotation,
        completionHandler: (photoUrlArray: [String]?, errorString: String?) -> Void) {
            
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        let bbox = createBoundingBoxString(latitude, longitude: longitude)
            
        let flickrSearchUrl = "\(ConstantStrings.sharedInsance.flickrUrl)&api_key=\(ConstantStrings.sharedInsance.flickrApiKey)&bbox=\(bbox)&format=json&nojsoncallback=1"
            
        let request = NSMutableURLRequest(URL: NSURL(string: flickrSearchUrl)!)
            
        let session = NSURLSession.sharedSession()
            
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            guard (error == nil) else {
                completionHandler(photoUrlArray: nil, errorString: "Connection error")
                return
            }
            
            let parsedResult : [String: AnyObject]?
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject]
                
                let photoDictionary = parsedResult!["photos"]!["photo"] as! NSArray
                var photoUrlArray = [String]()
                var x = 0
                
                for _ in photoDictionary {
                    let farm = parsedResult!["photos"]!["photo"]!![x]["farm"] as! NSNumber
                    let server = parsedResult!["photos"]!["photo"]!![x]["server"] as! String
                    let id = parsedResult!["photos"]!["photo"]!![x]["id"] as! String
                    let secret = parsedResult!["photos"]!["photo"]!![x]["secret"] as! String
                    x += 1
                    photoUrlArray.append(self.getPhotoURL(id, farm: farm, server: server, secret: secret))
                }
                completionHandler(photoUrlArray: photoUrlArray, errorString: nil)
                
            } catch {
                parsedResult = nil
                print("Try again of contact our team")
                completionHandler(photoUrlArray: nil, errorString: "Try again or contact our team")
            }
            
           
        }
        task.resume()
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        let bounding_box_half_width = 0.2
        let bounding_box_half_height = 0.2
        let lat_min = -90.0
        let lat_max = 90.0
        let lon_min = -180.0
        let lon_max = 180.0
        let bottom_left_lon = max(longitude - bounding_box_half_width, lon_min)
        let bottom_left_lat = max(latitude - bounding_box_half_height, lat_min)
        let top_right_lon = min(longitude + bounding_box_half_width, lon_max)
        let top_right_lat = min(latitude + bounding_box_half_height, lat_max)
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    
    func getPhotoURL(id: String, farm: NSNumber, server: String, secret: String) -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
    
}
