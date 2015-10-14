//
//  ViewController.swift
//  RengineGpsClient
//
//  Created by kf on 9/30/15.
//  Copyright © 2015 xiteagency. All rights reserved.
//

import UIKit
import CoreLocation
//import SocketIO

class ViewController: UIViewController, CLLocationManagerDelegate{
   
    // MARK: Properties
    @IBOutlet var serverStatus: UILabel!
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var serverPort: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var dscr: UILabel!
    
    var manager:CLLocationManager!
    let socketClient = Socket()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        manager = CLLocationManager()
        manager.delegate = self

    }


// let qualityOfServiceClass = QOS_CLASS_BACKGROUND
// let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
// dispatch_async(backgroundQueue, {
//     println("This is run on the background queue")

//    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//         println("This is run on the main queue, after the previous code in outer block")
//     })
// })
	// MARK: Actions
    @IBAction func startBtn(sender: AnyObject) {
        serverStatus.text = "Connecting..."
        //let host = "192.168.1.99"
        let host = "5.189.190.98"
        let port = 31338
      
        let qualityOfServiceClass = Int(QOS_CLASS_USER_INITIATED.rawValue)
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            self.socketClient.open(host, port:port)
            self.socketClient.send("$$T142,123435,AAA,35,36.792323,27.142585,151006124258,A,9,12,0,161,1.0,17,8078038,16884011,202|1|013B|F215,0000,|||0A37|03DD,00000001,*A0")
        
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.requestWhenInUseAuthorization()
            self.manager.startUpdatingLocation()
        
        })

	}

	func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        serverStatus.text = "-"
        serverStatus.text = "Connected!"
        let myCoordinates = locations[0] as CLLocation
        // let locationInfo = locations[1] as CLLocation
        longitude.text = "\(myCoordinates.coordinate.longitude)"
        latitude.text = "\(myCoordinates.coordinate.latitude)"
        speed.text = "\(myCoordinates.speed)"
        heading.text = "\(myCoordinates.course)"
        dscr.text = "\(myCoordinates.description)"
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYMMddHHmmss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        socketClient.send("$$T142,123435,AAA,35,"+latitude.text!+","+longitude.text!+","+formatter.stringFromDate(date)+",A,9,12,"+speed.text!+","+heading.text!+",1.0,17,8078038,16884011,202|1|013B|F215,0000,|||0A37|03DD,00000001,*A0")
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

    
    

