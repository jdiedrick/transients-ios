//
//  TZDriftViewController.swift
//  transients
//
//  Created by Johann Diedrick on 7/20/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import MotionKit


class TZDriftViewController: UIViewController{
    
let motionKit = MotionKit()
    
let threshold = 0.5
let interval = 0.1

override func viewDidLoad(){
    view.backgroundColor = UIColor.orangeColor()
   
    
    LocationService.sharedInstance.startUpdatingLocation()
    LocationService.sharedInstance.startUpdatingHeading()
    
    
    var motionValues = NSMutableArray()
   
    
    
    motionKit.getAccelerometerValues(interval: self.interval) {(x, y, z) -> () in
    
   // println("X: \(x) Y: \(y) Z \(z)")
    var slowedDown = false

    
    if(x < -self.threshold){ //we're moving!
        
            //println("we're moving")
            motionValues.addObject(x)
            //println(motionValues)
            var lastValue = motionValues.lastObject as! Float64
        
            if(motionValues.count > 3){
                var penultimateValue = motionValues.objectAtIndex(motionValues.count - 2) as! Float64
              //  println("last value: \(lastValue) | penultimateValue: \(penultimateValue)")
                if slowedDown == false{
                    if (lastValue > penultimateValue){
                        
                        var throwDistance = abs(penultimateValue) - self.threshold
                        println("we're slowing down: max value above threshold: \(throwDistance)")
                        
                        slowedDown = true
                        motionValues.removeAllObjects()
                        
                        self.calculateNewPosition(throwDistance)
                    }
                }
            }
        }
        
        //reset slowedDown check
        slowedDown = false
    
    }
}
    
    func calculateNewPosition(throwDistance : Double){
        var distance = 2*throwDistance //first calculate magnitude (distance); might wanna use a map function?
        var currentLat = LocationService.sharedInstance.currentLocation!.coordinate.latitude
        var currentLng = LocationService.sharedInstance.currentLocation!.coordinate.longitude
        var heading = LocationService.sharedInstance.currentHeading!.magneticHeading
        var latDisplacement = distance*cos(self.DegreesToRadians(heading))
        var lngDisplacement = distance*sin(self.DegreesToRadians(heading))
        var newLat = currentLat + latDisplacement
        var newLng = currentLng + lngDisplacement
        
        println("Distance: \(distance) | Current Lat: \(currentLat) | Current Lng: \(currentLng) | Heading: \(heading) | latDisp: \(latDisplacement) | lngDisp: \(lngDisplacement) | New Lat: \(newLat) | New Lng: \(newLng) ")
        
        
    }
    
    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
}