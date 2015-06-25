//
//  ViewController.swift
//  transients
//
//  Created by Johann Diedrick on 6/22/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import UIKit
import AVFoundation


class TZRecorderViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var recordButton = UIButton()

    var audioPlayer : AVAudioPlayer?
    var audioRecorder : AVAudioRecorder?
    
    var baseRecordButtonSizeRad : CGFloat = 100;

    var meterTimer:NSTimer!
    
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
        let buttonWidth : CGFloat! = baseRecordButtonSizeRad
        let buttonHeight : CGFloat! = baseRecordButtonSizeRad
        
        recordButton = UIButton(frame: CGRectMake(self.view.frame.width/2 - buttonWidth/2,
            self.view.frame.height/2 - buttonHeight/2,
            buttonWidth,
            buttonHeight))
        recordButton.layer.cornerRadius = buttonWidth/2;
        
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
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker, error: &error)
        
        
        if let err = error{
            println("audioSession error: \(err.localizedDescription)")
        }
        
        audioRecorder = AVAudioRecorder(URL: soundFileURL,
            settings: recordSettings as [NSObject : AnyObject], error: &error)
    
        if let err = error{
            println("audioSession error: \(err.localizedDescription)")
        } else{
            audioRecorder?.meteringEnabled = true
            audioRecorder?.prepareToRecord()
        }
    }

    func recordAudio(){
        if audioRecorder?.recording == false{
            audioRecorder?.record()
            self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.01,
                target:self,
                selector:"updateAudioMeter:",
                userInfo:nil,
                repeats:true)
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

    
    func updateAudioMeter(time:NSTimer){
        if (audioRecorder?.recording == true) {
            let dFormat = "%02d"
            let min:Int = Int(audioRecorder!.currentTime / 60)
            let sec:Int = Int(audioRecorder!.currentTime % 60)
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec) )"
            audioRecorder!.updateMeters()
            var apc0 = audioRecorder!.averagePowerForChannel(0)
            
            //println( logMap(apc0, inMin: -100.0, inMax: -3.0, outMin: 0.0001, outMax: 1) )
            
            var level = logMap(apc0, inMin: -100.0, inMax: -3.0, outMin: 0.0001, outMax: 1)
            
            var scale = 500.0
    
            var newButtonRad = Float(baseRecordButtonSizeRad) + Float(level) * Float(scale)
            
            
            recordButton.frame = CGRectMake(
                CGFloat(Float(self.view.frame.width/2) - Float(recordButton.bounds.width)/2),
                CGFloat(Float(self.view.frame.height/2) - Float(recordButton.bounds.height)/2),
                CGFloat(newButtonRad),
                CGFloat(newButtonRad))
            
            recordButton.layer.cornerRadius = recordButton.bounds.width/2
        }
    }


    /* HELPERS */
    func logMap(inVal:Float, inMin:Float, inMax:Float, outMin:Float, outMax:Float)  -> Float{
        var minv = logf(outMin)
        var maxv = logf(outMax)
        
        var numerator = maxv - minv
        var denom = inMax - inMin
        
        // dont divide by zero
        if (denom == 0.0) {
            denom = 0.00000000001
        }
        
        // calculate scale
        var scale = numerator / denom
        
        return exp( (minv + scale * (inVal-inMin) ))
    }
    
}

