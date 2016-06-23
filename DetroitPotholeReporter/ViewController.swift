//
//  ViewController.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/8/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit
import CoreData

//TO ASK TOM LIST:

//ADD BUTTON THAT DELETES CORE DATA (the current trip array)
//IMPLEMENT GEOPOINT CLUSTERING, IF CLUSTER CONTAINS 4 FLAG AS POTHOLE
//MOVE CURRENT BACKENDLESS ADDITION TO BUTTON TO ENABLE OFFLINE USAGE
//ONLY ALLOW LOGGED IN USERS TO SUBMIT POTHOLE DATA
//WHY ISNT MY USER LOCATION WORKING




//INFORMATION ON ATTITUDE
//        //when the phone is flat, with the top facing ahead, all are close to 0. when top faces left, yaw
//        //is about -1.75(-1.6). facing backward, yaw is 2.8(3.1). when facing left yaw is 1.2(1.5)
//
//        //when phone is held top vertically in portrait, roll and yaw are close to 0, pitch is close to 1.5(1.4)
//        //when phone is held in landscape, top right, roll is 1.5, pitch is 0, yaw is -2(-1.65)
//        //when upside down portrait, roll is 0, pitch is -1.5, yaw is 2.5(2.9)
//        //when landscape top left, pitch is -1.5(-1.4), roll  is 0, yaw is 1.1(1.5)
//
//        //this first test run is going to be all flat. phone facing right. But later I may need to take
//        //these into account, and maybe have to do a reset whenever phone is secured.

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tempShakesList: UITableView!
    
    let dataManager = DataManager.sharedInstance
    let networkManager = NetworkManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    let accelerometerDataTrigger = AccelerometerDataTrigger.sharedInstance
    let voiceRecognizer = VoiceRecognizer.sharedInstance
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBAction func submitEndList(sender: AnyObject) {
        //FILL THIS SHIT OUT
    }
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accelerometerDataTrigger.currentTripPotholeArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let currentPothole = accelerometerDataTrigger.currentTripPotholeArray[indexPath.row]
        
        if let currentAxis = currentPothole.verticalAxis {
            if currentAxis == "z" {
                let formatterZ = String(format: "%0.2f", currentPothole.zMove!.doubleValue)
                cell.textLabel!.text = "Flat Bounce in Gs: \(formatterZ)"
            } else if currentAxis == "y" {
                let formatterY = String(format: "%0.2f", currentPothole.yMove!.doubleValue)
                cell.textLabel!.text = "Portrait Bounce in Gs: \(formatterY)"
            } else if currentAxis == "x" {
                let formatterX = String(format: "%0.2f", currentPothole.xMove!.doubleValue)
                cell.textLabel!.text = "Landscape Bounce in Gs: \(formatterX)"
            } else {
                cell.textLabel!.text = "Unable to resolve device attitude"
            }
        }
        
        if let lat = currentPothole.latitude, lon = currentPothole.longitude {
            cell.detailTextLabel!.text = "\(String(format: "%0.6f",lat.doubleValue)), \(String(format: "%0.6f",lon.doubleValue))"
        } else {
            cell.detailTextLabel!.text = ""
        }
        
        cell.backgroundColor = UIColor.clearColor()
        if let confirmed = currentPothole.isConfirmed {
            if confirmed.boolValue {
                cell.backgroundColor = UIColor.greenColor()
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentPothole = accelerometerDataTrigger.currentTripPotholeArray[indexPath.row]
        if let confirmed = currentPothole.isConfirmed {
            currentPothole.isConfirmed = !confirmed.boolValue
        } else {
            currentPothole.isConfirmed = true
        }
        appDelegate.saveContext()
        dataManager.saveConfirmedPotholes(dataManager.convertPotholeToBEPothole(currentPothole))
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func finishTable() {
        dataManager.fetchPotholes()
        self.tempShakesList.reloadData()
    }
    
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accelerometerDataTrigger.setupLocationMonitoring()
        //speech recognizer off because I fucking hate how sucky it is
        //voiceRecognizer.setUpOpenEars()
        print("View Did Load")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        accelerometerDataTrigger.startMotionManager()
        finishTable()
        dataManager.downloadPotholes()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(finishTable), name: accelerometerDataTrigger.motionAndTableNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(finishTable), name: voiceRecognizer.motionAndTableNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
