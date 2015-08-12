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

    var geoSoundRecorder : TZGeoSoundRecorder!
    
    var geoSoundPlayer : TZGeoSoundPlayer!
    
    var baseRecordButtonSizeRad : CGFloat = 100;

    var meterTimer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            view.backgroundColor = UIColor.blueColor()
        setupUI()
        setupAudio()
        LocationService.sharedInstance.startUpdatingLocation()
        
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
        
        //setup location to save our sound
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let soundFilePath = docsDir.stringByAppendingPathComponent("sound.wav")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        
        let recordSettings = [AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        /*
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue, //maybe worth changing later
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 44100.0
        ]*/
        
        // setup our audio session
        
        var error: NSError?
        
        let audioSession = AVAudioSession.sharedInstance()
        
        
        if let err = error{
            println("audioSession error: \(err.localizedDescription)")
        }
        
        if (audioSession.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("granted")
                    audioSession.setCategory(
                        AVAudioSessionCategoryPlayAndRecord,
                        withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker,
                        error: &error)
                } else{
                    println("not granted")
                }
            })
            
        }

        // setup our recorder and player
        
        geoSoundRecorder = TZGeoSoundRecorder(
            URL: soundFileURL,
            settings: recordSettings as [NSObject : AnyObject],
            error: &error)
    
        geoSoundPlayer = TZGeoSoundPlayer(
            contentsOfURL: soundFileURL,
            error: &error)
        
        geoSoundPlayer?.delegate = self
        geoSoundRecorder?.delegate = self
        
        if let err = error{
            println("audioSession error: \(err.localizedDescription)")
        } else{
            geoSoundRecorder?.meteringEnabled = true
            geoSoundRecorder?.prepareToRecord()
        }
    
        self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.01,
                target:self,
                selector:"updateAudioMeter:",
                userInfo:nil,
                repeats:true)
    }
    
    // ui events

    func startRecording(sender:UIButton!){
        println("start recording")
        geoSoundRecorder!.startRecordingAudio();
    }

    func stopRecording(sender:UIButton!){
        println("stop recording")
        geoSoundRecorder!.stopRecordingAudio()
        println("transitioning")
    }


    // delegates
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("audio player finished playing")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("audio play decode error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("audio recorder did finish recording")
        var bufferURL = geoSoundRecorder.url
        var error: NSError?

        geoSoundPlayer = TZGeoSoundPlayer(contentsOfURL: bufferURL, error: &error)

        if let error = error {
            println("error playing back recording")
        } else {

            // transition screens
            let tzsvc:TZSaveViewController = TZSaveViewController()

            tzsvc.file_path = bufferURL

            self.presentViewController(tzsvc, animated: true, completion: nil)
            

            //            geoSoundPlayer!.startPlayingAudio()
        }
        
        println("Player duration: \(geoSoundPlayer.duration)")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("audio record encode error")
    }

    
    func updateAudioMeter(time:NSTimer){
        if (geoSoundRecorder?.recording == true) {
            
            let dFormat = "%02d"
            let min:Int = Int(geoSoundRecorder!.currentTime / 60)
            let sec:Int = Int(geoSoundRecorder!.currentTime % 60)
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec) )"
            geoSoundRecorder!.updateMeters()
            var apc0 = geoSoundRecorder!.averagePowerForChannel(0)
            
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
        } /*else if (geoSoundPlayer?.playing == true){
            println("this is also happening")
            let dFormat = "%02d"
            let min:Int = Int(geoSoundPlayer!.currentTime / 60)
            let sec:Int = Int(geoSoundPlayer!.currentTime % 60)
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec) )"
            geoSoundPlayer!.updateMeters()
            var apc0 = geoSoundPlayer!.averagePowerForChannel(0)
            
            var level = logMap(apc0, inMin: -100.0, inMax: -3.0, outMin: 0.0001, outMax: 1)
            println(apc0)
            var scale = 500.0
            
            var newButtonRad = Float(baseRecordButtonSizeRad) + Float(level) * Float(scale)
            
            
            recordButton.frame = CGRectMake(
                CGFloat(Float(self.view.frame.width/2) - Float(recordButton.bounds.width)/2),
                CGFloat(Float(self.view.frame.height/2) - Float(recordButton.bounds.height)/2),
                CGFloat(newButtonRad),
                CGFloat(newButtonRad))
            
            recordButton.layer.cornerRadius = recordButton.bounds.width/2
            
        }*/
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

