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
    
    var refresher:UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(JobsTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return statuses.count
    }
    
    @objc func updateTable() {
        statuses.removeAll()
        dates.removeAll()
        firstNames.removeAll()
        lastNames.removeAll()
        let array = ["done", "scheduled"]
        let predicate = NSPredicate(format: "status = %@ OR status = %@", argumentArray: array)
        let query = PFQuery(className: "Job", predicate: predicate)
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.addDescendingOrder("pDateTime")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let status = object["status"] {
                        if let pDate = object["pDateTime"] {
                            if let userId = object["from"] {
                                let userQuery = PFUser.query()
                                userQuery?.whereKey("objectId", equalTo: userId)
                                userQuery?.findObjectsInBackground(block: { (success, error) in
                                    if error != nil {
                                        print(error?.localizedDescription)
                                    } else if let users = success {
                                        for user in users {
                                            if let fName = user["firstName"] {
                                                if let lName = user["lastName"] {
                                                    self.dates.append(pDate as! NSDate)
                                                    self.statuses.append(status as! String)
                                                    self.firstNames.append(fName as! String)
                                                    self.lastNames.append(lName as! String)
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
            //self.refresher.endRefreshing()
            //self.tableView.reloadData()
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
        }
        else {
            cell.backgroundColor = .green
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
