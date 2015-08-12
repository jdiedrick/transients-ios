//
//  TZMapViewController.swift
//  transients
//
//  Created by Johann Diedrick on 6/25/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import AVFoundation

let json_url = "http://ec2-52-24-91-31.us-west-2.compute.amazonaws.com:9000/geosounds"

class TZMapViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AVAudioPlayerDelegate{
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()

    var mapScale = 0.25
    var myLocation : CLLocationCoordinate2D!
    
    var geosoundPlayer : AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.purpleColor()
       
        mapView.showsUserLocation = true
        mapView.delegate = self

        self.view.addSubview(mapView)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
       
        // only request location when app is open
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.getSounds()
       
        var error : NSError?
        
        let audioSession = AVAudioSession.sharedInstance()
        
        
        if let err = error{
            println("audioSession error: \(err.localizedDescription)")
        }
        if (audioSession.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("granted")
                    audioSession.setCategory(
                        AVAudioSessionCategoryPlayAndRecord,
                        withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker,
                        error: &error)
                } else{
                    println("not granted")
                }
            })
            
        }

        // setup our recorder and player
       /*
        geoSoundPlayer = TZGeoSoundPlayer(
            contentsOfURL: soundFileURL,
            error: &error)
        
        geoSoundPlayer?.delegate = self
        geoSoundRecorder?.delegate = self
      */
        
        
    
    }


    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.myLocation = manager.location.coordinate
        self.centerMapView(manager.location.coordinate)

        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, err)->Void in
                if err != nil {
                    println("Error: " + err.localizedDescription)
                    return
                }

                if placemarks.count > 0 {
                    let pm = placemarks[0] as! CLPlacemark
                    self.displayLocationInfo(pm)
                }
            })
    }

    func displayLocationInfo(placemark: CLPlacemark) {
            self.locationManager.stopUpdatingLocation()
//            println(placemark.locality)
//            println(placemark.postalCode)
//            println(placemark.administrativeArea)
//            println(placemark.country)
    }

    func locationManager(manager:CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }

    // center map based on user location
    func centerMapView(coord: CLLocationCoordinate2D) {
        let location = coord

        let span = MKCoordinateSpanMake(self.mapScale, self.mapScale)
        
        let region = MKCoordinateRegionMake(location, span)
        
        mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
        mapView.mapType = MKMapType.Standard
        
        mapView.zoomEnabled = true
        
        mapView.scrollEnabled = true
        
        mapView.setRegion(region, animated: true)
    }
    

    // re-center map based on location
    func findMyLocationAgain() {
        self.locationManager.startUpdatingLocation()
    }

    func mapViewChanged() {
        // to do: reload pins based on the new map view
    }


    func getSounds() {
        Alamofire.request(.GET, json_url)
            .responseJSON { (_, _, data, _) in
                
                if ((data) != nil){
                let json = JSON(data!)

                self.plotSounds(json)
                }
        }
    }

    func plotSounds(data:JSON) {
        
        for (index: String, sound: JSON) in data["geosounds"] {
            
            println(sound)
           
            println(sound["latitude"])
            var lat = sound["latitude"]
            var lng = sound["longitude"]
            var sound_url = sound["sound_url"]

            var coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat.numberValue), longitude: CLLocationDegrees(lng.numberValue))

            let pin = MKPointAnnotation()
            pin.coordinate = coord
            pin.title = "Cool Place and Sound"
            pin.subtitle = sound_url.stringValue
            mapView.addAnnotation(pin)

            println("Lat: \(lat), Lng: \(lng), URL: \(sound_url)" )
        }

    }

    //delegates
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
      
        if (geosoundPlayer != nil){
        
                println("pausing, removing observer and clearing audio player")
            
                geosoundPlayer.pause() // pause the audio
            
                geosoundPlayer.removeObserver(self, forKeyPath: "status") // clear the observer
            
                geosoundPlayer = nil // clear the player
        }
        //use av player instead of avaudioplayer, maybe change in class for all players?
        var error : NSError?
      
        var soundFileURL = NSURL(string: view.annotation.subtitle as String!)!
        
        println("\(soundFileURL)")
        geosoundPlayer = AVPlayer(URL: soundFileURL)
        
       //setup notifications
        geosoundPlayer.addObserver(self, forKeyPath: "status", options: nil, context: nil)
        
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        if keyPath == "status" {
            if geosoundPlayer.status == AVPlayerStatus.ReadyToPlay{
                println("ready to play")
                geosoundPlayer.play()
            }
        }
    }
    
    
}