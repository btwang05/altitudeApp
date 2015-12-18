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

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate , NSURLSessionDelegate{

    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var lacValLabel: UILabel!
    @IBOutlet weak var longValLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var testName: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var interval: UITextField!
    
    weak var timer1: NSTimer?
    weak var timer2: NSTimer?
    
    let locationManager = CLLocationManager()
    let dataProcessingQueue = NSOperationQueue()
    let altimeter = CMAltimeter()
    let lengthFormatter = NSLengthFormatter()
    var altChange: Double = 0
    
    var lat = "ConstLat"
    var lon = "ConstLon"
    var alt = "ConstAlt"
    var bar = "ConstBar"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 20
        mapView.delegate = self
        testName.delegate = self
        duration.delegate = self
        interval.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        lengthFormatter.numberFormatter.usesSignificantDigits = false
        lengthFormatter.numberFormatter.maximumSignificantDigits = 2
        lengthFormatter.unitStyle = .Short
        
        // Prepare altimeter
        altimeter.startRelativeAltitudeUpdatesToQueue(dataProcessingQueue) {
            (data, error) in
            if error != nil {
                print("There was an error obtaining altimeter data: \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //Get a relative altitude when you start moving
                    //self.altChange += data.relativeAltitude as! Double
                    //self.altitudeLabel.text = "\(self.lengthFormatter.stringFromMeters(self.altChange))"
                    let lac = String(format:"%3.7fkPa", data!.pressure as Double)
                    //self.altChange += data!.pressure as Double
                    //self.pressureLabel.text = "\(self.lengthFormatter.stringFromMeters(self.altChange))Pa"
                    self.pressureLabel.text = lac
                    self.bar = lac
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
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
    
    //input the interval, duration, and testname into textfields before running start
    @IBAction func buttonPressed(sender: UIButton) {
        print("You clicked the button")
        let interval = NSNumberFormatter().numberFromString(self.interval.text!)?.integerValue
        let dur = (NSNumberFormatter().numberFromString(self.duration.text!)?.integerValue)
        let nextTimer = NSTimer.scheduledTimerWithTimeInterval(Double(interval!), target: self, selector: "handleIdleEvent:", userInfo: nil, repeats: true)
        self.timer1 = nextTimer
        let stopTimer = NSTimer.scheduledTimerWithTimeInterval(Double(dur!*60), target: self, selector: "stopEvent:", userInfo: nil, repeats: false)
        self.timer2 = stopTimer
    }
    
    //invalidate post requests after certain amount of time
    func stopEvent(timer: NSTimer) {
        self.timer1?.invalidate()
    }
    
    //post request
    func handleIdleEvent(timer: NSTimer) {
//        let configuration =
//        NSURLSessionConfiguration.defaultSessionConfiguration()
//        
//        var session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        
        let testName = self.testName.text
        let myUrl = NSURL(string: "http://dyn-160-39-148-163.dyn.columbia.edu:8080")
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        let date = NSDate()
        let stringDate = formatter.stringFromDate(date)
        // Compose a query string
        let postString = "testing !("+testName!+")time= "+stringDate+" lat="+self.lat+" lon="+self.lon+" alt=" + self.alt+" bar="+self.bar
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        print(request, terminator: "")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("response = \(response)")
            
            // Print out response body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations:  [CLLocation]) {
        if let location = locations.first as/*?*/ CLLocation! {
            let altitude = String(format:"%3.3fm", location.altitude)
            altitudeLabel.text = altitude
            self.alt="\(location.altitude)"
            //Update latitude and longitude
            let lac = String(format:"%3.3f", location.coordinate.latitude)
            self.lat = lac
            lacValLabel.text = lac
            let long = String(format:"%3.3f", location.coordinate.longitude)
            longValLabel.text = long
            self.lon = long
            // Re-center the map
            mapView.centerCoordinate = location.coordinate
        }
        //locationManager.stopUpdatingLocation()
        
    }
    
    //Show the map view
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
    {
        if let overlay = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: overlay)
            renderer.lineWidth = 4.0
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
            return renderer
        }
        return MKPolylineRenderer()
    }

}

