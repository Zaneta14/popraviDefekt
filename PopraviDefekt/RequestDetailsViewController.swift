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
    
    var jobId = String()
    
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
    
    @IBOutlet weak var rate: UIBarButtonItem!
    
    @IBOutlet weak var rateC: UIBarButtonItem!
    
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
            rate.isEnabled = false
            rateC.isEnabled = false
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
            acceptO.setTitle(" Accept ", for: .normal)
            acceptO.isHidden = false
            rejectCancelO.setTitle(" Reject ", for: .normal)
            rejectCancelO.isHidden = false
            imageV.isHidden = false
            scheduledOn.isHidden = true
            schDate.isHidden = true
            afterPhoto.isHidden = true
            rate.isEnabled = false
            rateC.isEnabled = false
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
            rate.isEnabled = false
            rateC.isEnabled = false
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
            rate.isEnabled = true
            rateC.isEnabled = true
        } else if statusS == "done (pending)" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let stringDate = dateFormatter.string(from: dateFinished as Date)
            schDate.text = stringDate
            afterPhoto.isHidden = false
            pDate.isHidden = true
            pPrice.isHidden = true
            pd.isHidden = true
            pp.text = "Is the information below valid?"
            pp.isHidden = false
            scheduledOn.text = "Done on:"
            scheduledOn.isHidden = false
            schDate.isHidden = false
            imageV.isHidden = false
            acceptO.setTitle(" Yes ", for: .normal)
            rejectCancelO.setTitle(" No ", for: .normal)
            acceptO.isHidden = false
            rejectCancelO.isHidden = false
            rate.isEnabled = false
            rateC.isEnabled = false
        }
    }
    
    
    @IBAction func accept(_ sender: Any) {
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: craftsmanId)
        query.whereKey("description", equalTo: descr)
        query.whereKey("date", equalTo: dateReq)
        if statusS == "pending" {
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
        else {
            query.findObjectsInBackground(block:  { (objects, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let objects = objects {
                    for object in objects {
                        object["status"] = "done"
                        object.saveInBackground()
                    }
                }
            })
            displayAlert(title: "Success", message: "The job is now finished.")
        }
    }
    
    @IBAction func rejectCancel(_ sender: Any) {
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: craftsmanId)
        query.whereKey("description", equalTo: descr)
        query.whereKey("date", equalTo: dateReq)
        if statusS != "done (pending)" {
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
            } else if statusS == "pending" {
                displayAlert(title: "Success", message: "The offer has been rejected.")
            }
        }
        else {
            query.findObjectsInBackground(block:  { (objects, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let objects = objects {
                    for object in objects {
                        object["status"] = "scheduled"
                        if let times = object["timesDeclaredInvalid"] {
                            var t = times as! Int
                            t += 1
                            object["timesDeclaredInvalid"] = t
                        } else {
                            object["timesDeclaredInvalid"] = 1
                        }
                        object.saveInBackground()
                    }
                }
            })
            displayAlert(title: "Success", message: "You have declared the craftsman's information invalid.")
        }
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertOKaction) in
            self.popThisView()
        }))
        present(allertController, animated: true, completion: nil)
    }
    
    func popThisView() {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is RequestsJobsTableViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
    
    @IBAction func makeACall(_ sender: Any) {
        var phone = phoneNumber.titleLabel?.text
        if let url = URL(string: "tel://\(phone!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func sendAnEmail(_ sender: Any) {
        let emailA = email.titleLabel?.text
        if let url = URL(string: "mailto:\(emailA!)") { 
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "afterPhotoSegue" {
            let dvc = segue.destination as! PopUpViewController
            dvc.imageFile = afterImg
        }
        else if segue.identifier == "rateSegue" {
            let dvc = segue.destination as! RateJobViewController
            dvc.jobId = jobId
            dvc.craftsmanId = craftsmanId
        }
        else if segue.identifier == "rateCSegue" {
            let dvc = segue.destination as! RateCraftsmanViewController
            dvc.craftsmanId = craftsmanId
        }
    }
}
