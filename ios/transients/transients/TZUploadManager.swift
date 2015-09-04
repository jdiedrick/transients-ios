//
//  TZUploadManager.swift
//  transients
//
//  Created by Johann Diedrick on 8/16/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

let audio_upload_url_local = "http://192.168.0.13:9000/uploadaudio"
let json_upload_url_local = "http://192.168.0.13:9000/uploadjson"

let audio_upload_url_dev = "http://ec2-52-24-91-31.us-west-2.compute.amazonaws.com:9000/uploadaudio"
let json_upload_url_dev = "http://ec2-52-24-91-31.us-west-2.compute.amazonaws.com:9000/uploadjson"

protocol TZUploadManagerDelegate{
    func presentLoadingScreen()
    func dismissLoadingScreen()
}

class TZUploadManager{

    var audio_upload_url = audio_upload_url_dev
    var json_upload_url = json_upload_url_dev
    var delegate : TZUploadManagerDelegate?
    
    
    func uploadGeoSound(geoSound: TZGeoSound){
        println("uploading geo sound")
        self.uploadAudio(geoSound)
    }

    func uploadAudio(geoSound: TZGeoSound){
        println("uploading audio")
       self.presentLoadingScreen()
        var fileURL = geoSound.fileURL
        
        Alamofire.upload(
            Alamofire.Method.POST,
            URLString: audio_upload_url,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: fileURL!, name: "mp3")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { request, response, json, error in
                        println(json)
                        var json_data = JSON(json!)
                        geoSound.fileURL = NSURL(string: json_data["filename"].string!)
                        self.uploadJSON(geoSound)
                    }
                case .Failure(let encodingError):
                    println(encodingError)
                }
            }
        )
}
    
    func uploadJSON(geoSound : TZGeoSound){
       //upload json
        println("uploading json")
        println("\(LocationService.sharedInstance.currentLocation!)")

        //var sound_url = jsonData["filename"].string
        
        var geoSoundDescription = [
            "latitude": "\(geoSound.latitude!)",
            "longitude": "\(geoSound.longitude!)",
            "filename": "\(geoSound.fileURL!.absoluteString!)",
            "date": "\(geoSound.date!)",
            "time": "\(geoSound.time!)",
            "title":"\(geoSound.title!)",
            "description": "\(geoSound.description!)",
            "tags": "\(geoSound.tags!)",
            "isDrifting" : "\(geoSound.isDrifting!)",
            "thrownLatitude" : "\(geoSound.thrownLatitude!)",
            "thrownLongitude" : "\(geoSound.thrownLongitude!)"
        ];
        
        
        Alamofire.request(Alamofire.Method.POST, json_upload_url, parameters: geoSoundDescription, encoding: Alamofire.ParameterEncoding.JSON)
            .responseJSON(options: nil) { (request, response, JSON, error) -> Void in
            println(JSON)
            self.dismissLoadingScreen()
            
        }
        
    }
    
    func presentLoadingScreen(){
            delegate?.presentLoadingScreen()
    }
    
    func dismissLoadingScreen(){
            delegate?.dismissLoadingScreen()
    }
};