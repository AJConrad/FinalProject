//
//  VoiceRecognizer.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/20/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit

class VoiceRecognizer: NSObject, CLLocationManagerDelegate, OEEventsObserverDelegate {
    
    static let sharedInstance = VoiceRecognizer()
    let accelerometerDataTrigger = AccelerometerDataTrigger.sharedInstance
    
    var openEarsEventsObserver :OEEventsObserver!
    let motionAndTableNotification = "VoiceMotionAndTableNotified"
    
    func setUpOpenEars() {
        print("setup open ears")
        let lmGenerator = OELanguageModelGenerator()
        let words = ["POTHOLE","POT HOLE","POT","HOLE","WHOLE","FALSE", "TRUE"]
        let name = "WordFiles"
        let oeModel = OEAcousticModel.pathToModel("AcousticModelEnglish")
        let err = lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: oeModel)
        
        var lmPath :String?
        var dictPath :String?
        if err == nil {
            lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
            dictPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
        } else {
            print("Error \(err)")
        }
        
        let sphinxController = OEPocketsphinxController.sharedInstance()
        do {
            try sphinxController.setActive(true)
        } catch {
            print("Sphinx Error")
        }
        sphinxController.secondsOfSilenceToDetect = 0.2
        sphinxController.startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dictPath, acousticModelAtPath: oeModel, languageModelIsJSGF: false)
        openEarsEventsObserver = OEEventsObserver()
        openEarsEventsObserver.delegate = self
        
    }
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        
        if Int(recognitionScore) > -30000 {
            switch hypothesis {
            case "POTHOLE", "POT HOLE", "POT", "WHOLE", "HOLE", "YES", "NO":
                print("Pothole")
                accelerometerDataTrigger.addPotholes((accelerometerDataTrigger.deviceMotionManager.deviceMotion?.userAcceleration.x)!, yMove: (accelerometerDataTrigger.deviceMotionManager.deviceMotion?.userAcceleration.y)!, zMove: (accelerometerDataTrigger.deviceMotionManager.deviceMotion?.userAcceleration.z)!, verticalAxis: "")
            case "FALSE", "NO":
                print("False")
                accelerometerDataTrigger.currentTripPotholeArray[accelerometerDataTrigger.currentTripPotholeArray.count - 1].isConfirmed = false
            case "TRUE", "YES":
                print("True")
                accelerometerDataTrigger.currentTripPotholeArray[accelerometerDataTrigger.currentTripPotholeArray.count - 1].isConfirmed = true
            //CHANGE THESE TO SAVE AND CONVERT
            default:
                print("Didn't hear match, but got \(hypothesis) confidently \(recognitionScore)")
                //Add something where the phone says "Say either "Pothole" or "False"
            }
            NSNotificationCenter.defaultCenter().postNotificationName(motionAndTableNotification, object: self)
        } else {
            print ("The recieved hypothesis is \(hypothesis) with a score of \(recognitionScore) and an ID of \(utteranceID)")
            //Add something where the phone says "Say either "Pothole" or "False"
        }
    }
    
}
