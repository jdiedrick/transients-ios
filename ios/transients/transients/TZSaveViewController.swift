//
//  TZSaveViewController.swift
//  transients
//
//  Created by Jason Sigal on 8/4/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation


class TZSaveViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate, TZUploadManagerDelegate{
   
    
    /**
        variables:
            - the file location / duration

        on this screen:
            - update location
            - text box: description, tags
            - display time and date
    **/

    var delegate : TZUploadManagerDelegate?
    
    var file_path:NSURL?
    
    var title_box:UITextField?
    var description_box:UITextField?
    var tag_box:UITextField?
    
    var location_label:UILabel?
    var time_label:UILabel?
    var date_label:UILabel?
    
    var upload_button:UIButton?
    var preview_button:UIButton?
    var cancel_button:UIButton?
   
    var drift_switch:UISwitch?
    
    var grayView:UIView?
    var activityIndicator:UIActivityIndicatorView?

    var geoSoundPlayer:TZGeoSoundPlayer?
    
    var geoSoundUploader:TZUploadManager?
    
    override func viewDidLoad(){
        super.viewDidLoad()

        view.backgroundColor = Constants.Colors.backgroundColor
        
        //gesture for dismissing keyboard
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        title_box = UITextField()
        title_box?.delegate = self
        title_box?.setTranslatesAutoresizingMaskIntoConstraints(false)
        title_box?.backgroundColor = UIColor.purpleColor()
        title_box?.placeholder = "Title of Sound (optional)"
        
        description_box = UITextField()
        description_box?.delegate = self
        description_box?.setTranslatesAutoresizingMaskIntoConstraints(false)
        description_box?.backgroundColor = UIColor.yellowColor()
        description_box?.placeholder = "Description (optional)"

        tag_box = UITextField()
        tag_box?.delegate = self
        tag_box?.setTranslatesAutoresizingMaskIntoConstraints(false)
        tag_box?.backgroundColor = UIColor.yellowColor()
        tag_box?.placeholder = "Tags (optional)"
        
        location_label = UILabel()
        location_label?.setTranslatesAutoresizingMaskIntoConstraints(false)
        location_label?.backgroundColor = UIColor.greenColor()
        location_label?.text = "Lat: X | Lng: Y"
        
        time_label = UILabel()
        time_label?.setTranslatesAutoresizingMaskIntoConstraints(false)
        time_label?.backgroundColor = UIColor.greenColor()
        time_label?.text = "Time of the recording is: 4:20am"

        date_label = UILabel()
        date_label?.setTranslatesAutoresizingMaskIntoConstraints(false)
        date_label?.backgroundColor = UIColor.greenColor()
        date_label?.text = "Date of the recording is: 5/3/1987"
        
        upload_button = UIButton()
        upload_button?.setTranslatesAutoresizingMaskIntoConstraints(false)
        upload_button?.backgroundColor = UIColor.blueColor()
        upload_button?.setTitle("Upload", forState: UIControlState.Normal)
        upload_button?.addTarget(self, action: "uploadAudio", forControlEvents: UIControlEvents.TouchUpInside)

        preview_button = UIButton()
        preview_button?.setTranslatesAutoresizingMaskIntoConstraints(false)
        preview_button?.backgroundColor = UIColor.blueColor()
        preview_button?.setTitle("Preview", forState: UIControlState.Normal)
        preview_button?.addTarget(self, action: "previewAudio", forControlEvents: UIControlEvents.TouchUpInside)

        cancel_button = UIButton()
        cancel_button?.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancel_button?.backgroundColor = UIColor.blueColor()
        cancel_button?.setTitle("Cancel", forState: UIControlState.Normal)
        cancel_button?.addTarget(self, action: "cancelUpload", forControlEvents: UIControlEvents.TouchUpInside)
        
        drift_switch = UISwitch()
        drift_switch?.setTranslatesAutoresizingMaskIntoConstraints(false)
        

        let viewsDictionary = [
            "title_box":title_box!,
            "description_box":description_box!,
            "tag_box":tag_box!,
            "location_label":location_label!,
            "time_label":time_label!,
            "date_label":date_label!,
            "upload_button":upload_button!,
            "preview_button":preview_button!,
            "cancel_button":cancel_button!,
            "drift_switch":drift_switch!
        ]

        
        self.view.addSubview(title_box!)
        self.view.addSubview(description_box!)
        self.view.addSubview(tag_box!)
        self.view.addSubview(location_label!)
        self.view.addSubview(time_label!)
        self.view.addSubview(date_label!)
        self.view.addSubview(upload_button!)
        self.view.addSubview(preview_button!)
        self.view.addSubview(cancel_button!)
        self.view.addSubview(drift_switch!)
        
        //position constraints

        /** test **/
        //Make a view


        //sizing constraints
        // thx http://makeapppie.com/2014/07/26/the-swift-swift-tutorial-how-to-use-uiviews-with-auto-layout-programmatically/

        let view_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-36-[description_box]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDictionary)
        let view_constraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[title_box]-[description_box]-[tag_box]-[location_label]-[time_label]-[date_label]-[upload_button]-[preview_button]-[cancel_button]-[drift_switch]-20-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
        
