//
//  CraftsmanTableViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/23/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class CraftsmanTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var fNames = [String]()
    
    var lNames = [String]()
    
    var datumi = [NSDate]()
    
    var opisi = [String]()
    
    var lokacii = [String]()
    
    var telefoni = [String]()
    
    var emailovi = [String]()
    
    var lons = [Double]()
    
    var lats = [Double]()
    
    var indeks = Int()
    
    var currentLat = Double()
    
    var currentLon = Double()
    
    var komentari = [[String]]()

    var beforePic = [PFFileObject]()
    
    var userIds = [String]()
    
    var refresher:UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(CraftsmanTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTable()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLat = locations[0].coordinate.latitude
        currentLon = locations[0].coordinate.longitude
        PFUser.current()!["currentLat"] = currentLat
        PFUser.current()!["currentLon"] = currentLon
        PFUser.current()?.saveInBackground()
    }
    
    @objc func updateTable() {
        self.fNames.removeAll()
        self.lNames.removeAll()
        self.datumi.removeAll()
        self.opisi.removeAll()
        self.lokacii.removeAll()
        self.lats.removeAll()
        self.lons.removeAll()
        self.telefoni.removeAll()
        self.emailovi.removeAll()
        self.beforePic.removeAll()
        self.komentari.removeAll()
        self.userIds.removeAll()
        let query = PFQuery(className: "Job")
        query.whereKey("to", equalTo: PFUser.current()?.objectId!)
        query.whereKey("status", equalTo: "active")
        query.addDescendingOrder("date")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error!)
            } else if let objects = objects {
                for object in objects {
                    if let userId = object["from"] {
                        if let datum = object["date"] {
                            if let opis = object["description"] {
                                if let lokacija = object["location"] {
                                    if let lat = object["lat"] {
                                        if let lon = object["lon"] {
                                            if let beforeImg = object["beforeImg"] {
                                                let comQuery = PFQuery(className: "Comment")
                                                comQuery.whereKey("userId", equalTo: userId)
                                                comQuery.findObjectsInBackground(block: { (success, error) in
                                                    if error != nil {
                                                        print(error!)
                                                    }
                                                    else if let objects = success {
                                                        for object in objects {
                                                            var komentar = [String]()
                                                            if let comments = object["comments"] {
                                                                komentar = comments as! [String]
                                                            }
                                                            let userQuery = PFUser.query()
                                                            userQuery?.whereKey("objectId", equalTo: userId)
                                                            userQuery?.findObjectsInBackground(block: { (users, error) in
                                                                if error != nil {
                                                                    print(error!)
                                                                } else if let users = users {
                                                                    for user in users {
                                                                        if let user = user as? PFUser {
                                                                            if let fName = user["firstName"] {
                                                                                if let lName = user["lastName"] {
                                                                                    if let pNumber = user["phoneNumber"] {
                                                                                        if let emailAdd = user.username {
                                                                                            self.datumi.append(datum as! NSDate)
                                                                                            self.opisi.append(opis as! String)
                                                                                            self.lokacii.append(lokacija as! String)
                                                                                            self.lats.append(lat as! Double)
                                                                                            self.lons.append(lon as! Double)
                                                                                            self.fNames.append(fName as! String)
                                                                                            self.lNames.append(lName as! String)
                                                                                            self.telefoni.append(pNumber as! String)
                                                                                            self.emailovi.append(emailAdd)
                                                                                            self.beforePic.append(beforeImg as! PFFileObject)
                                                                                            self.komentari.append(komentar)
                                                                                            self.userIds.append(userId as! String)
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                self.refresher.endRefreshing()
                                                                self.tableView.reloadData()
                                                            })
                                                        }
                                                    }
                                                    self.refresher.endRefreshing()
                                                    self.tableView.reloadData()
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cCell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        for userId in userIds {
            print(userId)
        }
        let stringDate = dateFormatter.string(from: datumi[indexPath.row] as Date)
        cell.textLabel?.text = stringDate
        
        if komentari.count == fNames.count && komentari.count > 0 {
            if komentari[indexPath.row].count > 0 {
                cell.detailTextLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row] + " | " + komentari[indexPath.row].joined(separator: ", ")
            } else {
                cell.detailTextLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row] + NSLocalizedString("nocomm", comment: "")
            }
        } else {
            cell.detailTextLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row] + NSLocalizedString("nocomm", comment: "")
        }
        cell.layer.cornerRadius = 25
        cell.layer.masksToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indeks = (tableView.indexPathForSelectedRow?.row)!
        performSegue(withIdentifier: "rDetailsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rDetailsSegue" {
            let destVC = segue.destination as! CRequestDetailsViewController
            destVC.fName = fNames[indeks]
            destVC.lName = lNames[indeks]
            destVC.lokacija = lokacii[indeks]
            destVC.emailadresa = emailovi[indeks]
            destVC.opis = opisi[indeks]
            destVC.telefon = telefoni[indeks]
            destVC.datum = datumi[indeks]
            destVC.lat = lats[indeks]
            destVC.lon = lons[indeks]
            destVC.bfrPic.append(beforePic[indeks])
        }
    }
    
}
