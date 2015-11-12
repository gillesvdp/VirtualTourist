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
    /***
     
     api_key (Required)
     Your API application key. See here for more details.
     lat (Required)
     The latitude whose valid range is -90 to 90. Anything more than 6 decimal places will be truncated.
     lon (Required)
     The longitude whose valid range is -180 to 180. Anything more than 6 decimal places will be truncated.
     accuracy (Optional)
     Recorded accuracy level of the location information. World level is 1, Country is ~3, Region ~6, City ~11, Street ~16. Current range is 1-16. Defaults to 16 if not specified.
     extras (Optional)
     A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o
     per_page (Optional)
     Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
     page (Optional)
     The page of results to return. If this argument is omitted, it defaults to 1.
     
     ***/
    
    
    // MARK: Reuse identifiers
    let cell = "cell"
    
    // MARK: Segues
    let showPhotoAlbum = "showPhotoAlbum"
    
}