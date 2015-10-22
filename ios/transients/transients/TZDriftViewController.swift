//
//  TZDriftViewController.swift
//  transients
//
//  Created by Johann Diedrick on 7/20/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import MotionKit


class TZDriftViewController: UIViewController, TZUploadManagerDelegate{
    
    var geoSound : TZGeoSound!
    var geoSoundUploader : TZUploadManager!
    
    let motionKit = MotionKit()
    
    let threshold = 0.5
    let interval = 0.1
    let magnitude = 5
    
    var isUploading : Bool!

    var grayView:UIView?
    var activityIndicator:UIActivityIndicatorView?

override func viewDidLoad(){
    view.backgroundColor = Constants.Colors.backgroundColor
    
    var textView : UITextView = UITextView()
    
    textView.frame = CGRectMake(
        0,
        self.view.frame.height/2,
        self.view.frame.size.width,
        self.view.frame.size.height)
    
    textView.textColor = Constants.Colors.textColor
    
    textView.text = "Hold phone tightly \n and throw sound \n into the world!"
    
    textView.font = UIFont(name: textView.font.fontName, size: 32)
    
    textView.backgroundColor = Constants.Colors.backgroundColor
    
    textView.textAlignment = .Center
    
    textView.editable = false
    
    self.view.addSubview(textView)
   
    
    LocationService.sharedInstance.startUpdatingLocation()
    LocationService.sharedInstance.startUpdatingHeading()
    
    
    var motionValues = NSMutableArray()
   
    isUploading = false
    
    
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
                       
                        if (!self.isUploading){
                            self.calculateNewPosition(throwDistance)
                        }
                    }
                }
            }
        }
        
        //reset slowedDown check
        slowedDown = false
    
    }
}
    
    func calculateNewPosition(throwDistance : Double){
        var distance = 3.0*throwDistance //first calculate magnitude (distance); might wanna use a map function?
        var currentLat = LocationService.sharedInstance.currentLocation!.coordinate.latitude
        var currentLng = LocationService.sharedInstance.currentLocation!.coordinate.longitude
        var heading = LocationService.sharedInstance.currentHeading!.magneticHeading
        var latDisplacement = distance*cos(self.DegreesToRadians(heading))
        var lngDisplacement = distance*sin(self.DegreesToRadians(heading))
        var newLat = currentLat + latDisplacement
        var newLng = currentLng + lngDisplacement
        
        println("Distance: \(distance) | Current Lat: \(currentLat) | Current Lng: \(currentLng) | Heading: \(heading) | latDisp: \(latDisplacement) | lngDisp: \(lngDisplacement) | New Lat: \(newLat) | New Lng: \(newLng) ")
       
        geoSound.thrownLatitude = newLat
        geoSound.thrownLongitude = newLng
        
        //upload audio
        self.isUploading = true
        
        //set new drift location
        geoSoundUploader = TZUploadManager()
        
        geoSoundUploader.delegate = self
        geoSoundUploader.uploadAudio(geoSound)
        
    }
    
    //math helpers
    
    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }

    //presenting/dismissing protocols
    
    func presentLoadingScreen(){
        println("presenting loading screen for drift")
        grayView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        grayView!.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        
        var activityIndicator_width : CGFloat = 50
        var activityIndicator_height : CGFloat = 50
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator!.frame = CGRectMake(
            (self.view.frame.size.width/2) - (activityIndicator_width/2),
            (self.view.frame.size.height/2)-(activityIndicator_height/2),
            activityIndicator_width,
            activityIndicator_width)
        
        self.view.addSubview(grayView!)
        self.view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
    }
    
    func dismissLoadingScreen(){
        println("dismissing loading screen for drift")
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.removeFromSuperview()
        self.grayView!.removeFromSuperview()
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
}