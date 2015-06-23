//
//  ViewController.swift
//  transients
//
//  Created by Johann Diedrick on 6/22/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import UIKit
import AVFoundation

var recordButton = UIButton()

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var audioPlayer : AVAudioPlayer?
    var audioRecorder : AVAudioRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            view.backgroundColor = UIColor.blueColor()
        setupUI()
        setupAudio()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI(){
        
        //record button
        let buttonWidth : CGFloat! = 50
        let buttonHeight : CGFloat! = 50
        
        recordButton = UIButton(frame: CGRectMake(self.view.frame.width/2 - buttonWidth/2,
            self.view.frame.height/2 - buttonHeight/2,
            buttonWidth,
            buttonHeight))
        
        recordButton.backgroundColor = UIColor.orangeColor()
        
        recordButton.addTarget(self, action: "startRecording:", forControlEvents: UIControlEvents.TouchDown)
        recordButton.addTarget(self, action: "stopRecording:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(recordButton)
        
        }
    
    func setupAudio(){
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let soundFilePath = docsDir.stringByAppendingPathComponent("sound.caf")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue, //maybe worth changing later
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 44100.0
        ]
        
        var error: NSError?
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        
        
        if let err = error{
            println("audioSession error: \(err.localizedDescription)")
        }
        
        audioRecorder = AVAudioRecorder(URL: soundFileURL,
            settings: recordSettings as [NSObject : AnyObject], error: &error)
    
        if let err = error{
            println("audioSession error: \(err.localizedDescription)")
        } else{
            audioRecorder?.prepareToRecord()
        }
    }

    func recordAudio(){
        if audioRecorder?.recording == false{
            audioRecorder?.record()
        }
    }
    
    func stopAudio(){
        if audioRecorder?.recording == true{
            audioRecorder?.stop()
        }else{
            audioPlayer?.stop()
        }
    }
    
    func playAudio(){
        if audioRecorder?.recording == false{
            var error : NSError?
            
            audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder?.url, error: &error);
            
            audioPlayer?.delegate = self
            
            if let err = error{
                println("audioPlayer error: \(err.localizedDescription)")
            } else{
                audioPlayer?.play()
            }
            
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("audio player finished player")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("audio play decode error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("audio recorder did finish recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("audio record encode error")
    }

    func startRecording(sender:UIButton!){
        println("start recording")
        recordAudio();
    }

    func stopRecording(sender:UIButton!){
        println("stop recording")
        stopAudio()
        playAudio()
    }

}

