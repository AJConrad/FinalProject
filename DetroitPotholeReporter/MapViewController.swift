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
    let networkManager = NetworkManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    let accelerometerDataTrigger = AccelerometerDataTrigger.sharedInstance

    @IBOutlet weak var potholeMap: MKMapView!
    
    func locationManager (manager: CLLocationManager,didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let lastLoc = newLocation
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        let potholeSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let potholeRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lastLoc.coordinate.latitude, longitude: lastLoc.coordinate.longitude), span: potholeSpan)
        potholeMap.setRegion(potholeRegion, animated: true)
        
    }
    @IBAction func zoom(sender: AnyObject) {
        zoomToPins()
        annotatePotholes()
    }
    
    func zoomToPins() {
        potholeMap.showAnnotations(potholeMap.annotations, animated: true)
    }
    
    func annotatePotholes() {
        for newAnnots in accelerometerDataTrigger.tempShakesArray  {
            var counter = 1
            if newAnnots.isConfirmed == true {
                let pinLoc = CLLocationCoordinate2DMake(newAnnots.latitude!.doubleValue, newAnnots.longitude!.doubleValue)
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = pinLoc
                dropPin.title = "\(counter)"
                potholeMap.addAnnotation(dropPin)
                counter = counter + 1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.potholeMap.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

}
