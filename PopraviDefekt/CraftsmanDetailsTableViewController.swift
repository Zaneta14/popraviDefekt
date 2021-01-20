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
    
    @IBOutlet weak var craftsman: UILabel!
    
    @IBOutlet weak var commentsC: UITextView!
    
    @IBOutlet weak var grade: UILabel!
    
    @IBOutlet weak var percentage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        craftsman.text = firstName + " " + lastName
        let query = PFQuery(className: "CommentCraftsman")
        query.whereKey("userId", equalTo: selCraftsmanId)
        query.findObjectsInBackground { (success, error) in
            if error != nil {
                print(error!)
            } else if let objects = success {
                for object in objects {
                    if let comments = object["comments"] {
                        self.commentsC.text = "\"" + (comments as! [String]).joined(separator: "\", \"") + "\""
                    } else {
                        self.commentsC.text = "No comments yet."
                    }
                }
            }
        }
        var count = 0
        var sum = 0
        let q = PFQuery(className: "Job")
        q.whereKey("to", equalTo: selCraftsmanId)
        q.findObjectsInBackground { (success, error) in
            if error != nil {
                print(error!)
            } else if let objects = success {
                for object in objects {
                    if let rating = object["rating"] {
                        count += 1
                        sum += rating as! Int
                    }
                }
                if count > 0 {
                    let average = Double(sum) / Double(count)
                    self.grade.text = String(average) + "/5"
                }
                else {
                    self.grade.text = "No ratings yet."
                    self.grade.textColor = .black
                }
            }
        }
        var x = 0
        var y = 0
        let array = ["done", "scheduled", "done (pending)"]
        let predicate = NSPredicate(format: "status = %@ OR status = %@ OR status = %@", argumentArray: array)
        let qu = PFQuery(className: "Job", predicate: predicate)
        qu.whereKey("to", equalTo: selCraftsmanId)
        qu.findObjectsInBackground { (success, error) in
            if error != nil {
                print(error!)
            } else if let objects = success {
                if objects.count > 0 {
                    for object in objects {
                        if object["status"] as! String == "done" {
                            if let times = object["timesDeclaredInvalid"] {
                                x += 1
                                y += (1 + (times as! Int))
                            } else {
                                x += 1
                                y += 1
                            }
                        }
                        else {
                            if let times = object["timesDeclaredInvalid"] {
                                y += times as! Int
                            }
                        }
                    }
                    if y == 0 {
                        self.percentage.text = "No data about approved information by customers."
                    }
                    let result = (Double(x) / Double(y))*100
                    self.percentage.text = String(format: "%.2f", result) + "% approved information by customers"
                } else {
                    self.percentage.text = "No data about approved information by customers."
                }
            }
        }
        fetchData()
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
        } else {
            cell.comment.text = "No comment yet."
        }
        if ratings[indexPath.row] != 0 {
            cell.rating.text = "\(ratings[indexPath.row])" + "/5"
        } else {
            cell.rating.text = "No rating yet."
        }
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        return cell
    }

    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertOKaction) in
            self.popThisView()
        }))
        present(allertController, animated: true, completion: nil)
    }
    
    func popThisView() {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is SeeCraftsmenTableViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
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
                self.displayAlert(title: "Failed", message: (error! as! String))
            }
        }
    }
    
    func fetchData() {
        self.imageFiles.removeAll()
        self.dates.removeAll()
        self.ratings.removeAll()
        self.comments.removeAll()
        let query = PFQuery(className: "Job")
        query.whereKey("to", equalTo: selCraftsmanId)
        query.whereKey("status", equalTo: "done")
        query.findObjectsInBackground(block: { (jobs, error) in
            if error != nil {
                print(error!)
            } else if let jobs = jobs {
                for job in jobs {
                    if let datum = job["finishDate"] {
                        if let slika = job["afterImg"] {
                            self.dates.append(datum as! NSDate)
                            self.imageFiles.append(slika as! PFFileObject)
                            if let komentar = job["comment"] {
                                if let rejting = job["rating"] {
                                    self.comments.append(komentar as? String)
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
