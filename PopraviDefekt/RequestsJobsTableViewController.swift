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
    
    var fNames = [String]()
    var lNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datumiB.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("tableView")
        
        
        
        self.fNames.removeAll()
        self.lNames.removeAll()
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
                                print(firstName)
                                print(lastName)
                                cell.textLabel?.text = (firstName as! String) + " " + (lastName as! String)
                                //self.fNames.append(firstName as! String)
                                //self.lNames.append(lastName as! String)
                            }
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                let stringDate = dateFormatter.string(from: self.datumiB[indexPath.row] as Date)
                print(stringDate)
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
        }
    }

}
