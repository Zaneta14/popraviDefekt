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
    
    @IBOutlet weak var afterPLabel: UILabel!
    
    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var rejectCancelO: UIButton!
    
    @IBOutlet weak var acceptO: UIButton!
    
    @IBOutlet weak var beforePhoto: UIButton!
    
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
        status.text = NSLocalizedString(statusS, comment: "")
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: craftsmanId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error!)
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
                                                    print(error!)
                                                } else if let objects = success {
                                                    self.flName.text = (firstName as! String) + " " + (lastName as! String)
                                                    self.phoneNumber.setTitle(phoneNumber as? String, for: .normal)
                                                    self.email.setTitle(mailAddr, for: .normal)
                                                    var niza = [String]()
                                                    for object in objects {
                                                        for craft in crafts as! [String] {
                                                            if object.objectId == craft {
                                                                niza.append(NSLocalizedString(object["eng"] as! String, comment: ""))
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
            imageV.isHidden = true
            acceptO.isHidden = true
            let cancelS = NSLocalizedString("cancelS", comment: "")
            rejectCancelO.setTitle(cancelS, for: .normal)
            rejectCancelO.isHidden = false
            beforePhoto.isHidden = false
            afterPLabel.isHidden = true
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
            let ao = NSLocalizedString("AcceptO", comment: "")
            acceptO.setTitle(ao, for: .normal)
            acceptO.isHidden = false
            let ro = NSLocalizedString("RejectO", comment: "")
            rejectCancelO.setTitle(ro, for: .normal)
            rejectCancelO.isHidden = false
            imageV.isHidden = true
            scheduledOn.isHidden = true
            schDate.isHidden = true
            beforePhoto.isHidden = false
            afterPLabel.isHidden = true
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
            scheduledOn.text = NSLocalizedString("ScheduledOn", comment: "")
            scheduledOn.isHidden = false
            schDate.isHidden = false
            imageV.isHidden = true
            acceptO.isHidden = true
            beforePhoto.isHidden = false
            afterPLabel.isHidden = true
            rejectCancelO.isHidden = true
            rate.isEnabled = false
            rateC.isEnabled = false
        } else if statusS == "done" {
            let slikaPosle = afterImg[0]
            slikaPosle.getDataInBackground { (data, error) in
                if let imageData = data {
                    if let imageToDisplay = UIImage(data: imageData) {
                        self.imageV.image = imageToDisplay
                    }
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let stringDate = dateFormatter.string(from: dateFinished as Date)
            schDate.text = stringDate
            beforePhoto.isHidden = false
            afterPLabel.isHidden = false
            pDate.isHidden = true
            pPrice.isHidden = true
            pd.isHidden = true
            pp.isHidden = true
            scheduledOn.text = NSLocalizedString("DoneOn", comment: "")
            scheduledOn.isHidden = false
            schDate.isHidden = false
            imageV.isHidden = false
            acceptO.isHidden = true
            rejectCancelO.isHidden = true
            rate.isEnabled = true
            rateC.isEnabled = true
        } else if statusS == "done (pending)" {
            let slikaPosle = afterImg[0]
            slikaPosle.getDataInBackground { (data, error) in
                if let imageData = data {
                    if let imageToDisplay = UIImage(data: imageData) {
                        self.imageV.image = imageToDisplay
                    }
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let stringDate = dateFormatter.string(from: dateFinished as Date)
            schDate.text = stringDate
            beforePhoto.isHidden = false
            afterPLabel.isHidden = false
            pDate.isHidden = true
            pPrice.isHidden = true
            pd.isHidden = true
            pp.text = NSLocalizedString("ValidInfo", comment: "")
            pp.isHidden = false
            scheduledOn.text = NSLocalizedString("DoneOn", comment: "")
            scheduledOn.isHidden = false
            schDate.isHidden = false
            imageV.isHidden = false
            let y = NSLocalizedString("Yes", comment: "")
            let n = NSLocalizedString("No", comment: "")
            acceptO.setTitle(y, for: .normal)
            rejectCancelO.setTitle(n, for: .normal)
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
                    print(error!)
                } else if let objects = objects {
                    for object in objects {
                        object["status"] = "scheduled"
                        object.saveInBackground()
                    }
                }
            })
            displayAlert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Sch", comment: ""))
        }
        else {
            query.findObjectsInBackground(block:  { (objects, error) in
                if error != nil {
                    print(error!)
                } else if let objects = objects {
                    for object in objects {
                        object["status"] = "done"
                        object.saveInBackground()
                    }
                }
            })
            displayAlert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Fin", comment: ""))
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
                    print(error!)
                } else if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
            let suc = NSLocalizedString("Success", comment: "")
            if statusS == "active" {
                displayAlert(title: suc, message: NSLocalizedString("RequestCancelled", comment: ""))
            } else if statusS == "pending" {
                displayAlert(title: suc, message: NSLocalizedString("OfferRejected", comment: ""))
            }
        }
        else {
            query.findObjectsInBackground(block:  { (objects, error) in
                if error != nil {
                    print(error!)
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
            displayAlert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("CraftsmanInfoInvalid", comment: ""))
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
        let phone = phoneNumber.titleLabel?.text
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
        if segue.identifier == "beforePhotoSegue" {
            let dvc = segue.destination as! PopUpViewController
            dvc.imageFile = beforeImg
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
