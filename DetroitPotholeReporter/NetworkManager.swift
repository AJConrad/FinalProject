//
//  NetworkManager.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/9/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    
    static let sharedInstance = NetworkManager()
    
    var serverReach :Reachability?
    var serverAvailable = false
    
    func reachabilityChanged(note: NSNotification) {
        let reach = note.object as! Reachability
        serverAvailable = !(reach.currentReachabilityStatus().rawValue == NotReachable.rawValue)
        if serverAvailable {
            print("Server Availible")
        } else {
            print("Server NOT Availible")
        }
    }
    
    override init() {
        super.init()
        print("Starting Network Manager")
        let dataManager = DataManager.sharedInstance
        serverReach = Reachability(hostname: dataManager.baseURL)
        serverReach?.startNotifier()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)) , name: kReachabilityChangedNotification, object: nil)
    }
    
}
