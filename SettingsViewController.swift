//
//  SettingsViewController.swift
//  RengineGpsClient
//
//  Created by kf on 9/30/15.
//  Copyright © 2015 xiteagency. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UITableViewController{
   
    @IBOutlet var SettingsTableView: UITableView!
    @IBOutlet weak var frequencyField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var deviceField: UITextField!
        
    override func viewDidLoad() {

        super.viewDidLoad()
        
        SettingsTableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    
        //Fetch last saved configuration
        var servers = [NSManagedObject]()
        let managedContext = AppDelegate().managedObjectContext
        
        //Define fetsch entity request
        let fetchRequest = NSFetchRequest(entityName: "Configuration")
        
        // Fetch saved server data and update if any change
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            servers = results as! [NSManagedObject]
            
            if servers.count>=1 {
                let server = servers[0]
                hostField.text = server.valueForKey("host") as? String
                portField.text = String(server.valueForKey("port") as! Int)
                deviceField.text = server.valueForKey("deviceId") as? String
                frequencyField.text = String(server.valueForKey("frequency") as! Int)
            } else {
                //
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
}

    
    

