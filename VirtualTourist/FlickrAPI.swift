//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

class FlickrAPI : NSObject {
    
    func getPhotos(pinLatitude: Double, pinLongitude: Double, pageNumber: Int?,
        completionHandler: (photoUrlArray: [String]?, errorString: String?) -> Void) {
            
            let bbox = createBoundingBoxString(pinLatitude, longitude: pinLongitude)
            
            var selectedPage = Int()
            var flickrSearchUrl = String()
            
            if pageNumber == nil {
                // We will use this Url to get the number of pages available.
                flickrSearchUrl = "\(ConstantStrings.sharedInstance.flickrUrl)&api_key=\(ConstantStrings.sharedInstance.flickrApiKey)&bbox=\(bbox)&format=json&nojsoncallback=1&per_page=50"
            } else {
                // We will specify which page to access in the api url request.
                selectedPage = pageNumber!
                flickrSearchUrl = "\(ConstantStrings.sharedInstance.flickrUrl)&api_key=\(ConstantStrings.sharedInstance.flickrApiKey)&bbox=\(bbox)&format=json&nojsoncallback=1&page=\(selectedPage)&per_page=50"
            }
            
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
                    
                    if pageNumber == nil {
                        // First call of the function (#1)
                        // The function was just called, so no pageNumber was supplied. We will parse the total number of pages, and choose a random pageNumber based on the FlickrAPI constraints (max page 40 is accessible).
                        let numberOfPages = parsedResult!["photos"]!["pages"] as! Int
                        let pageLimit = min(numberOfPages, 40)
                        let randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        
                        // Calling the function again, this time specifying which page to access in the JSON result.
                        self.getPhotos(pinLatitude, pinLongitude: pinLongitude, pageNumber: randomPageNumber,
                            completionHandler: {(photoUrlArray, errorString) -> Void in
                                guard errorString == nil else {
                                    print(errorString)
                                    return
                                }
                                // #2 has finished its work, and sent us back the photoUrlArray (or error)
                                completionHandler(photoUrlArray: photoUrlArray, errorString: nil)
                        })
                        
                    } else {
                        // Secund call of the function (#2)
                        // We are accessing a selected page, and creating the urlArray for all the images on the page.
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
                        // PhotoUrlArray is now complete, let's send it back to #1.
                        completionHandler(photoUrlArray: photoUrlArray, errorString: nil)
                    }
                } catch {
                    completionHandler(photoUrlArray: nil, errorString: "Error parsing the data")
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
