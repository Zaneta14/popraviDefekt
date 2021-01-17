//
//  RateJobViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 1/16/21.
//  Copyright © 2021 Zaneta. All rights reserved.
//

import UIKit
import Parse

class RateJobViewController: UIViewController {
    
    var jobId = String()
    
    var craftsmanId = String()

    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var stepperO: UIStepper!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var commentJob: UITextView!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        info.isHidden = true
        let query = PFQuery(className: "Job")
        query.whereKey("objectId", equalTo: jobId)
        query.findObjectsInBackground { (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = success {
                for object in objects {
                    if let commentJ = object["comment"] {
                        if let ratingR = object["rating"] {
                            self.commentJob.text = commentJ as! String
                            self.commentJob.isEditable = false
                            self.rating.text = String(ratingR as! Int)
                            self.stepperO.isEnabled = false
                            self.submitButton.isEnabled = false
                            self.info.isHidden = false
                        }
                    }
                }
            }
        }
    }

    @IBAction func stepper(_ sender: UIStepper) {
        print(sender.value)
        rating.text = String(Int(sender.value))
    }
    
    @IBAction func submit(_ sender: Any) {
        if commentJob.text != "" && commentJob.text != "Your comment here..." {
            let comJ = commentJob.text
            let ratingR = Int(stepperO.value)
            let query = PFQuery(className: "Job")
            query.whereKey("objectId", equalTo: jobId)
            query.findObjectsInBackground { (success, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let objects = success {
                    for object in objects {
                        object["comment"] = comJ
                        object["rating"] = ratingR
                        object.saveInBackground()
                    }
                }
            }
        } else {
            displayAlert(title: "Invalid", message: "Please fill out the required text fields.")
        }
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
}
