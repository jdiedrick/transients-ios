//
//  TZGeoSoundPlayer.swift
//  transients
//
//  Created by Johann Diedrick on 6/28/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import AVFoundation

class TZGeoSoundPlayer : AVAudioPlayer{
    
    func startPlayingAudio(){
        if self.playing == false{
            self.play()
        }
    }
    
    func stopPlayingAudio(){
        if self.playing == true{
            self.stop()
        }
    }
    
}
