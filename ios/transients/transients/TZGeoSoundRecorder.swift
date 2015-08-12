//
//  TZGeoSoundRecorder.swift
//  transients
//
//  Created by Johann Diedrick on 6/28/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import AVFoundation

class TZGeoSoundRecorder : AVAudioRecorder{
    
    func startRecordingAudio(){
        if self.recording == false{
            self.record()
        }
    }

    func stopRecordingAudio(){
        println("\(self.currentTime)")
        if self.recording == true{
            self.stop()
        }
    }

}