        view.addConstraints(view_constraint_H as [AnyObject])
        view.addConstraints(view_constraint_V as [AnyObject])
        
    }
   
    
    func uploadAudio(){
        
        let fileURL : NSURL = file_path!
        
        var todaysDate:NSDate = NSDate()
        var dateFormatterDate:NSDateFormatter = NSDateFormatter()
        dateFormatterDate.dateFormat = "yyyy-MM-dd"
        
        var date:String = dateFormatterDate.stringFromDate(todaysDate)
        var dateFormatterTime:NSDateFormatter = NSDateFormatter()
        dateFormatterTime.dateFormat = "hh:mm"
        var time:String = dateFormatterTime.stringFromDate(todaysDate)
        
        var geoSound : TZGeoSound = TZGeoSound()
        
        geoSound.latitude = LocationService.sharedInstance.currentLocation!.coordinate.latitude
        geoSound.longitude = LocationService.sharedInstance.currentLocation!.coordinate.longitude
        geoSound.fileURL = fileURL
        geoSound.date = date
        geoSound.time = time
        geoSound.title = title_box!.text
        geoSound.description = description_box!.text
        geoSound.tags = tag_box!.text
        geoSound.isDrifting = false
        geoSound.thrownLatitude = geoSound.latitude
        geoSound.thrownLongitude = geoSound.longitude
    
        if (self.drift_switch!.on){
            println("lets drift")
            geoSound.isDrifting = true
            let dvc:TZDriftViewController = TZDriftViewController()
            dvc.geoSound = geoSound
            
            self.presentViewController(dvc, animated: true, completion: nil)
        } else {
            geoSoundUploader = TZUploadManager()
            geoSoundUploader?.delegate = self
            geoSoundUploader?.uploadAudio(geoSound)
            
        }
    }
    
    func previewAudio(){
        geoSoundPlayer = TZGeoSoundPlayer(contentsOfURL: file_path, error: nil)
        geoSoundPlayer?.delegate = self
        geoSoundPlayer?.play()
    }
    
    func cancelUpload(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //text view delegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // audio player delegate methods
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("audio player finished playing")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("audio play decode error")
    }
    
    //presenting/dismissing protocols
    
    func presentLoadingScreen(){
        println("presenting loading screen")
        grayView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        grayView!.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator!.frame = CGRectMake(
            (self.view.frame.size.width/2) - 50,
            (self.view.frame.size.height/2)-50,
            50,
            50)
        
        view.addSubview(grayView!)
        view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
    }
    
    func dismissLoadingScreen(){
        println("dismissing loading screen")
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.removeFromSuperview()
        self.grayView!.removeFromSuperview()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
}