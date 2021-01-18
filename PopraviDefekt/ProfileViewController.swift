//
//  ProfileViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 1/14/21.
//  Copyright © 2021 Zaneta. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var types = [String]()
    
    var typeIds = [String]()
    
    var selectedTypes = [String]()
    
    var selectedTypeIds = [String]()
    
    var nmb = Int()
    
    @IBOutlet weak var ima: UILabel!
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        types.removeAll()
        typeIds.removeAll()
        selectedTypes.removeAll()
        selectedTypeIds.removeAll()
        if PFUser.current()?["role"] as? String == "craftsman" {
            let query = PFQuery(className: "CraftsmanType")
            query.findObjectsInBackground { (success, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let objects = success {
                    self.nmb = objects.count
                    for object in objects {
                        if let type = object["eng"] {
                            self.types.append(type as! String)
                            if let typeId = object.objectId {
                                self.typeIds.append(typeId)
                                if ((PFUser.current()?["crafts"] as? [String])?.contains(typeId))! {
                                    self.selectedTypes.append(type as! String)
                                    self.selectedTypeIds.append(typeId)
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
        firstName.text = PFUser.current()?["firstName"] as? String
        lastName.text = PFUser.current()?["lastName"] as? String
        email.text = PFUser.current()?.username
        phoneNumber.text = PFUser.current()?["phoneNumber"] as? String
        if PFUser.current()?["role"] as? String == "customer" {
            tableView.isHidden = true
            ima.isHidden = true
        }
        else {
            tableView.isHidden = false
            ima.isHidden = false
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nmb
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typesCell", for: indexPath)
        cell.textLabel?.text = types[indexPath.row]
        if ((PFUser.current()?["crafts"] as? [String])?.contains(typeIds[indexPath.row]))! {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        let typeT = cell?.textLabel?.text
        if cell?.accessoryType != .checkmark {
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            if !selectedTypes.contains(typeT!) {
                selectedTypes.append(typeT!)
                let range = 0..<types.count
                for i in range {
                    if types[i] == typeT {
                        selectedTypeIds.append(typeIds[i])
                        break
                    }
                }
            }
        } else {
            cell?.accessoryType = .none
            let range = 0..<selectedTypes.count
            for i in range {
                if selectedTypes[i] == typeT {
                    selectedTypes.remove(at: i)
                    selectedTypeIds.remove(at: i)
                    break
                }
            }
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        if PFUser.current()?["role"] as! String == "craftsman" && selectedTypes.count == 0 {
            displayAlert(title: "No type selected", message: "Please select at least one craftsman type.")
        }
        else if password.text != "" || firstName.text != PFUser.current()?["firstName"] as? String || lastName.text != PFUser.current()?["lastName"] as? String || phoneNumber.text != PFUser.current()?["phoneNumber"] as? String || (PFUser.current()?["role"] as? String == "craftsman" && selectedTypeIds.sorted() != (PFUser.current()?["crafts"] as! [String]).sorted()) {
            if firstName.text != PFUser.current()?["firstName"] as? String {
                PFUser.current()?["firstName"] = firstName.text
            }
            if lastName.text != PFUser.current()?["lastName"] as? String {
                PFUser.current()?["lastName"] = lastName.text
            }
            if phoneNumber.text != PFUser.current()?["phoneNumber"] as? String {
                PFUser.current()?["phoneNumber"] = phoneNumber.text
            }
            if password.text != "" {
                PFUser.current()?.password = password.text
            }
            if PFUser.current()?["role"] as? String == "craftsman" && selectedTypeIds.sorted() != (PFUser.current()?["crafts"] as! [String]).sorted() {
                PFUser.current()?["crafts"] = selectedTypeIds
            }
            PFUser.current()?.saveInBackground()
            displayAlert(title: "Success", message: "Your profile is now updated.")
        } else {
            displayAlert(title: "No changes made", message: "You haven't made any changes.")
        }
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
}
