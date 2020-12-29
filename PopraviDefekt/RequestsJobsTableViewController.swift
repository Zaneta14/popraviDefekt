//
//  RequestsJobsTableViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/21/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class RequestsJobsTableViewController: UITableViewController {
    
    var indeks = Int()
    
    var datumiB = [NSDate]()
    
    var craftsmenIds = [String]()
    
    var statuses = [String]()
    
    var descriptions = [String]()
    
    var propDates = [NSDate]()
    
    var propPrices = [String]()
    
    var finishDates = [NSDate?]()
    
    var imageFiles = [PFFileObject?]()
    
    var refresher:UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(RequestsJobsTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datumiB.count
    }
    
    @objc func updateTable() {
        datumiB.removeAll()
        craftsmenIds.removeAll()
        statuses.removeAll()
        descriptions.removeAll()
        propDates.removeAll()
        propPrices.removeAll()
        finishDates.removeAll()
        imageFiles.removeAll()
        let query = PFQuery(className: "Job")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.addDescendingOrder("date")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let datumB = object["date"] {
                        if let craftsmanId = object["to"] {
                            if let status = object["status"] {
                                if let desc = object["description"] {
                                    self.datumiB.append(datumB as! NSDate)
                                    self.craftsmenIds.append(craftsmanId as! String)
                                    self.statuses.append(status as! String)
                                    self.descriptions.append(desc as! String)
                                    if let pDateTime = object["pDateTime"] {
                                        if let pPrice = object["pPrice"] {
                                            self.propDates.append(pDateTime as! NSDate)
                                            self.propPrices.append(pPrice as! String)
                                        }
                                    }
                                    else {
                                        self.propDates.append(NSDate()) //za da ne e prazno
                                        self.propPrices.append("")
                                    }
                                    if let finDate = object["finishDate"] {
                                        if let imageFile = object["imageFile"] {
                                            self.finishDates.append(finDate as! NSDate)
                                            self.imageFiles.append(imageFile as! PFFileObject)
                                        }
                                    }
                                    else {
                                        self.finishDates.append(nil)
                                        self.imageFiles.append(nil)
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Kelija", for: indexPath)
        let craftsmanId = craftsmenIds[indexPath.row]
        let queryT = PFUser.query()
        queryT?.whereKey("objectId", equalTo: craftsmanId)
        queryT?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let craftsman = object as? PFUser {
                        if let firstName = craftsman["firstName"] {
                            if let lastName = craftsman["lastName"] {
                                cell.textLabel?.text = (firstName as! String) + " " + (lastName as! String)
                            }
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let stringDate = dateFormatter.string(from: self.datumiB[indexPath.row] as Date)
                cell.detailTextLabel?.text = stringDate
                let status = self.statuses[indexPath.row]
                if status == "active" {
                    cell.backgroundColor = UIColor.yellow
                } else if status == "pending" {
                    cell.backgroundColor = UIColor.red
                } else if status == "scheduled" {
                    cell.backgroundColor = UIColor.blue
                } else if status == "done" {
                    cell.backgroundColor = UIColor.green
                }
            }
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indeks = (tableView.indexPathForSelectedRow?.row)!
        performSegue(withIdentifier: "requestDetailsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestDetailsSegue" {
            let destinationVC = segue.destination as! RequestDetailsViewController
            destinationVC.craftsmanId = craftsmenIds[indeks]
            destinationVC.descr = descriptions[indeks]
            destinationVC.dateReq = datumiB[indeks]
            destinationVC.statusS = statuses[indeks]
            if statuses[indeks] == "pending" {
                destinationVC.propDate = propDates[indeks]
                destinationVC.propPrice = propPrices[indeks]
            }
            else if statuses[indeks] == "scheduled" {
                destinationVC.propDate = propDates[indeks]
            }
            else if statuses[indeks] == "done" {
                destinationVC.imageFile.append(imageFiles[indeks]!)
                destinationVC.dateFinished = finishDates[indeks]!
            }
        }
    }
}
