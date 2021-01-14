//
//  PopUpViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 1/13/21.
//  Copyright © 2021 Zaneta. All rights reserved.
//

import UIKit
import Parse

class PopUpViewController: UIViewController {
    
    var imageFile = [PFFileObject]()
    
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageFile[0].getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageToDisplay = UIImage(data: imageData) {
                    self.imageView.image = imageToDisplay
                }
            }
        }
        
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
    }
    
    
    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
