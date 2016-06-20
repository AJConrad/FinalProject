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

//4 DECIMAL PLACES FOR THE POTHOLES, 11 meters difference


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tempShakesList: UITableView!
    
    let dataManager = DataManager.sharedInstance
    let networkManager = NetworkManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    let accelerometerDataTrigger = AccelerometerDataTrigger.sharedInstance
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accelerometerDataTrigger.tempShakesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let currentPothole = accelerometerDataTrigger.tempShakesArray[indexPath.row]
        
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
                cell.textLabel!.text = "Unable to resolve device facing"
            }
        }
        
        //these 4 lines were when the table was showing all movements when something went high over it
//        let formatterX = String(format: "%0.2f", currentPothole.xMove!.doubleValue)
//        let formatterY = String(format: "%0.2f", currentPothole.yMove!.doubleValue)
//        let formatterZ = String(format: "%0.2f", currentPothole.zMove!.doubleValue)
//        cell.textLabel!.text = "X \(formatterX) Y \(formatterY) Z \(formatterZ)"

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
    
    func convertPotholeToBEPothole(from: Pothole) -> bePothole {
        let newPotholeConvert = bePothole()
        
        newPotholeConvert.latitude = (from.latitude?.doubleValue)!
        newPotholeConvert.longitude = (from.longitude?.doubleValue)!
        newPotholeConvert.xMove = (from.xMove?.doubleValue)!
        newPotholeConvert.yMove = (from.yMove?.doubleValue)!
        newPotholeConvert.zMove = (from.zMove?.doubleValue)!
        newPotholeConvert.isConfirmed = (from.isConfirmed?.boolValue)!
        newPotholeConvert.roll = (from.roll?.doubleValue)!
        newPotholeConvert.pitch = (from.pitch?.doubleValue)!
        newPotholeConvert.yaw = (from.yaw?.doubleValue)!
        newPotholeConvert.verticalAxis = from.verticalAxis
        
        return newPotholeConvert
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentPothole = accelerometerDataTrigger.tempShakesArray[indexPath.row]
        if let confirmed = currentPothole.isConfirmed {
            currentPothole.isConfirmed = !confirmed.boolValue
        } else {
            currentPothole.isConfirmed = true
        }
        appDelegate.saveContext()
        dataManager.saveConfirmedPotholes(convertPotholeToBEPothole(currentPothole))
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    
    //MARK: - Core Data Methods
    
//    @IBAction func newAttitude(sender: AnyObject) {
//        //call attitude reset func here
//        let testRoll = accelerometerDataTrigger.deviceMotionManager.deviceMotion?.attitude.roll //.udata.attitude.roll
//        let testPitch = accelerometerDataTrigger.deviceMotionManager.deviceMotion?.attitude.pitch
//        let testYaw = accelerometerDataTrigger.deviceMotionManager.deviceMotion?.attitude.yaw
//        
//        print ("\(testRoll) \(testPitch) \(testYaw)")
//        
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
//    }
    
    func fetchPotholes() -> [Pothole]? {
        let fetchRequest = NSFetchRequest(entityName: "Pothole")
        do {
            accelerometerDataTrigger.tempShakesArray = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Pothole]
            return accelerometerDataTrigger.tempShakesArray
        } catch {
            print("Error in pothole fetching")
            return nil
        }
    }
    
    func finishTable() {
        fetchPotholes()
        self.tempShakesList.reloadData()
    }
    

    
    //MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        accelerometerDataTrigger.setupLocationMonitoring()
        accelerometerDataTrigger.setUpOpenEars()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        accelerometerDataTrigger.startMotionManager()
        finishTable()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(finishTable), name: accelerometerDataTrigger.motionAndTableNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
