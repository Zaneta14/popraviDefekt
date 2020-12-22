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
    
    var datumiB = [NSDate]()
    
    var craftsmenIds = [String]()
    
    var statuses = [String]()
    
    var descriptions = [String]()
    
    var fNames = [String]()
    var lNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datumiB.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Kelija", for: indexPath)
        let craftsmanId = craftsmenIds[indexPath.row]
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: craftsmanId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let craftsman = object as? PFUser {
                        if let firstName = craftsman["firstName"] {
                            if let lastName = craftsman["lastName"] {
                                print(firstName)
                                print(lastName)
                                self.fNames.append(firstName as! String)
                                self.lNames.append(lastName as! String)
                            }
                        }
                    }
                }
                cell.textLabel?.text = self.fNames[indexPath.row] + " " + self.lNames[indexPath.row]
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
        fNames.removeAll()
        lNames.removeAll()
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
