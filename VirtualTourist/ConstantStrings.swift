//
//  ConstantStrings.swift
//  VirtualTourist
//
//  Created by Gilles on 11/11/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

class ConstantStrings {
    
    static var sharedInsance = ConstantStrings()
    
    // FlickrAPI
    let flickrApiKey = "bac3739624ae24f96dc1242f6be2b676"
    let flickrApiSecret = "5a0b10934fa565e7"
    let flickrUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    let flickrRequestDetails = "/flickr.photos.geo.photosForLocation"
    
    // MARK: Reuse identifiers
    let cell = "cell"
    
    // MARK: Segues
    let showPhotoAlbum = "showPhotoAlbum"
}