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
    let backendless = Backendless.sharedInstance()
    var baseURL = "www.backendless.com"
    var verifiedPotholesArray = [Pothole]()
    var selectedPothole : Pothole?
    
    func downloadPotholes() {
        let dataQuery = BackendlessDataQuery()
        let whereClause = "pothole.isConfirmed = '1'"
        dataQuery.whereClause = whereClause
        var error: Fault?
        let bc = backendless.data.of(Pothole.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            verifiedPotholesArray = bc.getCurrentPage() as! [Pothole]
            accelerometerDataTrigger.tempShakesArray += verifiedPotholesArray
        }
    }

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
//import UIKit
//
//class DataManager: NSObject {
//    
//    static let sharedInstance = DataManager()
//    
//    var baseURL = "www.movablebytes.com"
//    var flavorsArray = [Flavor]()
//    
//    func getDataFromServer() {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        defer {
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//        }
//        let url = NSURL(string: "http://\(baseURL)/classfiles/flavors.json")
//        let urlRequest = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
//        let urlSession = NSURLSession.sharedSession()
//        let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) in
//            guard let unwrappedData = data else {
//                print ("No Data Error")
//                return
//            }
//            do {
//                let jsonResult = try NSJSONSerialization.JSONObjectWithData(unwrappedData, options: .MutableContainers)
//                print("JSON: \(jsonResult)")
//                let tempFlavorDictArray = jsonResult.objectForKey("flavors") as! [NSDictionary]
//                self.flavorsArray.removeAll()
//                for flavorDict in tempFlavorDictArray {
//                    let newFlavor = Flavor()
//                    newFlavor.flavorName = flavorDict.objectForKey("name") as! String
//                    newFlavor.flavorImageFilename = flavorDict.objectForKey("filename") as! String
//                    newFlavor.flavorID = Int(flavorDict.objectForKey("id") as! String)
//                    let formatter = NSDateFormatter()
//                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    newFlavor.DateUpdated = formatter.dateFromString(flavorDict.objectForKey("dateUpdated") as! String)
//                    self.flavorsArray.append(newFlavor)
//                    if !self.fileIsInDocuments(newFlavor.flavorImageFilename) {
//                        let imageURLString = "http://\(self.baseURL)/classfiles/images/\(newFlavor.flavorImageFilename)"
//                        self.getImageFromServer(newFlavor.flavorImageFilename, remoteFilename: imageURLString)
//                    }
//                    dispatch_async(dispatch_get_main_queue(), {
//                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvNewDataFromServer", object: nil))
//                    })
//                    
//                }
//                print("Got \(self.flavorsArray.count)")
//            } catch {
//                print("JSON Parsing Error")
//            }
//        }
//        task.resume()
//    }
//    
//    func fileIsInDocuments(filename: String) -> Bool {
//        let fileManager = NSFileManager.defaultManager()
//        return fileManager.fileExistsAtPath(getDocumentPathForFile(filename))
//        
//    }
//    
//    func getDocumentPathForFile(filename: String) -> String {
//        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//        return documentPath.stringByAppendingPathComponent(filename)
//    }
//    
//    private func getImageFromServer(localFilename: String, remoteFilename: String) {
//        let remoteURL = NSURL(string: remoteFilename)
//        let imageData = NSData(contentsOfURL: remoteURL!)
//        let imageTemp = UIImage(data: imageData!)
//        if let _ = imageTemp {
//            imageData!.writeToFile(getDocumentPathForFile(localFilename), atomically: false)
//        }
//    }
//    
//}

