//
//  MapViewController.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/15/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let dataManager = DataManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    let accelerometerDataTrigger = AccelerometerDataTrigger.sharedInstance
    var clusterPointArray = [GeoCluster]()
    
    @IBOutlet weak var potholeMap: MKMapView!
    
    
    
    //MARK: - Interactivity Methods
    
    @IBAction func submitEndMap(sender: AnyObject) {
        groupGeoPoints()
//        annotateClusters()
    }
    
    @IBAction func zoom(sender: AnyObject) {
        zoomToPins()
        annotatePotholes()

    }
    
    func zoomToPins() {
        potholeMap.showAnnotations(potholeMap.annotations, animated: true)
        //fix zoom to be around current location. Farther out zoom than what is normal for just zooming to current loc though
    }
    
    
    
    //MARK: - GeoPoint Grouping
    
    func groupGeoPoints () {
        //number of pixels wide the map currently is
        let mapWidthInPixels = Double(potholeMap.bounds.size.width)
        //the xy point of the top right corner
        let nePoint = CGPointMake(self.potholeMap.bounds.origin.x + potholeMap.bounds.size.width, potholeMap.bounds.origin.y)
        //the xy point of the bottom left corner
        let swPoint = CGPointMake((self.potholeMap.bounds.origin.x), (potholeMap.bounds.origin.y + potholeMap.bounds.size.height))
        //the lat/lon of the top right corner
        let neCoord = potholeMap.convertPoint(nePoint, toCoordinateFromView: potholeMap)
        //the lat/lon of the bottom left corner
        let swCoord = potholeMap.convertPoint(swPoint, toCoordinateFromView: potholeMap)
        //the number of degrees the map width currently is
        let mapDegreeWidth = neCoord.longitude - swCoord.longitude
        //the number of clusters wide the map is
        let potholeGroupUnitsWidth = mapDegreeWidth / 0.0001
        //the number of pixels per cluster
        var pixelWidthPerCluster = mapWidthInPixels / potholeGroupUnitsWidth
        if pixelWidthPerCluster <= 1.0 {
            pixelWidthPerCluster = 1.0
            //This is a very inelegant solution and will preclude users from sending data to the city. 
            //But that is where I was going with this. I wanted to have an admin function to prevent junk.
            //So Think about this one later.
        }
        
        
//  TEST PRINTS TO MAKE SURE DATA LOOKS REASONABLE
//        print ("\(nePoint)")
//        print ("\(swPoint)")
//        print ("\(neCoord)")
//        print ("\(swCoord)")
//        print ("\(mapWidthInPixels)")
//        print ("\(mapDegreeWidth)")
//        print ("\(potholeGroupUnitsWidth)")
        print ("\(pixelWidthPerCluster)")
    
        
        let currentLocationGeoPoint = (point: GEO_POINT(latitude: (accelerometerDataTrigger.locManager.location?.coordinate.latitude)!, longitude: (accelerometerDataTrigger.locManager.location?.coordinate.longitude)!))
        let query = BackendlessGeoQuery.queryWithPoint(currentLocationGeoPoint, radius: 3500, units: MILES) as! BackendlessGeoQuery

        query.setClusteringParams(swCoord.longitude, eastLongitude: neCoord.longitude, mapWidth: Int32(mapWidthInPixels), clusterGridSize: Int32(pixelWidthPerCluster))
        //These ints seem like a bad idea, but whatever. Is this casting method correct?
        let points = backendless.geoService.getPoints(query)
        print("Loaded geo points and clusters: \(points)")
        for point in points.data {
            if point is GeoCluster {
                let clusterPoint = point as! GeoCluster
                print("***point***\(clusterPoint.latitude),\(clusterPoint.longitude)***")
                let pinLoc = CLLocationCoordinate2DMake(clusterPoint.latitude.doubleValue, clusterPoint.longitude.doubleValue)
                print ("\(pinLoc)")
                //need to make the cluster points data auctually cluster points first
                let dropPin = PotholeAnnotation()
                dropPin.pinType = "Cluster"
                dropPin.coordinate = pinLoc
                dropPin.title = "Crowd Verified Road Condition"
                potholeMap.addAnnotation(dropPin)


//                let clusterPoints = backendless.geo.getClusterPoints(GeoCluster.)
//                //let clusterPoints = backendless.geoService.getClusterPoints(point as! GeoCluster)
//                if clusterPoints.totalObjects.doubleValue > 2 {
//                    clusterPointArray = clusterPoints.getCurrentPage() as! [GeoCluster]
//                    print("TEST TEST TEST TEST TEST TEST TEST TEST \(clusterPointArray)")
//                    annotateClusters()
//                    print("Should Annotate Clusters")
//                }
            }
        }
    }

