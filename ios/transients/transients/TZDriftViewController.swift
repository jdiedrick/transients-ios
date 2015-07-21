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
                        println("we're slowing down: max value above threshold: \(abs(penultimateValue) - self.threshold)")
                        slowedDown = true
                        motionValues.removeAllObjects()
                    }
                }
            }
        }
        
        //reset slowedDown check
        slowedDown = false
    
    }
}

}