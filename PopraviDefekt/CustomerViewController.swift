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

class CustomerViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var manager = CLLocationManager()
    
    var locationChosen = Bool()
    
    var firstNames = [String]()
    
    var lastNames = [String]()
    
    var place = String()
    
    var desc = String()
    
    var lat = Double()
    
    var lon = Double()
    
    var types = [String]()
    
    var craft = String()
    
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var map: MKMapView!
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        types.removeAll()
        let query = PFQuery(className: "CraftsmanType")
        query.findObjectsInBackground { (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = success {
                for object in objects {
                    if let typeP = object["eng"] {
                        self.types.append(typeP as! String)
                    }
                }
                self.pickerView.reloadAllComponents()
                self.pickerView.selectRow(1, inComponent: 0, animated: false)
            }
        }
        
        locationChosen = false
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
        longPressGR.minimumPressDuration = 2
        map.addGestureRecognizer(longPressGR)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        craft = types[row]
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
                        self.lat = newCoordinate.latitude
                        self.lon = newCoordinate.longitude
                    }
                })
            }
        }
    }

    @IBAction func seeCraftsmen(_ sender: Any) {
        if !locationChosen || descriptionField.text == "" {
            displayAlert(title: "Not enough information", message: "Please enter all information required")
        }
        else {
            firstNames.removeAll()
            lastNames.removeAll()
            desc = descriptionField.text!
            var objId = String()
            let queryQ = PFQuery(className: "CraftsmanType")
            queryQ.whereKey("eng", equalTo: craft)
            queryQ.findObjectsInBackground { (success, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let objects = success {
                    for object in objects {
                        if let objectId = object.objectId {
                            objId = objectId
                            let query = PFUser.query()
                            query?.whereKey("crafts", contains: objId)
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
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeCraftsmenSegue" {
            let destinationVC = segue.destination as! SeeCraftsmenTableViewController
            destinationVC.fNames = firstNames
            destinationVC.lNames = lastNames
            destinationVC.lokacija = place
            destinationVC.opis = desc
            destinationVC.lat = lat
            destinationVC.lon = lon
        }
    }
    
    @IBAction func seeRequests(_ sender: Any) {
        self.performSegue(withIdentifier: "requestsSegue", sender: nil)
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
