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
    
    @IBOutlet weak var potholeMap: MKMapView!
    
    
    
    //MARK: - Interactivity Methods
    
    @IBAction func submitEndMap(sender: AnyObject) {
        groupGeoPoints()
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
        let pixelWidthPerCluster = mapWidthInPixels / potholeGroupUnitsWidth
        
        
//  TEST PRINTS TO MAKE SURE DATA LOOKS REASONABLE
//        print ("\(nePoint)")
//        print ("\(swPoint)")
//        print ("\(neCoord)")
//        print ("\(swCoord)")
//        print ("\(mapWidthInPixels)")
//        print ("\(mapDegreeWidth)")
//        print ("\(potholeGroupUnitsWidth)")
//        print ("\(pixelWidthPerCluster)")
    
        
        let currentLocationGeoPoint = (point: GEO_POINT(latitude: (accelerometerDataTrigger.locManager.location?.coordinate.latitude)!, longitude: (accelerometerDataTrigger.locManager.location?.coordinate.longitude)!))
        let query = BackendlessGeoQuery.queryWithPoint(currentLocationGeoPoint, radius: 200, units: YARDS) as! BackendlessGeoQuery
        query.setClusteringParams(swCoord.longitude, eastLongitude: neCoord.longitude, mapWidth: Int32(mapWidthInPixels), clusterGridSize: Int32(pixelWidthPerCluster))
        //These ints seem like a bad idea, but whatever. Is this casting method correct?
        let points = backendless.geoService.getPoints(query)
        print("Loaded geo points and clusters: \(points)")
        for point in points.data {
            if point is GeoCluster {
                let clusterPoints = backendless.geoService.getClusterPoints(point as! GeoCluster)
                print("Cluster points: \(clusterPoints)")
            }
        }
    }

    
    
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
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = pinLoc
                dropPin.title = "\(accelerometerDataTrigger.currentTripPotholeArray.indexOf(newAnnots))"
                potholeMap.addAnnotation(dropPin)
            }
        }
        for crowdAnnots in dataManager.verifiedPotholesArray {
            let crowdPinLoc = CLLocationCoordinate2DMake(crowdAnnots.latitude, crowdAnnots.longitude)
            let crowdDropPin = MKPointAnnotation()
            crowdDropPin.coordinate = crowdPinLoc
            crowdDropPin.title = "\(dataManager.verifiedPotholesArray.indexOf(crowdAnnots))"
            potholeMap.addAnnotation(crowdDropPin)
        }
    }
    
    func potholeMap(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation != mapView.userLocation {
            let reuseIdentifier = "Pin"
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
            if pin == nil {
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                pin!.pinTintColor = UIColor.blueColor()
                pin!.canShowCallout = true
            } else {
                pin!.annotation = annotation
            }
            return pin
//        }
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
