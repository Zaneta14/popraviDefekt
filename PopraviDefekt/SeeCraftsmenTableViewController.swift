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
    var dates = [NSDate]()
    var imageFiles = [PFFileObject]()
    var selectedCraftsmanId = String()
    var opis = String()
    var lokacija = String()
    var lat = Double()
    var lon =  Double()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelija", for: indexPath)
        cell.textLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row]
        
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
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.imageFiles.removeAll()
        self.dates.removeAll()
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
                            self.selectedCraftsmanId = objectId
                            let query = PFQuery(className: "Job")
                            query.whereKey("to", equalTo: objectId)
                            query.whereKey("status", equalTo: "done")
                            query.findObjectsInBackground(block: { (jobs, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else if let jobs = jobs {
                                    for job in jobs {
                                        if let datum = job["finishDate"] {
                                            if let slika = job["imageFile"] {
                                                self.dates.append(datum as! NSDate)
                                                print(datum)
                                                self.imageFiles.append(slika as! PFFileObject)
                                            }
                                        }
                                    }
                                }
                            })
                            self.performSegue(withIdentifier: "craftsmanDetailsSegue", sender: nil)
                        }
                    }
                }
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "craftsmanDetailsSegue" {
            let destinationVC = segue.destination as! CraftsmanDetailsTableViewController
            destinationVC.dates = dates
            print(dates.count)
            destinationVC.imageFiles = imageFiles
            destinationVC.selCraftsmanId = selectedCraftsmanId
            destinationVC.lokacija = lokacija
            destinationVC.opis = opis
            destinationVC.lat = lat
            destinationVC.lon = lon
        }
    }
}
