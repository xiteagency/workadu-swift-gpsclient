//
//  ViewController.swift
//  RengineGpsClient
//
//  Created by kf on 9/30/15.
//  Copyright © 2015 xiteagency. All rights reserved.
//

import UIKit
import CoreLocation
import SocketIO

class ViewController: UIViewController, CLLocationManagerDelegate, NSStreamDelegate{
   
    // MARK: Properties
    @IBOutlet var serverStatus: UILabel!
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var serverPort: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var speed: UILabel!
    
    let socket = SocketIOClient(socketURL: "192.168.1.99:31338")
    var manager:CLLocationManager!
    



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        manager = CLLocationManager()
        manager.delegate = self

        self.socket.onAny {print("got event: \($0.event) with items \($0.items)")}
        // Socket Events
        self.socket.on("reconnectAttempt") {data, ack in
            print("socket connected")

            // Sending messages
            self.socket.emit("testEcho")

            self.socket.emit("testObject", [
                "data": true
                ])

            // Sending multiple items per message
            self.socket.emit("multTest", [1], 1.4, 1, "true",
                true, ["test": "foo"], "bar")
        }



    }

	// MARK: Actions
    @IBAction func startBtn(sender: AnyObject) {
        serverStatus.text = "Connecting..."
        self.socket.connect()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
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
        print("pos")
        socket.emit("onTrack","$$T142,865328024295627,AAA,35,36.792323,27.142585,151006124258,A,9,12,0,161,1.0,17,8078038,16884011,202|1|013B|F215,0000,|||0A37|03DD,00000001,*A0")
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

    
    

