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

class AccelerometerDataTrigger: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = AccelerometerDataTrigger()
    
    var deviceMotionManager = CMMotionManager()
    let motionAndTableNotification = "AccelMotionAndTableNotified"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var currentTripPotholeArray = [Pothole]()
    var locManager = CLLocationManager()
    
    
    //ADIVCE: Possibly get rid of confirm function
    
    //MARK: - Motion Methods
    
    func startMotionManager() {
        if deviceMotionManager.deviceMotionAvailable {
            deviceMotionManager.deviceMotionUpdateInterval = 0.1
            deviceMotionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                
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
        
        let date1 = currentTripPotholeArray.last?.dateEntered
        let date2 = NSDate().dateByAddingTimeInterval(-5)
        if date1?.compare(date2) == NSComparisonResult.OrderedAscending {

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
            newShake.dateEntered = NSDate()
            determineVerticalAxis()
            newShake.verticalAxis = verticalAxis
            print("Added Pothole vert \(newShake.verticalAxis)")
            appDelegate.saveContext()
            NSNotificationCenter.defaultCenter().postNotificationName(motionAndTableNotification, object: self)
        }
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
}
