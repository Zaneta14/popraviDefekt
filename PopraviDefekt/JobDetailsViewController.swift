//
//  JobDetailsViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/27/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit

class JobDetailsViewController: UIViewController {
    
    var firstName = String()
    
    var lastName = String()
    
    var emailA = String()
    
    var phoneN = String()
    
    var statusS = String()
    
    var dateSch = NSDate()
    
    var dateFin = NSDate()
    
    var image = UIImage()
    
    var lat = Double()
    
    var lon = Double()
    
    var adresa = String()
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var customer: UILabel!
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var addess: UILabel!
    
    @IBOutlet weak var dateFinished: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var upload: UILabel!
    
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var or: UILabel!
    @IBOutlet weak var photoLibrary: UIButton!
    
    @IBOutlet weak var finishDate: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var save: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
    }
    
    @IBAction func photoLibPressed(_ sender: Any) {
    }
    
    @IBAction func savePressed(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
