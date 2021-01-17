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
    var comments = [String?]()
    var ratings = [Int]()
    var selCraftsmanId = String()
    var opis = String()
    var lokacija = String()
    var lat = Double()
    var lon = Double()
    var firstName = String()
    var lastName = String()
    var beforeImg = UIImage()

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
                }
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: dates[indexPath.row] as Date)
        cell.dateFinished.text = stringDate
        if comments[indexPath.row] != nil {
            cell.comment.text = "\"" + comments[indexPath.row]! + "\""
        }
        if ratings[indexPath.row] != 0 {
            cell.rating.text = "\(ratings[indexPath.row])" + "/5"
        }
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
        if let imageData = beforeImg.jpeg(.medium) {
            let imageFile = PFFileObject(name: "image.jpg", data: imageData)
            request["beforeImg"] = imageFile
        }
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
        self.ratings.removeAll()
        self.comments.removeAll()
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
                            query.whereKey("to", equalTo: objectId)
                            query.whereKey("status", equalTo: "done")
                            query.findObjectsInBackground(block: { (jobs, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else if let jobs = jobs {
                                    for job in jobs {
                                        if let datum = job["finishDate"] {
                                            if let slika = job["afterImg"] {
                                                self.dates.append(datum as! NSDate)
                                                self.imageFiles.append(slika as! PFFileObject)
                                                if let komentar = job["comment"] {
                                                    if let rejting = job["rating"] {
                                                        self.comments.append(komentar as! String)
                                                        self.ratings.append(rejting as! Int)
                                                    }
                                                } else {
                                                    self.comments.append(nil)
                                                    self.ratings.append(0)
                                                }
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
