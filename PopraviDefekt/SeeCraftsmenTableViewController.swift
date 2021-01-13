//
//  SeeCraftsmenTableViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/21/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class SeeCraftsmenTableViewController: UITableViewController {
    
    var fNames = [String]()
    var lNames = [String]()
    var opis = String()
    var lokacija = String()
    var lat = Double()
    var lon =  Double()
    var craftsmanIds = [String]()
    var i = Int()
    var selectedCraftsmanId = String()
    var beforeImg = UIImage()
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        craftsmanIds.removeAll()
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelija", for: indexPath)
        cell.textLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row]
        let defectLocation = CLLocation(latitude: lat, longitude: lon)
        let firstName = fNames[indexPath.row]
        let lastName = lNames[indexPath.row]
        let craftsmanQuery = PFUser.query()
        craftsmanQuery?.whereKey("role", equalTo: "craftsman")
        craftsmanQuery?.whereKey("firstName", equalTo: firstName)
        craftsmanQuery?.whereKey("lastName", equalTo: lastName)
        craftsmanQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let craftsmen = objects {
                for object in craftsmen {
                    if let craftsman = object as? PFUser {
                        if let objectId = craftsman.objectId {
                            if let currLat = craftsman["currentLat"] {
                                if let currLon = craftsman["currentLon"] {
                                    let craftsmanLocation = CLLocation(latitude: currLat as! Double, longitude: currLon as! Double)
                                    let distance = craftsmanLocation.distance(from: defectLocation) / 1000
                                    let roundedDistance = round(distance * 100) / 100
                                    cell.detailTextLabel?.text = "\(roundedDistance)km away"
                                    let query = PFQuery(className: "Job")
                                    query.whereKey("from", equalTo: PFUser.current()?.objectId)
                                    query.whereKey("to", equalTo: objectId)
                                    query.whereKey("status", equalTo: "active")
                                    query.findObjectsInBackground(block: { (objects, error) in
                                        if error != nil {
                                            print(error?.localizedDescription)
                                        } else if let objects = objects {
                                            if objects.count > 0 {
                                                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        i = indexPath.row
        performSegue(withIdentifier: "craftsmanDetailsSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "craftsmanDetailsSegue" {
            let destinationVC = segue.destination as! CraftsmanDetailsTableViewController
            destinationVC.lat = lat
            destinationVC.lon = lon
            destinationVC.lokacija = lokacija
            destinationVC.opis = opis
            destinationVC.firstName = fNames[i]
            destinationVC.lastName = lNames[i]
            destinationVC.beforeImg = beforeImg
        }
    }
    
}