//    func downloadPotholes() {
//        let dataQuery = BackendlessDataQuery()
//        let whereClause = "ownerID = '\(loginManager.currentUser.objectId)'"
//        //isConfirmed = True OR ownerID = userID
//        //going to want to display either threshold ones and users own confirmed ones
//        dataQuery.whereClause = whereClause
//        var error: Fault?
//        let bc = backendless.data.of(bePothole.ofClass()).find(dataQuery, fault: &error)
//        if error == nil {
//            verifiedPotholesArray = bc.getCurrentPage() as! [bePothole]
//        }
//        print("downloaded \(verifiedPotholesArray.count) potholes")
//    }
    
    
    //MARK: - Location and Map Methods
    
    func locationManager (manager: CLLocationManager,didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let lastLoc = newLocation
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        let potholeSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let potholeRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lastLoc.coordinate.latitude, longitude: lastLoc.coordinate.longitude), span: potholeSpan)
        potholeMap.setRegion(potholeRegion, animated: true)
    }
    
    func annotatePotholes() {
        for newAnnots in accelerometerDataTrigger.currentTripPotholeArray {
            if newAnnots.isConfirmed == true {
                let pinLoc = CLLocationCoordinate2DMake(newAnnots.latitude!.doubleValue, newAnnots.longitude!.doubleValue)
                let dropPin = PotholeAnnotation()
                dropPin.pinType = "Pothole"
                dropPin.coordinate = pinLoc
                dropPin.title = "\(accelerometerDataTrigger.currentTripPotholeArray.indexOf(newAnnots))"
                potholeMap.addAnnotation(dropPin)
            }
        }
        for crowdAnnots in dataManager.verifiedPotholesArray {
            let crowdPinLoc = CLLocationCoordinate2DMake(crowdAnnots.latitude, crowdAnnots.longitude)
            let crowdDropPin = PotholeAnnotation()
            crowdDropPin.pinType = "Pothole"
            crowdDropPin.coordinate = crowdPinLoc
            crowdDropPin.title = "\(dataManager.verifiedPotholesArray.indexOf(crowdAnnots))"
            potholeMap.addAnnotation(crowdDropPin)
        }
    }
    
    func annotateClusters() {
        print ("Number of clusters \(clusterPointArray.count)")
        for clusterAnnots in clusterPointArray {
            let pinLoc = CLLocationCoordinate2DMake(clusterAnnots.latitude.doubleValue, clusterAnnots.longitude.doubleValue)
            print ("\(pinLoc)")
            //need to make the cluster points data auctually cluster points first
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = pinLoc
            dropPin.title = "Crowd Verified Road Condition \(clusterPointArray.indexOf(clusterAnnots))"
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        } else {
            let reuseIdentifier = "Pin"
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
            if pin == nil {
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                pin!.pinTintColor = UIColor.purpleColor()
                if annotation is PotholeAnnotation {
                    let phAnnotation = annotation as! PotholeAnnotation
                    if phAnnotation.pinType == "Pothole" {
                        pin!.pinTintColor = UIColor.blueColor()
                    } else if phAnnotation.pinType == "Cluster" {
                        pin!.pinTintColor = UIColor.greenColor()
                    }
                }
                pin!.canShowCallout = true
            } else {
                pin!.annotation = annotation
            }
            return pin

        }
//        else if annotation is GeoPoint {
//            let reuseIdentifier = "Pin"
//            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
//            if pin == nil {
//                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//                pin!.pinTintColor = UIColor.redColor()
//                pin!.canShowCallout = false
//            } else {
//                pin!.annotation = annotation
//            }
//        }
        return nil
    }


    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.potholeMap.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
