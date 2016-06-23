//
//  Pothole+CoreDataProperties.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/22/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pothole {

    @NSManaged var isConfirmed: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var pitch: NSNumber?
    @NSManaged var roll: NSNumber?
    @NSManaged var verticalAxis: String?
    @NSManaged var xMove: NSNumber?
    @NSManaged var yaw: NSNumber?
    @NSManaged var yMove: NSNumber?
    @NSManaged var zMove: NSNumber?
    @NSManaged var dateEntered: NSDate?

}
