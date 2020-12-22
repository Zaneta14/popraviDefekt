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
    var dates = [String]()
    var imageFiles = [PFFileObject]()
    var selectedCraftsmanId = String()
    var opis = String()
    var lokacija = String()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelija", for: indexPath)
        cell.textLabel?.text = fNames[indexPath.row] + " " + lNames[indexPath.row]
        
        let firstName = fNames[indexPath.row]
        let lastName = lNames[indexPath.row]
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
        let firstName = fNames[indexPath.row]
        let lastName = lNames[indexPath.row]
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
                            self.selectedCraftsmanId = objectId
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
                                                self.dates.append(datum as! String)
                                                self.imageFiles.append(slika as! PFFileObject)
                                            }
                                        }
                                    }
                                }
                            })
                            self.performSegue(withIdentifier: "craftsmanDetailsSegue", sender: nil)
                        }
                    }
                }
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "craftsmanDetailsSegue" {
            let destinationVC = segue.destination as! CraftsmanDetailsTableViewController
            destinationVC.dates = dates
            destinationVC.imageFiles = imageFiles
            destinationVC.selCraftsmanId = selectedCraftsmanId
            destinationVC.lokacija = lokacija
            destinationVC.opis = opis
            dates.removeAll()
            imageFiles.removeAll()
        }
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
