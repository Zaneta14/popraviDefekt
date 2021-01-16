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
    
    @IBOutlet weak var commentCraftsman: UITextView!
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
        let q = PFQuery(className: "CommentCraftsman")
        q.whereKey("userId", equalTo: craftsmanId)
        q.whereKey("usersWhoCommented", contains: PFUser.current()?.objectId)
        q.findObjectsInBackground { (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = success {
                if objects.count > 0 {
                    for object in objects {
                        let users = object["usersWhoCommented"] as! [String]
                        let comments = object["comments"] as! [String]
                        let range = 0..<users.count
                        for i in range {
                            if users[i] == PFUser.current()?.objectId {
                                self.commentCraftsman.text = comments[i]
                                self.commentCraftsman.isEditable = false
                            }
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
        if commentJob.text != "" && commentJob.text != "Your comment here..." && commentCraftsman.text != "" && commentCraftsman.text != "Your comment here..." {
            let comJ = commentJob.text
            let ratingR = Int(stepperO.value)
            let comC = commentCraftsman.text
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
            let comQuery = PFQuery(className: "CommentCraftsman")
            comQuery.whereKey("userId", equalTo: craftsmanId)
            comQuery.findObjectsInBackground(block: { (success, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let objects = success {
                    for object in objects {
                        var array = [String]()
                        var usersArray = [String]()
                        if let comments = object["comments"] {
                            if let usersWhoCommented = object["usersWhoCommented"] {
                                print("ima komentar")
                                array = comments as! [String]
                                usersArray = usersWhoCommented as! [String]
                            }
                        } else {
                            print("nema komentar")
                            //var array = [String]()
                        }
                        array.append(comC as! String)
                        usersArray.append((PFUser.current()?.objectId)!)
                        object["comments"] = array
                        object["usersWhoCommented"] = usersArray
                        object.saveInBackground()
                    }
                    self.displayAlert(title: "Thank you for your feedback.", message: "Your information has been submitted")
                }
            })
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
