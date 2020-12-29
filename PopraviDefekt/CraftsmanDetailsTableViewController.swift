//
//  CraftsmanDetailsTableViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/21/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

class CraftsmanDetailsTableViewController: UITableViewController {
    
    var dates = [NSDate]()
    var imageFiles = [PFFileObject]()
    var selCraftsmanId = String()
    var opis = String()
    var lokacija = String()
    var lat = Double()
    var lon = Double()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("date = \(dates[0])")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CraftsmanDetailsTableViewCell
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            if let imageData = data {
                print("here")
                if let imageToDisplay = UIImage(data: imageData) {
                    cell.imageI.image = imageToDisplay
                    print("success")
                }
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: dates[indexPath.row] as Date)
        cell.dateFinished.text = stringDate
        return cell
    }

    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    @IBAction func makeARequest(_ sender: Any) {
        let request = PFObject(className: "Job")
        request["from"] = PFUser.current()?.objectId
        request["to"] = selCraftsmanId
        request["date"] = NSDate()
        request["status"] = "active"
        request["description"] = opis
        request["location"] = lokacija
        request["lat"] = lat
        request["lon"] = lon
        request.saveInBackground { (success, error) in
            if success {
                self.displayAlert(title: "Success!", message: "You have made a request.")
            } else {
                self.displayAlert(title: "Failed", message: (error?.localizedDescription)!)
            }
        }
    }
}
