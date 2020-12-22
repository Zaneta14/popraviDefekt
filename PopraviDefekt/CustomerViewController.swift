//
//  CustomerViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/13/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class CustomerViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var manager = CLLocationManager()
    
    var locationChosen = Bool()
    
    var firstNames = [String]()
    
    var lastNames = [String]()
    
    var place = String()
    
    var desc = String()
    
    var datumiB = [NSDate]()
    
    var craftsmenIds = [String]()
    
    var statuses = [String]()
    
    var descriptions = [String]()
    
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var plumber: UISwitch!
    
    @IBOutlet weak var shoeMaker: UISwitch!
    
    @IBOutlet weak var electrician: UISwitch!
    
    @IBOutlet weak var carpenter: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationChosen = false
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
        longPressGR.minimumPressDuration = 2
        map.addGestureRecognizer(longPressGR)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        print("longpress")
        if !locationChosen {
            if gestureRecognizer.state == UIGestureRecognizer.State.began {
                let touchPoint = gestureRecognizer.location(in: self.map)
                let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
                let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                print(newCoordinate)
                var title = ""
                CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        if let placemark = placemarks?[0] {
                            if placemark.subThoroughfare != nil {
                                title += placemark.subThoroughfare! + " "
                            }
                            if placemark.thoroughfare != nil {
                                title += placemark.thoroughfare!
                            }
                        }
                        if title == "" {
                            title = "Added \(NSDate())"
                        }
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = newCoordinate
                        annotation.title = title
                        self.map.addAnnotation(annotation)
                        self.locationChosen = true
                        print(title)
                        self.place = title
                    }
                })
            }
        }
    }

    @IBAction func seeCraftsmen(_ sender: Any) {
        if !locationChosen || descriptionField.text == "" || (!plumber.isOn && !shoeMaker.isOn && !electrician.isOn && !carpenter.isOn) {
            displayAlert(title: "Not enough information", message: "Please enter all information required")
        }
        else {
            desc = descriptionField.text!
            let query = PFUser.query()
            var craft = String()
            if plumber.isOn {
                craft = "plumber"
            } else if electrician.isOn {
                craft = "electrician"
            } else if carpenter.isOn {
                craft = "carpenter"
            } else if shoeMaker.isOn {
                craft = "shoemaker"
            }
            query?.whereKey("craft", equalTo: craft)
            query?.findObjectsInBackground(block: { (objects, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else if let craftsmen = objects {
                    for object in craftsmen {
                        if let craftsman = object as? PFUser {
                            if let firstName = craftsman["firstName"] {
                                if let lastName = craftsman["lastName"] {
                                    self.firstNames.append(firstName as! String)
                                    self.lastNames.append(lastName as! String)
                                }
                            }
                        }
                    }
                }
                self.performSegue(withIdentifier: "seeCraftsmenSegue", sender: nil)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeCraftsmenSegue" {
            let destinationVC = segue.destination as! SeeCraftsmenTableViewController
            destinationVC.fNames = firstNames
            destinationVC.lNames = lastNames
            destinationVC.lokacija = place
            destinationVC.opis = desc
            firstNames.removeAll()
            lastNames.removeAll()
        }
        else if segue.identifier == "requestsSegue" {
            let destinationVC = segue.destination as! RequestsJobsTableViewController
            destinationVC.datumiB = datumiB
            destinationVC.craftsmenIds = craftsmenIds
            destinationVC.statuses = statuses
            destinationVC.descriptions = descriptions
            datumiB.removeAll()
            craftsmenIds.removeAll()
            statuses.removeAll()
            descriptions.removeAll()
            print("here")
        }
    }
    
    @IBAction func seeRequests(_ sender: Any) {
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let datumB = object["date"] {
                        if let craftsmanId = object["to"] {
                            if let status = object["status"] {
                                if let desc = object["description"] {
                                    self.datumiB.append(datumB as! NSDate)
                                    self.craftsmenIds.append(craftsmanId as! String)
                                    self.statuses.append(status as! String)
                                    self.desc.append(desc as! String)
                                }
                            }
                        }
                    }
                }
                self.performSegue(withIdentifier: "requestsSegue", sender: nil)
            }
        })
    }
    
    @IBAction func craftsmenChoice(_ sender: UISwitch) {
        if sender == plumber {
            if plumber.isOn {
                plumber.isOn = false
            } else {
                plumber.isOn = true
                electrician.isOn = false
                carpenter.isOn = false
                shoeMaker.isOn = false
            }
        }
        else if sender == carpenter {
            if carpenter.isOn {
                carpenter.isOn = false
            } else {
                carpenter.isOn = true
                electrician.isOn = false
                shoeMaker.isOn = false
                plumber.isOn = false
            }
        } else if sender == electrician {
            if electrician.isOn {
                electrician.isOn = false
            } else {
                electrician.isOn = true
                plumber.isOn = false
                carpenter.isOn = false
                shoeMaker.isOn = false
            }
        } else if sender == shoeMaker {
            if shoeMaker.isOn {
                shoeMaker.isOn = false
            } else {
                shoeMaker.isOn = true
                plumber.isOn = false
                carpenter.isOn = false
                electrician.isOn = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        PFUser.logOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
