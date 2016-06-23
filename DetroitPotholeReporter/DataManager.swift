//
//  DataManager.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/10/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    let accelerometerDataTrigger = AccelerometerDataTrigger.sharedInstance
    let loginManager = LoginManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    var baseURL = "www.backendless.com"
    var verifiedPotholesArray = [bePothole]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var groupPotholesArray = [bePothole]()
    
    
    
    
    //MARK: - Local Data
    
    func fetchPotholes() -> [Pothole]? {
        let fetchRequest = NSFetchRequest(entityName: "Pothole")
        let sortDescriptor = NSSortDescriptor(key: "dateEntered", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            accelerometerDataTrigger.currentTripPotholeArray = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Pothole]
            return accelerometerDataTrigger.currentTripPotholeArray
        } catch {
            print("Error in pothole fetching")
            return nil
        }
    }
    
    
    
    //MARK: - Backendless Data
    
    func convertPotholeToBEPothole(from: Pothole) -> bePothole {
        let newPotholeConvert = bePothole()
        
        newPotholeConvert.latitude = (from.latitude?.doubleValue)!
        newPotholeConvert.longitude = (from.longitude?.doubleValue)!
        newPotholeConvert.xMove = (from.xMove?.doubleValue)!
        newPotholeConvert.yMove = (from.yMove?.doubleValue)!
        newPotholeConvert.zMove = (from.zMove?.doubleValue)!
        newPotholeConvert.isConfirmed = (from.isConfirmed?.boolValue)!
        //maybe make this one false, and have an admin mode that will make it true if a certain threshold is met
        newPotholeConvert.roll = (from.roll?.doubleValue)!
        newPotholeConvert.pitch = (from.pitch?.doubleValue)!
        newPotholeConvert.yaw = (from.yaw?.doubleValue)!
        newPotholeConvert.verticalAxis = from.verticalAxis
        newPotholeConvert.potholeGeoPoint = GeoPoint(point: GEO_POINT(latitude: newPotholeConvert.latitude, longitude: newPotholeConvert.longitude))
        
        return newPotholeConvert
    }
    
    //THIS FUNCTION IS GOING TO NEED A LOT OF CHANGE
    
    func downloadPotholes() {
        let dataQuery = BackendlessDataQuery()
        let whereClause = "ownerID = '\(loginManager.currentUser.objectId)'"
                //isConfirmed = True OR ownerID = userID
        //going to want to display either threshold ones and users own confirmed ones
        dataQuery.whereClause = whereClause
        var error: Fault?
        let bc = backendless.data.of(bePothole.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            verifiedPotholesArray = bc.getCurrentPage() as! [bePothole]
        }
        print("downloaded \(verifiedPotholesArray.count) potholes")
    }
    
    
    

    
    //THIS FUNCTION IS GOING TO NEED A LOT OF CHANGE
    
    func saveConfirmedPotholes(savingPothole: bePothole) {
        let dataStore = backendless.data.of(Pothole.ofClass())
        if savingPothole.isConfirmed == true {
            dataStore.save(savingPothole, response: { (response) in
                print("Potholes Saved")
            }) { (error) in
                print("Pothole not saved, error \(error)")
            }
        }
    }
    
}
