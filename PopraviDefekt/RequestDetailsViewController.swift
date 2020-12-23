//
//  RequestDetailsViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/22/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class RequestDetailsViewController: UIViewController {
    
    var craftsmanId = String()
    
    var descr = String()
    
    var dateReq = NSDate()
    
    var statusS = String()
    
    var dateFinished = NSDate()
    
    var imageFile = [PFFileObject]()
    
    @IBOutlet weak var requestDate: UILabel!
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var flName: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var pDate: UILabel!
    
    @IBOutlet weak var pPrice: UILabel!
    
    @IBOutlet weak var pd: UILabel!
    
    @IBOutlet weak var pp: UILabel!
    
    @IBOutlet weak var scheduledOn: UILabel!
    
    @IBOutlet weak var schDate: UILabel!
    
    @IBOutlet weak var imageV: UIImageView!

    @IBOutlet weak var rejectCancelO: UIButton!
    
    @IBOutlet weak var acceptO: UIButton!
    
    var datumiB = [NSDate]()
    
    var craftsmenIds = [String]()
    
    var statuses = [String]()
    
    var descriptions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        desc.text = descr
        //requestDate.text = dateReq
        status.text = statusS
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: craftsmanId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                print("nema error")
                for object in objects {
                    if let craftsman = object as? PFUser {
                        if let firstName = craftsman["firstName"] {
                            if let lastName = craftsman["lastName"] {
                                print(lastName)
                                if let phoneNumber = craftsman["phoneNumber"] {
                                    print(phoneNumber)
                                    if let mailAddr = craftsman.username {
                                        if let craft = craftsman["craft"] {
                                            self.flName.text = (firstName as! String) + " " + (lastName as! String)
                                            self.type.text = (craft as! String)
                                            self.email.text = mailAddr + " " + (phoneNumber as! String)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        if statusS == "active" {
            pDate.isHidden = true
            pPrice.isHidden = true
            pd.isHidden = true
            pp.isHidden = true
            scheduledOn.isHidden = true
            schDate.isHidden = true
            imageV.isHidden = true
            acceptO.isHidden = true
            rejectCancelO.setTitle(" Cancel ", for: .normal)
            rejectCancelO.isHidden = false
        }
        else if statusS == "pending" {
            pDate.isHidden = false
            pPrice.isHidden = false
            pd.isHidden = false
            pp.isHidden = false
            acceptO.isHidden = false
            rejectCancelO.setTitle("Reject", for: .normal)
            rejectCancelO.isHidden = false
            imageV.isHidden = true
            scheduledOn.isHidden = true
            schDate.isHidden = true
        } else if statusS == "scheduled" {
            pDate.isHidden = true
            pPrice.isHidden = true
            pd.isHidden = true
            pp.isHidden = true
            scheduledOn.text = "Scheduled on:"
            scheduledOn.isHidden = false
            schDate.isHidden = false
            imageV.isHidden = true
            acceptO.isHidden = true
            rejectCancelO.isHidden = true
        } else if statusS == "done" {
            pDate.isHidden = true
            pPrice.isHidden = true
            pd.isHidden = true
            pp.isHidden = true
            scheduledOn.text = "Done on:"
            scheduledOn.isHidden = false
            schDate.isHidden = false
            imageV.isHidden = false
            acceptO.isHidden = true
            rejectCancelO.isHidden = true
        }
    }
    
    
    @IBAction func accept(_ sender: Any) {
        
    }
    
    @IBAction func rejectCancel(_ sender: Any) {
        if statusS == "active" {
            print("active")
            let query = PFQuery(className: "Job")
            query.whereKey("from", equalTo: PFUser.current()?.objectId)
            query.whereKey("to", equalTo: craftsmanId)
            query.whereKey("description", equalTo: descr)
            query.whereKey("date", equalTo: dateReq)
            print("query")
            query.findObjectsInBackground(block:  { (objects, error) in
                if error != nil {
                    print("error")
                    print(error?.localizedDescription)
                } else if let objects = objects {
                    print("da")
                    for object in objects {
                        print("delete")
                        object.deleteInBackground()
                    }
                }
            })
            displayAlert(title: "Success", message: "The request has been canceled.")
        }
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }

}
