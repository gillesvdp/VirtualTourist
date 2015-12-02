//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by Gilles on 12/2/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var photo: Photo?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = photo {
            if let completeLocalUrl = photo!.completeLocalUrl() {
                if let imageData = NSData(contentsOfFile: completeLocalUrl) {
                    if let image = UIImage(data: imageData) {
                        imageView.image = image
                    }
                }
            }
        }
    }
}
