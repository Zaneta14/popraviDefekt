//
//  MapViewController.swift
//  PopraviDefekt
//
//  Created by Zaneta on 12/29/20.
//  Copyright © 2020 Zaneta. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var lat = Double()
    
    var lon = Double()
    
    var lok = String()

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = lok
        self.map.addAnnotation(annotation)
    }

}
