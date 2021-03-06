//
//  JobsTableViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/26/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class JobsTableViewController: UITableViewController {
    
    var statuses = [String]()
    
    var firstNames = [String]()
    
    var lastNames = [String]()
    
    var dates = [NSDate]()
    
    var finishDates = [NSDate?]()
    
    var pNumbers = [String]()
    
    var emailAs = [String]()
    
    var adresi = [String]()
    
    var lats = [Double]()
    
    var lons = [Double]()
    
    var beforeImages = [PFFileObject]()
    
    var images = [PFFileObject?]()
    
    var jobIds = [String]()
    
    var userIds = [String]()
    
    var refresher:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(RequestsJobsTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTable()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }
    
    @objc func updateTable() {
        statuses.removeAll()
        dates.removeAll()
        firstNames.removeAll()
        lastNames.removeAll()
        finishDates.removeAll()
        lons.removeAll()
        lats.removeAll()
        adresi.removeAll()
        pNumbers.removeAll()
        emailAs.removeAll()
        images.removeAll()
        jobIds.removeAll()
        userIds.removeAll()
        beforeImages.removeAll()
        let array = ["done", "scheduled", "done (pending)"]
        let predicate = NSPredicate(format: "status = %@ OR status = %@ OR status = %@", argumentArray: array)
        let query = PFQuery(className: "Job", predicate: predicate)
        query.whereKey("to", equalTo: PFUser.current()?.objectId!)
        query.addDescendingOrder("pDateTime")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error!)
            } else if let objects = objects {
                for object in objects {
                    if let status = object["status"] {
                        if let pDate = object["pDateTime"] {
                            if let adresa = object["location"] {
                                if let lat = object["lat"] {
                                    if let lon = object["lon"] {
                                        if let bfrImage = object["beforeImg"] {
                                            if let slika = object["afterImg"] {
                                                self.images.append(slika as? PFFileObject)
                                            } else {
                                                self.images.append(nil)
                                            }
                                            if let fDate = object["finishDate"] {
                                                self.finishDates.append(fDate as? NSDate)
                                            } else {
                                                self.finishDates.append(nil)
                                            }
                                            if let jobId = object.objectId {
                                                if let userId = object["from"] {
                                                    let userQuery = PFUser.query()
                                                    userQuery?.whereKey("objectId", equalTo: userId)
                                                    userQuery?.findObjectsInBackground(block: { (success, error) in
                                                        if error != nil {
                                                            print(error!)
                                                        } else if let users = success {
                                                            for user in users {
                                                                if let user = user as? PFUser {
                                                                    if let fName = user["firstName"] {
                                                                        if let lName = user["lastName"] {
                                                                            if let emailA = user.username {
                                                                                if let pNumber = user["phoneNumber"] {
                                                                                    self.dates.append(pDate as! NSDate)
                                                                                    self.statuses.append(status as! String)
                                                                                    self.firstNames.append(fName as! String)
                                                                                    self.lastNames.append(lName as! String)
                                                                                    self.pNumbers.append(pNumber as! String)
                                                                                    self.emailAs.append(emailA)
                                                                                    self.lats.append(lat as! Double)
                                                                                    self.lons.append(lon as! Double)
                                                                                    self.adresi.append(adresa as! String)
                                                                                    self.beforeImages.append(bfrImage as! PFFileObject)
                                                                                    self.jobIds.append(jobId)
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
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelijaK", for: indexPath)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let stringDate = formatter.string(from: dates[indexPath.row] as Date)
        cell.textLabel?.text = stringDate
        cell.detailTextLabel?.text = firstNames[indexPath.row] + " " + lastNames[indexPath.row]
        if statuses[indexPath.row] == "scheduled" {
            cell.backgroundColor = .red
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }
        else if statuses[indexPath.row] == "done" {
            cell.backgroundColor = .green
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }
        else {
            cell.backgroundColor = .purple
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
        }
        cell.layer.cornerRadius = 25
        cell.layer.masksToBounds = true
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jobDetailsSegue" {
            if let index = tableView.indexPathForSelectedRow?.row {
                let dVC = segue.destination as! JobDetailsViewController
                dVC.firstName = firstNames[index]
                dVC.lastName = lastNames[index]
                dVC.adresa = adresi[index]
                dVC.emailA = emailAs[index]
                dVC.phoneN = pNumbers[index]
                dVC.lat = lats[index]
                dVC.lon = lons[index]
                dVC.statusS = statuses[index]
                dVC.dateSch = dates[index]
                dVC.jobId = jobIds[index]
                dVC.userId = userIds[index]
                dVC.beforeImage.append(beforeImages[index])
                if statuses[index] == "done" || statuses[index] == "done (pending)" {
                    dVC.dateFin = finishDates[index]!
                    dVC.image.append(images[index]!)
                }
            }
        }
    }
    
}
