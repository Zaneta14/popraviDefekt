//
//  RateCraftsmanViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 1/17/21.
//  Copyright © 2021 Zaneta. All rights reserved.
//

import UIKit
import Parse

class RateCraftsmanViewController: UIViewController {
    
    var craftsmanId = String()
    
    @IBOutlet weak var craftsman: UILabel!
    
    @IBOutlet weak var comment: UITextView!
    
    @IBOutlet weak var info1: UILabel!
    
    @IBOutlet weak var info2: UILabel!
    
    @IBOutlet weak var submitO: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        info1.isHidden = true
        info2.isHidden = true
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: craftsmanId)
        query?.findObjectsInBackground(block: { (success, error) in
            if error != nil {
                print("error")
            } else if let objects = success {
                for object in objects {
                    self.craftsman.text = object["firstName"] as! String + " " + (object["lastName"] as! String)
                }
            }
        })
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
                                self.comment.text = comments[i]
                                self.info1.isHidden = false
                                self.info2.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        let comC = comment.text
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
                    }
                    var x = 0
                    if usersArray.count > 0 {
                        let range = 0..<usersArray.count
                        for i in range {
                            if usersArray[i] == PFUser.current()?.objectId {
                                array[i] = comC!
                                x = 1
                                break
                            }
                        }
                    }
                    if x == 0 {
                        array.append(comC as! String)
                        usersArray.append((PFUser.current()?.objectId)!)
                    }
                    object["comments"] = array
                    object["usersWhoCommented"] = usersArray
                    object.saveInBackground()
                }
                self.displayAlert(title: "Thank you for your feedback.", message: "Your information has been submitted")
            }
        })
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }

}
