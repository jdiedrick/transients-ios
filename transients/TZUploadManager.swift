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
import AudioToolbox

protocol TZUploadManagerDelegate{
    func presentLoadingScreen()
    func dismissLoadingScreen()
}

class TZUploadManager{

    var audio_upload_url = Constants.API.Production_UploadAudio
    var json_upload_url = Constants.API.Production_UploadJSON
    var delegate : TZUploadManagerDelegate?
    
    
    func uploadGeoSound(geoSound: TZGeoSound){
        print("uploading geo sound")
        self.uploadAudio(geoSound)
    }

    func uploadAudio(geoSound: TZGeoSound){
        print("uploading audio")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
       self.presentLoadingScreen()
       let fileURL = geoSound.fileURL
        
        
        Alamofire.upload(
            Alamofire.Method.POST,
            audio_upload_url,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: fileURL!, name: "mp3")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        //var json_data = JSON(response)
                        //geoSound.fileURL = NSURL(string: json_data["filename"].string!)
                        self.uploadJSON(geoSound)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
}
    
    func uploadJSON(geoSound : TZGeoSound){
       //upload json
        print("uploading json")
        //println("\(LocationService.sharedInstance.currentLocation!)")

        var geoSoundDescription = [
            "latitude": "\(geoSound.latitude!)",
            "longitude": "\(geoSound.longitude!)",
            "filename": "\(geoSound.fileURL!.absoluteString)",
            "date": "\(geoSound.date!)",
            "time": "\(geoSound.time!)",
            "description": "\(geoSound.description!)",
            "tags": "\(geoSound.tags!)",
            "isDrifting" : "\(geoSound.isDrifting!)",
            "thrownLatitude" : "\(geoSound.thrownLatitude!)",
            "thrownLongitude" : "\(geoSound.thrownLongitude!)"
        ];
        
        
        Alamofire.request(Alamofire.Method.POST, json_upload_url, parameters: geoSoundDescription, encoding: Alamofire.ParameterEncoding.JSON)
            .responseJSON{ response in
            print(response)
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