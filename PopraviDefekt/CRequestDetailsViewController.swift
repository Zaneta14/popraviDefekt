//
//  CRequestDetailsViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/26/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import MapKit
import Parse

class CRequestDetailsViewController: UIViewController {
    
    var fName = String()
    
    var lName = String()
    
    var datum = NSDate()
    
    var opis = String()
    
    var lokacija = String()
    
    var telefon = String()
    
    var emailadresa = String()
    
    var lat = Double()
    
    var lon = Double()
    
    var bfrPic = [PFFileObject]()
    
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var datumM: UILabel!
    
    @IBOutlet weak var adresaLok: UILabel!
    
    @IBOutlet weak var opisS: UITextView!
    
    @IBOutlet weak var imePrezime: UILabel!
    
    @IBOutlet weak var phoneN: UIButton!
    
    @IBOutlet weak var emailA: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opisS.text = opis
        emailA.setTitle(emailadresa, for: .normal)
        phoneN.setTitle(telefon, for: .normal)
        imePrezime.text = fName + " " + lName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: datum as Date)
        datumM.text = stringDate
        adresaLok.text = lokacija
        opisS.text = "\"" + opis + "\""
        let slikaPred = bfrPic[0]
        slikaPred.getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageToDisplay = UIImage(data: imageData) {
                    self.imageView.image = imageToDisplay
                }
            }
        }
    }
    
    @IBAction func makeAnOffer(_ sender: Any) {
        if priceTextField.text == "" {
            displayAlert(title: "Invalid", message: "Please enter a price.")
        } else {
            let schDateAndTime = datePicker.date
            let price = priceTextField.text
            let userQuery = PFUser.query()
            userQuery?.whereKey("firstName", equalTo: fName)
            userQuery?.whereKey("lastName", equalTo: lName)
            userQuery?.whereKey("phoneNumber", equalTo: telefon)
            userQuery?.whereKey("username", equalTo: emailadresa)
            userQuery?.findObjectsInBackground(block: { (success, error) in
                if error != nil {
                    print(error!)
                } else if let users = success {
                    for user in users {
                        if let userId = user.objectId {
                            let query = PFQuery(className: "Job")
                            query.whereKey("from", equalTo: userId)
                            query.whereKey("to", equalTo: PFUser.current()?.objectId)
                            query.whereKey("description", equalTo: self.opis)
                            query.whereKey("date", equalTo: self.datum)
                            query.whereKey("location", equalTo: self.lokacija)
                            query.findObjectsInBackground(block:  { (objects, error) in
                                if error != nil {
                                    print(error!)
                                } else if let objects = objects {
                                    for object in objects {
                                        object["status"] = "pending"
                                        object["pDateTime"] = schDateAndTime
                                        object["pPrice"] = price
                                        object.saveInBackground()
                                    }
                                }
                            })
                        }
                    }
                }
            })
            displayAlert(title: "Success!", message: "You have made an offer.")
        }
    }
    
    @IBAction func rejectRequest(_ sender: Any) {
        let userQuery = PFUser.query()
        userQuery?.whereKey("firstName", equalTo: fName)
        userQuery?.whereKey("lastName", equalTo: lName)
        userQuery?.whereKey("phoneNumber", equalTo: telefon)
        userQuery?.whereKey("username", equalTo: emailadresa)
        userQuery?.findObjectsInBackground(block: { (success, error) in
            if error != nil {
                print(error!)
            } else if let users = success {
                for user in users {
                    if let userId = user.objectId {
                        let query = PFQuery(className: "Job")
                        query.whereKey("from", equalTo: userId)
                        query.whereKey("to", equalTo: PFUser.current()?.objectId)
                        query.whereKey("description", equalTo: self.opis)
                        query.whereKey("date", equalTo: self.datum)
                        query.whereKey("location", equalTo: self.lokacija)
                        query.findObjectsInBackground(block:  { (objects, error) in
                            if error != nil {
                                print(error!)
                            } else if let objects = objects {
                                for object in objects {
                                    object.deleteInBackground()
                                }
                            }
                        })
                    }
                }
            }
        })
        displayAlert(title: "Success", message: "You have rejected the request.")
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
                if controller is CraftsmanTableViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
    
    @IBAction func makeACall(_ sender: Any) {
        let phone = phoneN.titleLabel?.text
        if let url = URL(string: "tel://\(phone!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func sendAnEmail(_ sender: Any) {
        let email = emailA.titleLabel?.text
        if let url = URL(string: "mailto:\(email!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue" {
            let dvc = segue.destination as! MapViewController
            dvc.lat = lat
            dvc.lon = lon
            dvc.lok = lokacija
        }
    }
    
}
