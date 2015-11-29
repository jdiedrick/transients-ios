//
//  ViewController.swift
//  transients
//
//  Created by Johann Diedrick on 6/22/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//


import UIKit
import AVFoundation
import Parse


class TZRecorderViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {

    var recordButton : UIButton!

    var geoSoundRecorder : TZGeoSoundRecorder!
    
    var geoSoundPlayer : TZGeoSoundPlayer!
    
    var baseRecordButtonSizeRad : CGFloat = 100;

    var meterTimer:NSTimer!
    
    var uploadTime: Int = 0
    
    var recordingSession : AVAudioSession!
    
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
        
        //holding recording
        recordButton.addTarget(self,
            action: "startRecording:",
            forControlEvents: UIControlEvents.TouchDown)
        recordButton.addTarget(self,
            action: "stopRecording:",
            forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(recordButton)

    }
    
    func setupAudio(){
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do{
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){ [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()){
                    if allowed{
                        print("allowed")
                    }else{
                        print("not allowed")
                    }
                }
            }
        } catch{
                print("not allowed in catch")
        }
        
    
        let audioURL = TZRecorderViewController.getGeoSoundURL()
        print(audioURL.absoluteString)
        
        let recordSettings = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        do{
            geoSoundRecorder = try TZGeoSoundRecorder(URL: audioURL, settings: recordSettings as! [String : AnyObject] )
            geoSoundRecorder?.delegate = self
            geoSoundRecorder?.meteringEnabled = true
            geoSoundRecorder?.prepareToRecord()
        } catch{
            print("error creating recorder")
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
        print("recognized gesture")
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
                    let theTextFields = textFields
                    let enteredText = theTextFields[0].text
                    self!.uploadTime = Int(enteredText!)!
                    print("\(self!.uploadTime)")
                }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!,
            animated: true,
            completion: nil)
        
        
    }
    
    // ui events

    func startRecording(sender:UIButton!){
        print("start recording")
        self.recordButton.backgroundColor = Constants.Colors.recordingColor
        geoSoundRecorder.record()
        //geoSoundRecorder!.startRecordingAudio();
    }

    func stopRecording(sender:UIButton!){
        print("stop recording")
        geoSoundRecorder.stop()
        //geoSoundRecorder!.stopRecordingAudio()
        print("transitioning")
    }

    // delegates
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("audio player finished playing")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError!) {
        print("audio play decode error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audio recorder did finish recording")

        self.recordButton.backgroundColor = Constants.Colors.recordButtonColor
        
        let audioURL = TZRecorderViewController.getGeoSoundURL()
        print(audioURL.absoluteString)
        
        /*
        do{
            try geoSoundPlayer = TZGeoSoundPlayer(contentsOfURL: audioURL)
            geoSoundPlayer.play()
        } catch{
            print("error resetting geosound player after recording")
        }
        */
        
        //let docDirectory = TZRecorderViewController.getDocumentsDirectory()
        /*
        AudioHelper.convertFromWavToMp3(audioURL.absoluteString, block:{(Bool) in
            
            //let mp3FileName = "Mp3File.mp3"
            //let mp3FilePath = docDirectory.stringByAppendingString(mp3FileName)
            //var mp3URL = NSURL(fileURLWithPath: mp3FilePath)
            //var error : NSError?
            //let tzsvc:TZSaveViewController = TZSaveViewController()
            //tzsvc.file_path = mp3URL
            //self.presentViewController(tzsvc, animated: true, completion: nil)
        })
        */
        
        let tzsvc:TZSaveViewController = TZSaveViewController()
        tzsvc.file_path = audioURL
        self.presentViewController(tzsvc, animated: true, completion: nil)
        
        
        //print("Player duration: \(geoSoundPlayer.duration)")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        print("audio record encode error")
    }

    
    func updateAudioMeter(time:NSTimer){
        if (geoSoundRecorder?.recording == true) {
            
            let dFormat = "%02d"
            let min:Int = Int(geoSoundRecorder!.currentTime / 60)
            let sec:Int = Int(geoSoundRecorder!.currentTime % 60)
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec) )"
            geoSoundRecorder!.updateMeters()
            var apc0 = geoSoundRecorder!.averagePowerForChannel(0)
            
            //print( logMap(apc0, inMin: -100.0, inMax: -3.0, outMin: 0.0001, outMax: 1) )
            
            var level = logMap(apc0, inMin: -100.0, inMax: -3.0, outMin: 0.0001, outMax: 1)
            
            var scale = 500.0
    
            var newButtonRad = CGFloat(Float(baseRecordButtonSizeRad) + Float(level) * Float(scale))
            
            var frameWidth = Float(self.view.frame.width/2)
            
            var frameHeight = Float(self.view.frame.height/2)
            
            var newButtonX = CGFloat(frameWidth - Float(recordButton.bounds.width)/2)
            
            var newButtonY = CGFloat(frameHeight - Float(recordButton.bounds.height)/2)
            
            recordButton.frame = CGRectMake(
                newButtonX,
                newButtonY,
                newButtonRad,
                newButtonRad)
            
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
    
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getGeoSoundURL() -> NSURL {
        let audioFilename = getDocumentsDirectory().stringByAppendingPathComponent("sound.wav")
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        return audioURL
    }
    
}

