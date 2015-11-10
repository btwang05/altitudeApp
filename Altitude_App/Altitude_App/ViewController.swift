//
//  ViewController.swift
//  Altitude_App
//
//  Created by Boyu Wang on 10/15/15.
//  Copyright (c) 2015 Boyu Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var lacValLabel: UILabel!
    @IBOutlet weak var longValLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 20
        mapView.delegate = self
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Start to measure altitude
    @IBAction func measureButton(sender: UIButton) {
        // Need to ask for the right permissions
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations:  [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            altitudeLabel.text = "\(location.altitude) m"
            //Update latitude and longitude
            var lac = String(format:"%3.3f", location.coordinate.latitude)
            lacValLabel.text = lac
            var long = String(format:"%3.3f", location.coordinate.longitude)
            longValLabel.text = long
            // Re-center the map
            mapView.centerCoordinate = location.coordinate
        }
        locationManager.stopUpdatingLocation()
        
    }
    
    //Show the map view
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let overlay = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: overlay)
            renderer.lineWidth = 4.0
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
            return renderer
        }
        return nil
    }

}

