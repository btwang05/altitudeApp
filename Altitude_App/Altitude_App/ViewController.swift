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
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var lacValLabel: UILabel!
    @IBOutlet weak var longValLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    let locationManager = CLLocationManager()
    let dataProcessingQueue = NSOperationQueue()
    let altimeter = CMAltimeter()
    let lengthFormatter = NSLengthFormatter()
    var altChange: Double = 0
    
    var lat = "ConstLat"
    var lon = "ConstLon"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 20
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        lengthFormatter.numberFormatter.usesSignificantDigits = false
        lengthFormatter.numberFormatter.maximumSignificantDigits = 2
        lengthFormatter.unitStyle = .Short
        
        // Prepare altimeter
        altimeter.startRelativeAltitudeUpdatesToQueue(dataProcessingQueue) {
            (data, error) in
            if error != nil {
                println("There was an error obtaining altimeter data: \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //Get a relative altitude when you start moving
                    //self.altChange += data.relativeAltitude as! Double
                    //self.altitudeLabel.text = "\(self.lengthFormatter.stringFromMeters(self.altChange))"
                    var lac = String(format:"%3.3f", data.pressure)
                    self.pressureLabel.text = lac
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Start to measure altitude
    @IBAction func measureButton(sender: UIButton) {
        // Need to ask for the right permissions
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        println("You clicked the button")
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        println(formatter.stringFromDate(date))
        let myUrl = NSURL(string: "http://localhost:8080")
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        // Compose a query string
        let postString = "testing time="+formatter.stringFromDate(date)+"lat="+self.lat+"lon="+self.lon
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        print(request)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil
            {
                println("error=\(error)")
                return
            }
            
            // You can print out response object
            println("response = \(response)")
            
            // Print out response body
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations:  [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            altitudeLabel.text = "\(location.altitude) m"
            //Update latitude and longitude
            var lac = String(format:"%3.3f", location.coordinate.latitude)
            self.lat = lac
            lacValLabel.text = lac
            var long = String(format:"%3.3f", location.coordinate.longitude)
            longValLabel.text = long
            self.lon = long
            // Re-center the map
            mapView.centerCoordinate = location.coordinate
        }
        //locationManager.stopUpdatingLocation()
        
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

