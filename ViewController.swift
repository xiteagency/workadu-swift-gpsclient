//
//  ViewController.swift
//  RengineGpsClient
//
//  Created by kf on 9/30/15.
//  Copyright © 2015 xiteagency. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate{
   
    // MARK: Properties
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var status: UILabel!
    
    var configuration = [NSManagedObject]()
    var manager:CLLocationManager!
    let socketClient = Socket()
    var device = ""
    var timer = NSTimer()
    var timerFlag = false
    var periodically = 0

    
    var locations = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage()
        
        // Do any additional setup after loading the view, typically from a nib.
        manager = CLLocationManager()
        manager.delegate = self
    }

	// MARK: Actions
    @IBAction func socketConnector(sender: UISwitch) {
        
        //Fetch last saved configuration 
        var servers = [NSManagedObject]()
        let managedContext = AppDelegate().managedObjectContext
        var host = ""
        var port = 0
        var deviceId = ""
        var frequency = 0
        
        //Define fetsch entity request
        let fetchRequest = NSFetchRequest(entityName: "Configuration")
        
        // Fetch saved server data and update if any change
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            servers = results as! [NSManagedObject]
           
            if servers.count>=1 {
                let server = servers[0]
                sender.enabled = true
                host = server.valueForKey("host") as! String
                port = server.valueForKey("port") as! Int
                deviceId = server.valueForKey("deviceId") as! String
                device = deviceId
                frequency = server.valueForKey("frequency") as! Int
                periodically = frequency
            } else {
                sender.enabled = false
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }


        if sender.on {
            self.manager.allowsBackgroundLocationUpdates = true
            self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.socketClient.open(host, port:port)
            status.text = "Host: "+host + ":" + String(port) + " Frequency: " + String(frequency) + "(sec)"
            self.socketClient.send("$$T142,"+device+",AAA,35,0.0,0.0,151006124258,A,9,12,0,161,1.0,17,8078038,16884011,202|1|013B|F215,0000,|||0A37|03DD,00000001,*A0")
            self.manager.requestWhenInUseAuthorization()
            self.manager.startUpdatingLocation()
            if frequency != 0 {
                timer = NSTimer.scheduledTimerWithTimeInterval(Double(frequency), target: self, selector: "handleTimer:", userInfo: nil, repeats: true)
            } else {
                timerFlag = true
            }
           
        } else {
            self.manager.stopUpdatingLocation()
            status.text = "No Connection"
            timerFlag = false
            timer.invalidate()
        }
	}

    func handleTimer(timer: NSTimer) {
        //CLLocation location = self.manager.location;
        timerFlag = true
        self.manager.requestLocation()
    }
    
	func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        let myCoordinates = locations[0] as CLLocation
        longitude.text = "\(myCoordinates.coordinate.longitude)"
        latitude.text = "\(myCoordinates.coordinate.latitude)"
        speed.text = "\(myCoordinates.speed)"
        heading.text = "\(myCoordinates.course)"
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYMMddHHmmss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        // -------------------PROTOCOL FORMAT (on developement)--------------------------
        // MessageIdentifier, Device Id, Accurancy, N/A, Latitude, Longitude, DateTime, Valid, Satelites, N/A, Speed, Heading, N/A, N/A, N/A, N/A, N/A, N/A, N/A, N/A, N/A
        // -------------------------------------------------------------------------------
        let protocolMessage = "$$RE100,"+device+",AAA,35,"+latitude.text!+","+longitude.text!+","+formatter.stringFromDate(date)+",A,9,12,"+speed.text!+","+heading.text!+",1.0,17,8078038,16884011,202|1|013B|F215,0000,|||0A37|03DD,00000001,*A0"

        if UIApplication.sharedApplication().applicationState == .Active {
            let annotation = MKPointAnnotation()
            annotation.coordinate = myCoordinates.coordinate
            
            // Also add to our map so we can remove old values later
            self.locations.append(annotation)
            
            // Remove values if the array is too big
            while self.locations.count > 1 {
                let annotationToRemove = self.locations.first!
                self.locations.removeAtIndex(0)
                
                // Also remove from the map
                myMapView.removeAnnotation(annotationToRemove)
            }
            myMapView.showAnnotations(self.locations, animated: true)
            
            if timerFlag {
                print("---------FOREGROUND--------------------------")
                NSLog("App is foreground. New location is %@", myCoordinates)
                socketClient.send(protocolMessage)
                print ("--------END FOREGROUND-------------------------------")
                if periodically != 0 {
                    timerFlag = false
                }
            }
            
        } else {
            if timerFlag {
                print("---------BACKGROUND--------------------------")
                NSLog("App is backgrounded. New location is %@", myCoordinates)
                socketClient.send(protocolMessage)
                print ("----------END BACKGROUND-----------------------------------")
                if periodically != 0 {
                    timerFlag = false
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    @IBAction func cancelToDetailsViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveServerDetail(segue:UIStoryboardSegue) {
       
        var host = ""
        var port = 0
        var deviceId = ""
        var frequency = 0
        
        if let SettingsViewController = segue.sourceViewController as? SettingsViewController {
            
            //Get data from seque
            host = SettingsViewController.hostField.text ?? host
            port = Int(SettingsViewController.portField.text!) ?? port
            deviceId = SettingsViewController.deviceField.text ?? deviceId
            frequency = Int(SettingsViewController.frequencyField.text!) ?? frequency
        }
        
        var servers = [NSManagedObject]()
        
        
        let managedContext = AppDelegate().managedObjectContext
        
        //Define fetch entity request
        let fetchRequest = NSFetchRequest(entityName: "Configuration")
        
        // Fetch saved server data and update if any change
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            servers = results as! [NSManagedObject]
            if servers.count > 0 {
                let server = servers[0]
                server.setValue(host, forKey: "host")
                server.setValue(port, forKey: "port")
                server.setValue(deviceId, forKey: "deviceId")
                server.setValue(frequency, forKey: "frequency")
            } else {
                let entity =  NSEntityDescription.entityForName("Configuration", inManagedObjectContext:managedContext)
                let server = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)
                server.setValue(host, forKey: "host")
                server.setValue(port, forKey: "port")
                server.setValue(deviceId, forKey: "deviceId")
                server.setValue(frequency, forKey: "frequency")
            }
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

    
    

