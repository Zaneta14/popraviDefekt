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
    //var dates = [NSDate]()
    //var imageFiles = [PFFileObject]()
    var opis = String()
    var lokacija = String()
    var lat = Double()
    var lon =  Double()
    var craftsmanIds = [String]()
    var i = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(viewDidLoad)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //craftsmanIds.removeAll()
        //tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        craftsmanIds.removeAll()
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelija", for: indexPath)
        cell.textLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row]
        
        let firstName = fNames[indexPath.row]
        print(firstName)
        let lastName = lNames[indexPath.row]
        print(lastName)
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
                            self.craftsmanIds.append(objectId)
                            print(objectId)
                            print("CraftsmanIds = \(self.craftsmanIds.count)")
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
            destinationVC.selCraftsmanId = craftsmanIds[i]
            print(craftsmanIds[i])
            //print("Selected craftsmanId: \(self.selectedCraftsmanId)")
            print("dVC")
            /*destinationVC.dates = self.dates
            print(self.dates.count)
            destinationVC.imageFiles = self.imageFiles*/
        }
    }
    
    /*func fetchData(i: Int) {
        print("fetchData")
        self.imageFiles.removeAll()
        self.dates.removeAll()
        let firstName = fNames[i]
        let lastName = lNames[i]
        print(firstName)
        let craftsmanQuery = PFUser.query()
        craftsmanQuery?.whereKey("role", equalTo: "craftsman")
        craftsmanQuery?.whereKey("firstName", equalTo: firstName)
        craftsmanQuery?.whereKey("lastName", equalTo: lastName)
        craftsmanQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let craftsmen = objects {
                print("ovde")
                for object in craftsmen {
                    print("ima")
                    if let craftsman = object as? PFUser {
                        if let objectId = craftsman.objectId {
                            print(objectId)
                            self.selectedCraftsmanId = objectId
                            let query = PFQuery(className: "Job")
                            query.whereKey("to", equalTo: objectId)
                            query.whereKey("status", equalTo: "done")
                            print("lala")
                            query.findObjectsInBackground(block: { (jobs, error) in
                                print("mhm")
                                if error != nil {
                                    print(error?.localizedDescription)
                                    print("greska")
                                } else if let jobs = jobs {
                                    print("nema greska")
                                    for job in jobs {
                                        print("ima2")
                                        if let datum = job["finishDate"] {
                                            if let slika = job["imageFile"] {
                                                self.dates.append(datum as! NSDate)
                                                print("Vo funkcija: \(self.dates.count)")
                                                print("Datum: \(datum)")
                                                self.imageFiles.append(slika as! PFFileObject)
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
    }*/
}
