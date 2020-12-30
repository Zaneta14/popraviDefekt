//
//  JobDetailsViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/27/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import Parse

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

class JobDetailsViewController: UIViewController, UINavigationControllerDelegate,
UIImagePickerControllerDelegate {
    
    var firstName = String()
    
    var lastName = String()
    
    var emailA = String()
    
    var phoneN = String()
    
    var statusS = String()
    
    var dateSch = NSDate()
    
    var dateFin = NSDate()
    
    var image = [PFFileObject]()
    
    var lat = Double()
    
    var lon = Double()
    
    var adresa = String()
    
    var jobId = String()
    
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
        customer.text = firstName + " " + lastName
        contact.text = emailA + " " + phoneN
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy HH:mm"
        let strDate = format.string(from: dateSch as! Date)
        dateLabel.text = strDate
        status.text = statusS
        addess.text = adresa
        if statusS == "scheduled" {
            finishDate.isHidden = true
            camera.isHidden = false
            or.isHidden = false
            photoLibrary.isHidden = false
            save.isHidden = false
            datePicker.datePickerMode = .date
            datePicker.isHidden = false
            upload.isHidden = false
        }
        else {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy"
            let strDate = format.string(from: dateFin as! Date)
            finishDate.text = strDate
            finishDate.isHidden = false
            camera.isHidden = true
            or.isHidden = true
            photoLibrary.isHidden = true
            save.isHidden = true
            datePicker.isHidden = true
            upload.isHidden = true
            image[0].getDataInBackground { (data, error) in
                if let imageData = data {
                    if let imageToDisplay = UIImage(data: imageData) {
                        self.imageView.image = imageToDisplay
                    }
                }
            }
        }
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera alert", message: "No camera is available", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil) }
    }
    
    @IBAction func photoLibPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if imageView.image == nil {
            displayAlert(title: "Invalid", message: "Please select an image.")
        }
        else {
            let query = PFQuery(className: "Job")
            query.whereKey("objectId", equalTo: jobId)
            query.findObjectsInBackground { (success, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let objects = success {
                    for object in objects {
                        object["finishDate"] = self.datePicker.date
                        object["status"] = "done"
                        if let image = self.imageView.image {
                            if let imageData = image.jpeg(.medium) {
                                let imageFile = PFFileObject(name: "image.jpg", data: imageData)
                                object["imageFile"] = imageFile
                                object.saveInBackground()
                            }
                        }
                    }
                }
            }
            displayAlert(title: "Success", message: "The job is now finished.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue" {
            let dVC = segue.destination as! MapViewController
            dVC.lat = lat
            dVC.lon = lon
            dVC.lok = adresa
        }
    }
    
    
}
