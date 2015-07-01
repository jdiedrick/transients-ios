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

class TZMapViewController : UIViewController, CLLocationManagerDelegate{
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()

    var mapScale = 0.25
    var myLocation : CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.purpleColor()
        
        mapView.showsUserLocation = true

        self.view.addSubview(mapView)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // only request location when app is open
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        self.getSounds()
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
        Alamofire.request(.GET, "http://localhost:9000/geosounds")
            .responseJSON { (_, _, data, _) in
                let json = JSON(data!)

                self.plotSounds(json)
        }
    }

    func plotSounds(data:JSON) {
        
        for (index: String, sound: JSON) in data["geosounds"] {
            var lat = sound["lat"].double
            var lng = sound["lng"].double

            var coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat!), longitude: CLLocationDegrees(lng!))

            let pin = MKPointAnnotation()
            pin.coordinate = coord
            pin.title = "Cool Place and Sound"
            mapView.addAnnotation(pin)

            println("Lat: \(lat), Lng: \(lng)" )
        }

    }
}