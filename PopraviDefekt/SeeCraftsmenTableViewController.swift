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
    //var firstName = String()
    //var lastName = String()

    /*override func viewDidLoad() {
        super.viewDidLoad()
    }*/
    
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
        
        let firstName = fNames[indexPath.row]
        print(firstName)
        let lastName = lNames[indexPath.row]
        print(lastName)
        let craftsmanQuery = PFUser.query()
        craftsmanQuery?.whereKey("role", equalTo: "craftsman")
        craftsmanQuery?.whereKey("firstName", equalTo: firstName)
        craftsmanQuery?.whereKey("lastName", equalTo: lastName)
        craftsmanQuery?.addDescendingOrder("lastName")
        craftsmanQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let craftsmen = objects {
                for object in craftsmen {
                    if let craftsman = object as? PFUser {
                        if let objectId = craftsman.objectId {
                            //self.craftsmanIds.append(objectId)
                            print(objectId)
                            //print("CraftsmanIds = \(self.craftsmanIds.count)")
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
        print("clicked")
        i = indexPath.row
        //fetchData(i: i)
        performSegue(withIdentifier: "craftsmanDetailsSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        if segue.identifier == "craftsmanDetailsSegue" {
            let destinationVC = segue.destination as! CraftsmanDetailsTableViewController
            destinationVC.lat = lat
            destinationVC.lon = lon
            destinationVC.lokacija = lokacija
            destinationVC.opis = opis
            destinationVC.firstName = fNames[i]
            destinationVC.lastName = lNames[i]
            //destinationVC.selCraftsmanId = selectedCraftsmanId//craftsmanIds[i]
            //print(craftsmanIds[i])
            //print("Selected craftsmanId: \(self.selectedCraftsmanId)")
            print("dVC")
            /*destinationVC.dates = self.dates
            print(self.dates.count)
            destinationVC.imageFiles = self.imageFiles*/
        }
    }
    
    /*func fetchData(i: Int) {
        print("fetchData")
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
                        }
                    }
                }
            }
        })
    }*/
}
