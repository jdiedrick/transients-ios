//
//  TZGeoSound.swift
//  transients
//
//  Created by Johann Diedrick on 8/16/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation

public class TZGeoSound {
    
    var latitude : Double? = nil
    var longitude : Double? = nil
    var thrownLatitude : Double? = nil
    var thrownLongitude : Double? = nil
    public var fileURL: NSURL? = nil
    var date : NSString? = nil
    var time : NSString? = nil
    var title : NSString? = nil
    var description : NSString? = nil
    var tags : NSString? = nil
    var isDrifting : Bool? = nil
   
    public init(){}
    
}