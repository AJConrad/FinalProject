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
    
//    func searchingDataObjectByDistance() {
//        
//        Types.tryblock({ () -> Void in
//            
//            let queryOptions = QueryOptions()
//            queryOptions.relationsDepth = 1;
//            
//            let dataQuery = BackendlessDataQuery()
//            dataQuery.queryOptions = queryOptions;
//            dataQuery.whereClause = "distance( 30.26715, -97.74306, Coordinates.latitude, Coordinates.longitude ) < mi(200)"
//            
//            let friends = self.backendless.persistenceService.find(Friend.ofClass(),
//                dataQuery:dataQuery) as BackendlessCollection
//            for friend in friends.data as! [Friend] {
//                let info = friend.coordinates!.metadata["description"] as! String
//                print("\(friend.name) lives at \(friend.coordinates!.latitude),
//                    \(friend.coordinates!.longitude) tagged as '\(info)'")
//            }
//            },
//                       catchblock: { (exception) -> Void in
//                        print("searchingDataObjectByDistance (FAULT): \(exception as! Fault)")
//        })
//    }
    
//    func downloadPotholesByDistance() {
//        
//        Types.tryblock({ () -> Void in
//            
//            let queryOptions = QueryOptions()
//            queryOptions.relationsDepth = 1
//            
//            let dataQuery = BackendlessDataQuery()
//            dataQuery.queryOptions = queryOptions
//            dataQuery.whereClause = "distance(latitude, longitude, Coordinates.latitude, Coordinates.longitude ) < mi(0.00379)"
//            print("Going to search for multiple reports")
//                
//            let groupPotholes = self.backendless.persistenceService.find(bePothole.ofClass(), dataQuery: dataQuery) as BackendlessCollection
//            print("This is where the for loop is")
////            for groupPothole in groupPotholes.data {
////                self.groupPotholesArray = groupPothole as! [bePothole]
////                print ("\(self.groupPotholesArray.count)")
////                print("Searched for multiple reports")
////            }
//
//            
//            }, catchblock: { (exception) -> Void in
//                print("searchingDataObjectByDistance (FAULT): \(exception as! Fault)")
//        })
//    }
    
    func getClusterGeoPoints() {
        let currentLocationGeoPoint = (point: GEO_POINT(latitude: (accelerometerDataTrigger.locManager.location?.coordinate.latitude)!, longitude: (accelerometerDataTrigger.locManager.location?.coordinate.longitude)!))
        let query = BackendlessGeoQuery.queryWithPoint(currentLocationGeoPoint, radius: 20, units: MILES) as! BackendlessGeoQuery
        query.setClusteringParams(-83.350, eastLongitude: -82.818, mapWidth: 480)
        let points = backendless.geoService.getPoints(query)
        print("Loaded geo points and clusters: \(points)")
        for point in points.data {
            if point is GeoCluster {
                let clusterPoints = backendless.geoService.getClusterPoints(point as! GeoCluster)
                print("Cluster points: \(clusterPoints)")
            }
        }
    }
    

    
//    func getClusterGeoPoints() {
//        
//        Types.try({ () -> Void in
//        
//        var query = BackendlessGeoQuery.queryWithCategories(["City"]) as BackendlessGeoQuery
//        query.setClusteringParams(-157.9 , eastLongitude: -157.8, mapWidth: 480)
//        var points = self.backendless.geoService.getPoints(query)
//        println("Loaded geo points and clusters: \(points)")
//        
//        for point in points.data {
//        if point is GeoCluster {
//        var clusterPoints = self.backendless.geoService.getClusterPoints(point as GeoCluster)
//        println("Cluster points: \(clusterPoints)")
//        }
//        }
//        },
//        
//        catch: { (exception) -> Void in
//        println("Server reported an error: \(exception as Fault)")
//        } 
//        ) 
//    }
    

    
//    func downloadPotholesExceptRadius() {
//        for bePotholeRadius in verifiedPotholesArray {
//            let currentPoint = GEO_POINT.init(latitude: bePotholeRadius.latitude, longitude: bePotholeRadius.longitude)
//            BackendlessGeoQuery.queryWithPoint(currentPoint).radius(11)
//            
//        }
//
//    }
    
//    GEO_POINT center;
//    center.latitude = 41.38;
//    center.longitude = 2.15;
//    BackendlessGeoQuery *query = [BackendlessGeoQuery queryWithPoint:center radius:100000 units:METERS categories:@[@"Restaurants"]];
//    [backendless.geoService getPoints:query response:^(BackendlessCollection *collection) {
//    NSLog(@"%@", collection.data);
//    } error:^(Fault *error) {
//    NSLog(@"%@", error.detail);
//    }];
    
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
