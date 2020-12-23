//
//  CraftsmanTableViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/23/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class CraftsmanTableViewController: UITableViewController {
    
    var count = Int()
    
    var fNames = [String]()
    
    var lNames = [String]()
    
    var datumi = [NSDate]()
    
    var refresher:UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(CraftsmanTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }
    
    @objc func updateTable() {
        print("updateTable")
        self.fNames.removeAll()
        self.lNames.removeAll()
        self.datumi.removeAll()
        let query = PFQuery(className: "Job")
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.whereKey("status", equalTo: "active")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let userId = object["from"] {
                        if let datum = object["date"] {
                            self.datumi.append(datum as! NSDate)
                            let userQuery = PFUser.query()
                            userQuery?.whereKey("objectId", equalTo: userId)
                            userQuery?.findObjectsInBackground(block: { (users, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else if let users = users {
                                    for user in users {
                                        if let user = user as? PFUser {
                                            if let fName = user["firstName"] {
                                                if let lName = user["lastName"] {
                                                    self.fNames.append(fName as! String)
                                                    self.lNames.append(lName as! String)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cCell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: datumi[indexPath.row] as Date)
        cell.textLabel?.text = stringDate
        cell.detailTextLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row]
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
