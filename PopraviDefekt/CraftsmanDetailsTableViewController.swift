//
//  CraftsmanDetailsTableViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/21/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class CraftsmanDetailsTableViewController: UITableViewController {
    
    var dates = [NSDate]()
    var imageFiles = [PFFileObject]()
    var selCraftsmanId = String()
    var opis = String()
    var lokacija = String()
    var lat = Double()
    var lon = Double()
    var firstName = String()
    var lastName = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
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
                            self.selCraftsmanId = objectId
                        }
                    }
                }
            }
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CraftsmanDetailsTableViewCell
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageToDisplay = UIImage(data: imageData) {
                    cell.imageI.image = imageToDisplay
                    print("success")
                }
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: dates[indexPath.row] as Date)
        cell.dateFinished.text = stringDate
        return cell
    }

    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    @IBAction func makeARequest(_ sender: Any) {
        
        let request = PFObject(className: "Job")
        request["from"] = PFUser.current()?.objectId
        request["to"] = selCraftsmanId
        request["date"] = NSDate()
        request["status"] = "active"
        request["description"] = opis
        request["location"] = lokacija
        request["lat"] = lat
        request["lon"] = lon
        request.saveInBackground { (success, error) in
            if success {
                self.displayAlert(title: "Success!", message: "You have made a request.")
            } else {
                self.displayAlert(title: "Failed", message: (error?.localizedDescription)!)
            }
        }
    }
    
    func fetchData() {
        self.imageFiles.removeAll()
        self.dates.removeAll()
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
                                                print("Vo funkcija: \(self.dates.count)")
                                                print("Datum: \(datum)")
                                                self.imageFiles.append(slika as! PFFileObject)
                                            }
                                        }
                                    }
                                }
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
        })
    }
    
}
