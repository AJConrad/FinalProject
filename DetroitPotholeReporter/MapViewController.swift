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
        //FILL OUT THIS SHIT
    }
    
    @IBAction func zoom(sender: AnyObject) {
        zoomToPins()
        annotatePotholes()
    }
    
    func zoomToPins() {
        potholeMap.showAnnotations(potholeMap.annotations, animated: true)
        //fix zoom to be around current location. Farther out zoom than what is normal for just zooming to current loc though
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation != mapView.userLocation {
        let reuseIdentifier = "pin"
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pin!.pinTintColor = UIColor.blueColor()
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton(type: .ContactAdd)
        } else {
            pin!.annotation = annotation
        }
        return pin
        }
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
