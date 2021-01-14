//
//  RequestDetailsViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/22/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class RequestDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    var craftsmanId = String()
    
    var descr = String()
    
    var dateReq = NSDate()
    
    var statusS = String()
    
    var dateFinished = NSDate()
    
    var beforeImg = [PFFileObject]()
    
    var afterImg = [PFFileObject]()
    
    var propDate = NSDate()
    
    var propPrice = String()
    
    var scheduledDate = NSDate()
    
    @IBOutlet weak var requestDate: UILabel!
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var flName: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var pDate: UILabel!
    
    @IBOutlet weak var pPrice: UILabel!
    
    @IBOutlet weak var pd: UILabel!
    
    @IBOutlet weak var pp: UILabel!
    
    @IBOutlet weak var scheduledOn: UILabel!
    
    @IBOutlet weak var schDate: UILabel!
    
    @IBOutlet weak var desc: UITextView!
    
    @IBOutlet weak var email: UIButton!
    
    @IBOutlet weak var phoneNumber: UIButton!
    
    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var rejectCancelO: UIButton!
    
    @IBOutlet weak var acceptO: UIButton!
    
    @IBOutlet weak var afterPhoto: UIButton!
    var datumiB = [NSDate]()
    
    var craftsmenIds = [String]()
    
    var statuses = [String]()
    
    var descriptions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        desc.text = "\"" + descr + "\""
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let stringDate = formatter.string(from: dateReq as Date)
        requestDate.text = stringDate
        status.text = statusS
        let slikaPred = beforeImg[0]
        slikaPred.getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageToDisplay = UIImage(data: imageData) {
                    self.imageV.image = imageToDisplay
                }
            }
        }
        beforeImg.removeAll()
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: craftsmanId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let craftsman = object as? PFUser {
                        if let firstName = craftsman["firstName"] {
                            if let lastName = craftsman["lastName"] {
                                if let phoneNumber = craftsman["phoneNumber"] {
                                    if let mailAddr = craftsman.username {
                                        if let crafts = craftsman["crafts"] {
                                            let query = PFQuery(className: "CraftsmanType")
                                            query.findObjectsInBackground { (success, error) in
                                                if error != nil {
                                                    print(error?.localizedDescription)
                                                } else if let objects = success {
                                                    self.flName.text = (firstName as! String) + " " + (lastName as! String)
                                                    self.phoneNumber.setTitle(phoneNumber as! String, for: .normal)
                                                    self.email.setTitle(mailAddr, for: .normal)
                                                    var niza = [String]()
                                                    for object in objects {
                                                        for craft in crafts as! [String] {
                                                            if object.objectId == craft {
                                                                niza.append(object["eng"] as! String)
                                                            }
                                                        }
                                                    }
                                                    self.type.text = niza.joined(separator: ", ")
                                                }
                                            }
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
            imageV.isHidden = false
            acceptO.isHidden = true
            rejectCancelO.setTitle(" Cancel ", for: .normal)
            rejectCancelO.isHidden = false
            afterPhoto.isHidden = true
        }
        else if statusS == "pending" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let stringDate = dateFormatter.string(from: propDate as Date)
            pDate.text = stringDate
            pPrice.text = propPrice
            pDate.isHidden = false
            pPrice.isHidden = false
            pd.isHidden = false
            pp.isHidden = false
            acceptO.isHidden = false
            rejectCancelO.setTitle("Reject", for: .normal)
            rejectCancelO.isHidden = false
            imageV.isHidden = false
            scheduledOn.isHidden = true
            schDate.isHidden = true
            afterPhoto.isHidden = true
        } else if statusS == "scheduled" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let stringDate = dateFormatter.string(from: propDate as Date)
            schDate.text = stringDate
            pDate.isHidden = true
            pPrice.isHidden = true
            pd.isHidden = true
            pp.isHidden = true
            scheduledOn.text = "Scheduled on:"
            scheduledOn.isHidden = false
            schDate.isHidden = false
            imageV.isHidden = false
            acceptO.isHidden = true
            afterPhoto.isHidden = true
            rejectCancelO.isHidden = true
        } else if statusS == "done" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let stringDate = dateFormatter.string(from: dateFinished as Date)
            schDate.text = stringDate
            afterPhoto.isHidden = false
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
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: craftsmanId)
        query.whereKey("description", equalTo: descr)
        query.whereKey("date", equalTo: dateReq)
        query.findObjectsInBackground(block:  { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    object["status"] = "scheduled"
                    object.saveInBackground()
                }
            }
        })
        displayAlert(title: "Success", message: "The job is now scheduled.")
    }
    
    @IBAction func rejectCancel(_ sender: Any) {
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: craftsmanId)
        query.whereKey("description", equalTo: descr)
        query.whereKey("date", equalTo: dateReq)
        query.findObjectsInBackground(block:  { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    object.deleteInBackground()
                }
            }
        })
        if statusS == "active" {
            displayAlert(title: "Success", message: "The request has been canceled.")
        } else {
            displayAlert(title: "Success", message: "The offer has been rejected.")
        }
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    @IBAction func makeACall(_ sender: Any) {
        var phone = phoneNumber.titleLabel?.text
        if let url = URL(string: "tel://\(phone!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func sendAnEmail(_ sender: Any) {
        var emailA = email.titleLabel?.text
        if let url = URL(string: "mailto:\(emailA!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "afterPhotoSegue" {
            let dvc = segue.destination as! PopUpViewController
            dvc.imageFile = afterImg
        }
    }
}
