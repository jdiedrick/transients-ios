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

class TZMapViewController : UIViewController{
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.purpleColor()
        
        let location = CLLocationCoordinate2D(latitude: 51.50007773, longitude: -0.1246402)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegionMake(location, span)
    
        mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
        mapView.mapType = MKMapType.Standard
        
        mapView.zoomEnabled = true
        
        mapView.scrollEnabled = true
        
        mapView.setRegion(region, animated: true)
        
        self.view.addSubview(mapView)
        
    
        
        
        
    }
}
