//
//  ViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/13/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
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
    
    @IBOutlet weak var plumber: UISwitch!
    
    @IBOutlet weak var shoeMaker: UISwitch!
    
    @IBOutlet weak var electrician: UISwitch!
    
    @IBOutlet weak var carpenter: UISwitch!
    
    @IBOutlet weak var customer: UILabel!
    
    @IBOutlet weak var craftsman: UILabel!
    
    @IBOutlet weak var pLabel: UILabel!
    
    @IBOutlet weak var sLabel: UILabel!
    
    @IBOutlet weak var eLabel: UILabel!
    
    @IBOutlet weak var cLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.current() != nil {
            if PFUser.current()!["role"] as! String == "customer" {
                performSegue(withIdentifier: "customerSegue", sender: self)
            } else {
                performSegue(withIdentifier: "craftsmanSegue", sender: self)
            }
        }
        /*let request = PFObject(className: "Job")
        request["from"] = "BI3t6nK8Yr"
        request["to"] = "ofyiO0GyMk"
        request["pDateTime"] = NSDate()
        request["status"] = "done"
        request.saveInBackground { (success, error) in
            if success {
                //self.displayAlert(title: "Success!", message: "You have made a request.")
            } else {
                //self.displayAlert(title: "Failed", message: (error?.localizedDescription)!)
            }
        }*/
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if ccSwitch.isOn {
            plumber.isHidden=false
            shoeMaker.isHidden=false
            carpenter.isHidden=false
            electrician.isHidden=false
            pLabel.isHidden=false
            sLabel.isHidden=false
            cLabel.isHidden=false
            eLabel.isHidden=false
        }
        else {
            plumber.isHidden=true
            shoeMaker.isHidden=true
            carpenter.isHidden=true
            electrician.isHidden=true
            pLabel.isHidden=true
            sLabel.isHidden=true
            cLabel.isHidden=true
            eLabel.isHidden=true
        }
    }
    
    @IBAction func switchesChanged(_ sender: UISwitch) {
        if sender == plumber {
            if plumber.isOn {
                plumber.isOn = false
            } else {
                plumber.isOn = true
                electrician.isOn = false
                carpenter.isOn = false
                shoeMaker.isOn = false
            }
        }
        else if sender == carpenter {
            if carpenter.isOn {
                carpenter.isOn = false
            } else {
                carpenter.isOn = true
                electrician.isOn = false
                shoeMaker.isOn = false
                plumber.isOn = false
            }
        } else if sender == electrician {
            if electrician.isOn {
                electrician.isOn = false
            } else {
                electrician.isOn = true
                plumber.isOn = false
                carpenter.isOn = false
                shoeMaker.isOn = false
            }
        } else if sender == shoeMaker {
            if shoeMaker.isOn {
                shoeMaker.isOn = false
            } else {
                shoeMaker.isOn = true
                plumber.isOn = false
                carpenter.isOn = false
                electrician.isOn = false
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

    @IBAction func topButtonPressed(_ sender: Any) {
        if signUpMode {
            if emailField.text == "" || passwordField.text == "" || firstNameField.text == "" || lastNameField.text == "" || phoneNumberField.text == "" || (ccSwitch.isOn && !plumber.isOn && !carpenter.isOn && !electrician.isOn && !shoeMaker.isOn) {
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
                    var craft = String()
                    if plumber.isOn {
                        craft = "plumber"
                    } else if electrician.isOn {
                        craft = "electrician"
                    } else if carpenter.isOn {
                        craft = "carpenter"
                    } else if shoeMaker.isOn {
                        craft = "shoemaker"
                    }
                    user["craft"] = craft
                }
                else {
                    //korisnik
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
                            self.performSegue(withIdentifier: "craftsmanSegue", sender: self)
                        }
                        else {
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
            customer.isHidden=true
            craftsman.isHidden=true
            ccSwitch.isHidden=true
            firstNameField.isHidden=true
            lastNameField.isHidden=true
            phoneNumberField.isHidden=true
            plumber.isHidden=true
            shoeMaker.isHidden=true
            carpenter.isHidden=true
            electrician.isHidden=true
            pLabel.isHidden=true
            sLabel.isHidden=true
            cLabel.isHidden=true
            eLabel.isHidden=true
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
                //majstor
                plumber.isHidden=false
                shoeMaker.isHidden=false
                carpenter.isHidden=false
                electrician.isHidden=false
                pLabel.isHidden=false
                sLabel.isHidden=false
                cLabel.isHidden=false
                eLabel.isHidden=false
            }
        }
    }
    
}

