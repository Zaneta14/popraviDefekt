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
UIImagePickerControllerDelegate, UITextViewDelegate {
    
    var firstName = String()
    
    var lastName = String()
    
    var emailA = String()
    
    var phoneN = String()
    
    var statusS = String()
    
    var dateSch = NSDate()
    
    var dateFin = NSDate()
    
    var beforeImage = [PFFileObject]()
    
    var image = [PFFileObject]()
    
    var lat = Double()
    
    var lon = Double()
    
    var adresa = String()
    
    var jobId = String()
    
    var userId = String()
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var customer: UILabel!
    
    @IBOutlet weak var addess: UILabel!
    
    @IBOutlet weak var telBroj: UIButton!
    
    @IBOutlet weak var emailAdresa: UIButton!
    
    @IBOutlet weak var dateFinished: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var upload: UILabel!
    @IBOutlet weak var afterPhoto: UILabel!
    
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var or: UILabel!
    @IBOutlet weak var photoLibrary: UIButton!
    
    @IBOutlet weak var finishDate: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var save: UIButton!
    
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var comment: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comment.text = NSLocalizedString("CustomerComment", comment: "")
        comment.textColor = .darkGray
        comment.layer.borderColor = UIColor.lightGray.cgColor
        comment.layer.borderWidth = 1
        comment.layer.cornerRadius = 10
        comment.layer.masksToBounds = true
        customer.text = firstName + " " + lastName
        emailAdresa.setTitle(emailA, for: .normal)
        telBroj.setTitle(phoneN, for: .normal)
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy HH:mm"
        let strDate = format.string(from: dateSch as Date)
        dateLabel.text = strDate
        status.text = NSLocalizedString(statusS, comment: "")
        addess.text = adresa
        if statusS == "scheduled" {
            finishDate.isHidden = true
            camera.isHidden = false
            or.isHidden = false
            photoLibrary.isHidden = false
            save.isHidden = false
            datePicker.datePickerMode = .date
            datePicker.isHidden = false
            dateFinished.isHidden = false
            upload.text = NSLocalizedString("Upload an image", comment: "")
            afterPhoto.isHidden = true
            upload.isHidden = false
            comment.isHidden = false
            info.isHidden = true
        }
        else {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy"
            let strDate = format.string(from: dateFin as Date)
            finishDate.text = strDate
            upload.text = NSLocalizedString("DoneOn", comment: "")
            finishDate.isHidden = false
            dateFinished.isHidden = true
            afterPhoto.isHidden = false
            comment.isHidden = true
            camera.isHidden = true
            or.isHidden = true
            photoLibrary.isHidden = true
            save.isHidden = true
            datePicker.isHidden = true
            upload.isHidden = false
            if statusS == "done" {
                info.isHidden = true
            } else {
                info.isHidden = false
            }
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
            let alert = UIAlertController(title: NSLocalizedString("Camera alert", comment: ""), message: NSLocalizedString("No camera is available", comment: ""), preferredStyle: .alert)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.comment.resignFirstResponder()
    }
    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertOKaction) in
            self.popThisView()
        }))
        present(allertController, animated: true, completion: nil)
    }
    
    func popThisView() {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is JobsTableViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if imageView.image == nil {
            displayAlert(title: NSLocalizedString("Invalid", comment: ""), message: NSLocalizedString("ChooseImage", comment: ""))
        }
        else {
            let query = PFQuery(className: "Job")
            query.whereKey("objectId", equalTo: jobId)
            query.findObjectsInBackground { (success, error) in
                if error != nil {
                    print(error!)
                } else if let objects = success {
                    for object in objects {
                        object["finishDate"] = self.datePicker.date
                        object["status"] = "done (pending)"
                        if let image = self.imageView.image {
                            if let imageData = image.jpeg(.medium) {
                                let imageFile = PFFileObject(name: "image.jpg", data: imageData)
                                object["afterImg"] = imageFile
                                object.saveInBackground()
                            }
                        }
                    }
                }
            }
            if comment.text != "" && comment.text != "Give a comment about the customer. (optional)" && comment.text != "Дај коментар за муштеријата. (опционо)" {
                let com = comment.text
                let comQuery = PFQuery(className: "Comment")
                comQuery.whereKey("userId", equalTo: userId)
                comQuery.findObjectsInBackground(block: { (success, error) in
                    if error != nil {
                        print(error!)
                    } else if let objects = success {
                        for object in objects {
                            if let comments = object["comments"] {
                                var niza = comments as! [String]
                                niza.append(com!)
                                object["comments"] = niza
                            } else {
                                var array = [String]()
                                array.append(com!)
                                object["comments"] = array
                            }
                            object.saveInBackground()
                        }
                    }
                })
            }
            displayAlert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("CustomerConfirmation", comment: ""))
        }
    }
    
    @IBAction func makeACall(_ sender: Any) {
        let phone = telBroj.titleLabel?.text
        if let url = URL(string: "tel://\(phone!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func sendAnEmail(_ sender: Any) {
        let email = emailAdresa.titleLabel?.text
        if let url = URL(string: "mailto:\(email!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func openWhatsapp(_ sender: Any) {
        let phone =  telBroj.titleLabel?.text
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phone!)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        } else {
            displayAlert(title: NSLocalizedString("Failed", comment: ""), message: NSLocalizedString("WhatsApp is not installed.", comment: ""))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue" {
            let dVC = segue.destination as! MapViewController
            dVC.lat = lat
            dVC.lon = lon
            dVC.lok = adresa
        }
        else if segue.identifier == "popupSegue" {
            let dVC = segue.destination as! PopUpViewController
            dVC.imageFile = beforeImage
        }
    }
    
}
