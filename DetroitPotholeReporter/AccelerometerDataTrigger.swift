//
//  AccelerometerDataTrigger.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/14/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class AccelerometerDataTrigger: NSObject, CLLocationManagerDelegate, OEEventsObserverDelegate {
    
    static let sharedInstance = AccelerometerDataTrigger()
    
    var deviceMotionManager = CMMotionManager()
    let motionAndTableNotification = "MotionAndTableNotified"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var tempShakesArray = [Pothole]()
    var locManager = CLLocationManager()
    
    var openEarsEventsObserver :OEEventsObserver!
    
    
    
    //MARK: - Motion Methods
    
    func startMotionManager() {
        if deviceMotionManager.deviceMotionAvailable {
            deviceMotionManager.deviceMotionUpdateInterval = 0.1
            deviceMotionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                
                
                
                
                //BIG SCAREY TO DO HERE
                //move the stuff from table view over here, and add an attribute to the entity which
                //names the axis of vertical movement
                
                //
                //I think its all done here
                //
                
                //                    if (-0.3 <= currentRoll.doubleValue && currentRoll.doubleValue <= 0.3) &&
                //                        (-0.3 <= currentPitch.doubleValue && currentPitch.doubleValue <= 0.3) {
                //                        let formatterZ = String(format: "%0.2f", currentPothole.zMove!.doubleValue)
                //                        cell.textLabel!.text = "Flat Bounce in Gs: \(formatterZ)"
                //                    } else if (-0.3 <= currentRoll.doubleValue && currentRoll.doubleValue <= 0.3) &&
                //                        (-0.3 <= currentYaw.doubleValue && currentYaw.doubleValue <= 0.3) {
                //                        let formatterY = String(format: "%0.2f", currentPothole.yMove!.doubleValue)
                //                        cell.textLabel!.text = "Portrait Bounce in Gs: \(formatterY)"
                //                    } else if (1.2 <= currentRoll.doubleValue && currentRoll.doubleValue <= 1.8) &&
                //                        (-0.3 <= currentPitch.doubleValue && currentPitch.doubleValue <= 0.3) {
                //                        let formatterX = String(format: "%0.2f", currentPothole.xMove!.doubleValue)
                //                        cell.textLabel!.text = "Landscape Bounce in Gs: \(formatterX)"
                //
                
                //                    if udata.userAcceleration.x > 2.5 || udata.userAcceleration.y > 2.5 || udata.userAcceleration.z > 2.5 || udata.userAcceleration.x < -2.5 || udata.userAcceleration.y < -2.5 || udata.userAcceleration.z < -2.5 {
                //                        print("Motion")
                //                        self!.addPotholes(udata.userAcceleration.x, yMove: udata.userAcceleration.y, zMove: udata.userAcceleration.z)
                //this code was the temporary any large motion code
                
                
                //                    //below is temp for flat phone only
                //                    if udata.userAcceleration.z > 0.7 || udata.userAcceleration.z < -0.7 {
                //                        print("Bounce")
                //                        self!.addPotholes(udata.userAcceleration.x, yMove: udata.userAcceleration.y, zMove: udata.userAcceleration.z)
                //                    }
                
                
                if let udata = data {
                    let currentRoll = udata.attitude.roll, currentPitch = udata.attitude.pitch, currentYaw = udata.attitude.yaw
                    
                    if (-0.3 <= currentRoll && currentRoll <= 0.3) && (-0.3 <= currentPitch && currentPitch <= 0.3) {
                        //Z AXIS IS VERTICAL
                        if udata.userAcceleration.z > 0.6 || udata.userAcceleration.z < -0.6 {
                            self!.addPotholes(udata.userAcceleration.x, yMove: udata.userAcceleration.y, zMove: udata.userAcceleration.z, verticalAxis: "z")
                        }
                    } else if (-0.3 <= currentRoll && currentRoll <= 0.3) && (-0.3 <= currentYaw && currentYaw <= 0.3) {
                        //Y AXIS IS VERTICAL
                        if udata.userAcceleration.y > 0.6 || udata.userAcceleration.y < -0.6 {
                            self!.addPotholes(udata.userAcceleration.x, yMove: udata.userAcceleration.y, zMove: udata.userAcceleration.z, verticalAxis: "y")
                        }
                    } else if (1.2 <= currentRoll && currentRoll <= 1.8) && (-0.3 <= currentPitch && currentPitch <= 0.3) {
                        //X AXIS IS VERTICAL
                        if udata.userAcceleration.x > 0.6 || udata.userAcceleration.x < -0.6 {
                            self!.addPotholes(udata.userAcceleration.x, yMove: udata.userAcceleration.y, zMove: udata.userAcceleration.z, verticalAxis: "x")
                        }
                    }
                }
            }
        }
    }
    
    func addPotholes(xMove: Double, yMove: Double, zMove: Double, verticalAxis: String) {
        
        guard let loc = locManager.location else {
            return
        }
        
        let entityDescription = NSEntityDescription.entityForName("Pothole", inManagedObjectContext: managedObjectContext)
        let newShake = Pothole(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        newShake.xMove = xMove
        newShake.yMove = yMove
        newShake.zMove = zMove
        newShake.roll = deviceMotionManager.deviceMotion?.attitude.roll
        newShake.pitch = deviceMotionManager.deviceMotion?.attitude.pitch
        newShake.yaw = deviceMotionManager.deviceMotion?.attitude.yaw
        newShake.latitude = loc.coordinate.latitude
        newShake.longitude = loc.coordinate.longitude
        determineVerticalAxis()
        newShake.verticalAxis = verticalAxis
        print("Added Pothole vert \(verticalAxis)")
        appDelegate.saveContext()
        NSNotificationCenter.defaultCenter().postNotificationName(motionAndTableNotification, object: self)
        
    }
    
    func determineVerticalAxis() {
        var verticalAxis = ""
        if (-0.3 <= deviceMotionManager.deviceMotion?.attitude.roll && deviceMotionManager.deviceMotion?.attitude.roll <= 0.3) && (-0.3 <= deviceMotionManager.deviceMotion?.attitude.pitch && deviceMotionManager.deviceMotion?.attitude.pitch <= 0.3) {
            verticalAxis = "z"
            } else if (-0.3 <= deviceMotionManager.deviceMotion?.attitude.roll && deviceMotionManager.deviceMotion?.attitude.roll <= 0.3) && (-0.3 <= deviceMotionManager.deviceMotion?.attitude.yaw && deviceMotionManager.deviceMotion?.attitude.yaw <= 0.3) {
            verticalAxis = "y"
            } else if (1.2 <= deviceMotionManager.deviceMotion?.attitude.roll && deviceMotionManager.deviceMotion?.attitude.roll <= 1.8) && (-0.3 <= deviceMotionManager.deviceMotion?.attitude.pitch && deviceMotionManager.deviceMotion?.attitude.pitch <= 0.3) {
            verticalAxis = "x"
            print ("func determineVert \(verticalAxis)")
        }
        
    }
    

    //MARK: - Location Methods
    
    func turnOnLocationMonitoring() {
        locManager.startMonitoringSignificantLocationChanges()
    }
    
    func setupLocationMonitoring() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()
        if CLLocationManager.locationServicesEnabled() {
            print("Location Service Enabled")
            switch CLLocationManager .authorizationStatus() {
            case .AuthorizedAlways:
                turnOnLocationMonitoring()
                break
            case .AuthorizedWhenInUse:
                turnOnLocationMonitoring()
                break
            case .NotDetermined:
                locManager .requestWhenInUseAuthorization()
                locManager .requestAlwaysAuthorization()
                break
            case .Restricted:
                print("Restricted")
                break
            case .Denied:
                print("Denied")
                break
            }
        } else {
            print("Turn on location services in settings")
        }
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        //let lastLoc = locations.last!
//        //print("Loc: \(lastLoc.coordinate.latitude),\(lastLoc.coordinate.longitude)")
//    }
    
    
    //MARK: - Verification Methods
    
    func setUpOpenEars() {
        print("setup open ears")
        let lmGenerator = OELanguageModelGenerator()
        let words = ["POTHOLE","POT HOLE","POT","HOLE","WHOLE","FALSE", "TRUE"]
        let name = "WordFiles"
        let oeModel = OEAcousticModel.pathToModel("AcousticModelEnglish")
        let err = lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: oeModel)
        
        var lmPath :String?
        var dictPath :String?
        if err == nil {
            lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
            dictPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
        } else {
            print("Error \(err)")
        }
        
        let sphinxController = OEPocketsphinxController.sharedInstance()
        do {
            try sphinxController.setActive(true)
        } catch {
            print("Sphinx Error")
        }
        sphinxController.secondsOfSilenceToDetect = 0.2
        sphinxController.startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dictPath, acousticModelAtPath: oeModel, languageModelIsJSGF: false)
        openEarsEventsObserver = OEEventsObserver()
        openEarsEventsObserver.delegate = self
        
    }
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        
        if Int(recognitionScore) > -30000 {
            switch hypothesis {
            case "POTHOLE", "POT HOLE", "POT", "WHOLE", "HOLE", "YES", "NO":
                print("Pothole")
                addPotholes((deviceMotionManager.deviceMotion?.userAcceleration.x)!, yMove: (deviceMotionManager.deviceMotion?.userAcceleration.y)!, zMove: (deviceMotionManager.deviceMotion?.userAcceleration.z)!, verticalAxis: "")
            case "FALSE", "NO":
                print("False")
                tempShakesArray[tempShakesArray.count - 1].isConfirmed = false
            case "TRUE", "YES":
                print("True")
                tempShakesArray[tempShakesArray.count - 1].isConfirmed = true
                //CHANGE THESE TO SAVE AND CONVERT
            default:
                print("Didn't hear match, but got \(hypothesis) confidently \(recognitionScore)")
                //Add something where the phone says "Say either "Pothole" or "False"
            }
            NSNotificationCenter.defaultCenter().postNotificationName(motionAndTableNotification, object: self)
        } else {
            print ("The recieved hypothesis is \(hypothesis) with a score of \(recognitionScore) and an ID of \(utteranceID)")
            //Add something where the phone says "Say either "Pothole" or "False"
        }
        
    }
}