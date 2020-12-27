//
//  CRequestDetailsViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/26/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
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
    
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var datumM: UILabel!
    
    @IBOutlet weak var opisS: UILabel!
    
    @IBOutlet weak var imePrezime: UILabel!
    
    @IBOutlet weak var emailTelefon: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opisS.text = opis
        emailTelefon.text = emailadresa + " " + telefon
        imePrezime.text = fName + " " + lName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: datum as Date)
        datumM.text = stringDate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = lokacija
        self.map.addAnnotation(annotation)
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
                    print(error?.localizedDescription)
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
                                    print(error?.localizedDescription)
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
            /*let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let stringDate = dateFormatter.string(from: schDateAndTime as Date)
            print(stringDate)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let stringTime = timeFormatter.string(from: schDateAndTime as Date)
            print(stringTime)*/
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
                print(error?.localizedDescription)
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
                                print(error?.localizedDescription)
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
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
