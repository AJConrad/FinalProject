//
//  Pothole+CoreDataProperties.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/15/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pothole {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var xMove: NSNumber?
    @NSManaged var yMove: NSNumber?
    @NSManaged var zMove: NSNumber?
    @NSManaged var isConfirmed: NSNumber?
    @NSManaged var roll: NSNumber?
    @NSManaged var pitch: NSNumber?
    @NSManaged var yaw: NSNumber?
    @NSManaged var verticalAxis: String?

}
