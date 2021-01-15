//
//  ProfileViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 1/14/21.
//  Copyright © 2021 Zaneta. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveChanges(_ sender: Any) {
    }
    
}
