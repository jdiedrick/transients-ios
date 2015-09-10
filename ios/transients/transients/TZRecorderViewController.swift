//
//  ViewController.swift
//  transients
//
//  Created by Johann Diedrick on 6/22/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//


import UIKit
import AVFoundation


class TZRecorderViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {

    var recordButton = UIButton()

    var geoSoundRecorder : TZGeoSoundRecorder!
    
    var geoSoundPlayer : TZGeoSoundPlayer!
    
    var baseRecordButtonSizeRad : CGFloat = 100;

    var meterTimer:NSTimer!
    
    var uploadTime: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        setupAudio()
        setupLocation()
        setupGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI(){
        view.backgroundColor = Constants.Colors.backgroundColor
        //record button
        let buttonWidth : CGFloat! = baseRecordButtonSizeRad
        let buttonHeight : CGFloat! = baseRecordButtonSizeRad
        
        recordButton = UIButton(frame: CGRectMake(self.view.frame.width/2 - buttonWidth/2,
            self.view.frame.height/2 - buttonHeight/2,
            buttonWidth,
            buttonHeight))
        recordButton.layer.cornerRadius = buttonWidth/2;
        
        recordButton.backgroundColor = Constants.Colors.recordButtonColor
        
        //recordButton.addTarget(self, action: "startRecording:", forControlEvents: UIControlEvents.TouchDown)
        //recordButton.addTarget(self, action: "stopRecording:", forControlEvents: UIControlEvents.TouchUpInside)
        recordButton.addTarget(self, action: "startRecordingForDuration:", forControlEvents: UIControlEvents.TouchUpInside)
        
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
    
    func setupLocation(){
        LocationService.sharedInstance.startUpdatingLocation()
    }
    
    func setupGestureRecognizer(){
        let gestureRecognizer : UITapGestureRecognizer! = UITapGestureRecognizer(target: self, action: "handleTap:")
        gestureRecognizer.delegate = self
        gestureRecognizer.numberOfTapsRequired = 5
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        println("recognized gesture")
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Recording Time", message: "Enter Recording Time", preferredStyle: .Alert)
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Enter recordind time"
        })
        
        let action = UIAlertAction(title: "Submit",
            style: UIAlertActionStyle.Default,
            handler: {[weak self]
                (paramAction:UIAlertAction!) in
                if let textFields = alertController?.textFields{
                    let theTextFields = textFields as! [UITextField]
                    let enteredText = theTextFields[0].text
                    self!.uploadTime = enteredText.toInt()!
                    println("\(self!.uploadTime)")
                }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!,
            animated: true,
            completion: nil)
        
        
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

    func startRecordingForDuration(sender:UIButton!){
        self.recordButton.backgroundColor = Constants.Colors.recordingColor
        
        if (uploadTime == 0){
            uploadTime = 5 // set a resonable initial time interval
        }
        var timeInterval : NSTimeInterval! = NSTimeInterval(uploadTime)
        geoSoundRecorder!.recordForDuration(timeInterval)
        
        
    }

    // delegates
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("audio player finished playing")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("audio play decode error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        
        self.recordButton.backgroundColor = Constants.Colors.recordButtonColor
        
        println("audio recorder did finish recording")
        var bufferURL = geoSoundRecorder.url
        var error: NSError?

        geoSoundPlayer = TZGeoSoundPlayer(contentsOfURL: bufferURL, error: &error)

        if let error = error {
            println("error playing back recording")
        } else {

        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let soundFilePath = docsDir.stringByAppendingPathComponent("sound.wav")

        AudioHelper.convertFromWavToMp3(soundFilePath, block:{(Bool) in
            
            let mp3FileName = "Mp3File.mp3"
            let mp3FilePath = NSTemporaryDirectory().stringByAppendingString(mp3FileName)
            var mp3URL = NSURL(fileURLWithPath: mp3FilePath)
            var error : NSError?
            let tzsvc:TZSaveViewController = TZSaveViewController()
            tzsvc.file_path = mp3URL!
            self.presentViewController(tzsvc, animated: true, completion: nil)
        })
            
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

