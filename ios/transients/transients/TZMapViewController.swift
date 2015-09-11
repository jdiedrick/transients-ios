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

class TZMapViewController : UIViewController, UIWebViewDelegate{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = Constants.Colors.backgroundColor
        
        let webView : UIWebView = UIWebView(frame: CGRectMake(
            0,
            0,
            self.view.frame.size.width,
            self.view.frame.size.height))
        
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: Constants.Map.Production)!))
        webView.delegate = self
        self.view.addSubview(webView)
       
    }
    

    
}