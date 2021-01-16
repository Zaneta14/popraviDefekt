//
//  ViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/13/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var nmb = Int()
    
    var types = [String]()
    
    var selectedTypes = [String]()
    
    var signUpMode=true
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var topButton: UIButton!
    
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet weak var ccSwitch: UISwitch!
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var craftsman: UILabel!
    
    @IBOutlet weak var customer: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        types.removeAll()
        selectedTypes.removeAll()
        let query = PFQuery(className: "CraftsmanType")
        query.findObjectsInBackground { (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let objects = success {
                self.nmb = objects.count
                for object in objects {
                    if let type = object["eng"] {
                        self.types.append(type as! String)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nmb
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "craftsmenCell", for: indexPath)
        cell.textLabel?.text = types[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        var typeT = cell?.textLabel?.text
        if cell?.accessoryType != .checkmark {
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            if !selectedTypes.contains(typeT!) {
                selectedTypes.append(typeT!)
            }
        }else {
            cell?.accessoryType = .none
            let range = 0..<selectedTypes.count
            for i in range {
                if selectedTypes[i] == typeT {
                    selectedTypes.remove(at: i)
                    break
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    
    @IBAction func switchChanged(_ sender: Any) {
        if ccSwitch.isOn {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
    }
    
    @IBAction func topButtonPressed(_ sender: Any) {
        if signUpMode {
            if emailField.text == "" || passwordField.text == "" || firstNameField.text == "" || lastNameField.text == "" || phoneNumberField.text == "" || (ccSwitch.isOn && selectedTypes.count == 0) {
                displayAlert(title: "Not enough information", message: "Please enter all information required")
            }
            else {
                launchActivityIndicator()
                let user = PFUser()
                user.username = emailField.text
                user.password = passwordField.text
                user.email = emailField.text
                user["firstName"] = firstNameField.text
                user["lastName"] = lastNameField.text
                user["phoneNumber"] = phoneNumberField.text
                if ccSwitch.isOn {
                    //majstor
                    user["role"] = "craftsman"
                    var databaseTypes = [String]()
                    let query = PFQuery(className: "CraftsmanType")
                    query.findObjectsInBackground { (success, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        } else if let objects = success {
                            for object in objects {
                                for selType in self.selectedTypes {
                                    if object["eng"] as! String == selType {
                                        if let objectId = object.objectId {
                                            databaseTypes.append(objectId)
                                        }
                                    }
                                }
                            }
                            user["crafts"] = databaseTypes
                        }
                    }
                }
                else {
                    user["role"] = "customer"
                }
                user.signUpInBackground { (success, error) in
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let error = error {
                        let errorString = error.localizedDescription
                        self.displayAlert(title: "Error signing up", message: errorString)
                    } else {
                        if PFUser.current()!["role"] as! String == "craftsman" {
                            let req = PFObject(className: "CommentCraftsman")
                            req["userId"] = PFUser.current()?.objectId
                            req.saveInBackground()
                            self.performSegue(withIdentifier: "craftsmanSegue", sender: self)
                        }
                        else {
                            let req = PFObject(className: "Comment")
                            req["userId"] = PFUser.current()?.objectId
                            req.saveInBackground()
                            self.performSegue(withIdentifier: "customerSegue", sender: self)
                        }
                    }
                }
            }
        }
        else {
            if emailField.text == "" || passwordField.text == "" {
                displayAlert(title: "Not enough information", message: "Please enter both email and password")
            }
            else {
                launchActivityIndicator()
                PFUser.logInWithUsername(inBackground: emailField.text!, password: passwordField.text!) { (user, error) in
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let error = error {
                        let errorString = error.localizedDescription
                        self.displayAlert(title: "Error logging in", message: errorString)
                    } else {
                        if user!["role"]  as! String == "craftsman" {
                            self.performSegue(withIdentifier: "craftsmanSegue", sender: self)
                        }
                        else if user!["role"] as! String == "customer" {
                            self.performSegue(withIdentifier: "customerSegue", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    @objc func launchActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        if signUpMode {
            signUpMode = false
            topButton.setTitle("Log in", for: .normal)
            bottomButton.setTitle("Switch to sign up", for: .normal)
            ccSwitch.isHidden=true
            firstNameField.isHidden=true
            lastNameField.isHidden=true
            phoneNumberField.isHidden=true
            customer.isHidden=true
            craftsman.isHidden=true
            tableView.isHidden = true
        }
        else {
            signUpMode = true
            topButton.setTitle("Sign up", for: .normal)
            bottomButton.setTitle("Switch to log in", for: .normal)
            customer.isHidden=false
            craftsman.isHidden=false
            ccSwitch.isHidden=false
            firstNameField.isHidden=false
            lastNameField.isHidden=false
            phoneNumberField.isHidden=false
            if ccSwitch.isOn {
                tableView.isHidden = false
            }
        }
    }
    
}

