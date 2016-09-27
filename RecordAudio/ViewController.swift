//
//  ViewController.swift
//  RecordAudio
//
//  Created by Ruchin on 27/09/16.
//  Copyright © 2016 Ruchin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    var soundRecorder: AVAudioRecorder!
    var soundPlayer:AVAudioPlayer!
    let fileName = "demo.caf"
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let audioSession = AVAudioSession.sharedInstance()
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("granted")
                    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try! audioSession.setActive(true)
                    try! audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                    self.setupRecorder()
                } else{
                    print("not granted")
                    //                    UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
                    //                    let app = UIApplication.shared
                    //                    app.canOpenURL(NSURL(string:"prefs:root=Privacy&path=MICROPHONE") as! URL)
                }
            })
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordSound(_ sender: AnyObject) {
        if (sender.titleLabel!?.text == "Record"){
            soundRecorder.record()
            sender.setTitle("Stop", for: .normal)
            playButton.isEnabled = false
        } else {
            soundRecorder.stop()
            sender.setTitle("Record", for: .normal)
        }
    }
    
    @IBAction func playSound(_ sender: AnyObject) {
        if (sender.titleLabel!?.text == "Play"){
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            preparePlayer()
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            sender.setTitle("Play", for: .normal)
        }
    }
    
    
    
    func getFileURL() -> NSURL {
        
        let path = getCacheDirectory().strings(byAppendingPaths: [fileName])
        let filePath = NSURL(fileURLWithPath: path[0])
        
        return filePath
    }
    
    
    func getCacheDirectory() -> NSString {
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask, true) as [NSString]
        
        return paths[0]
    }
    
    func setupRecorder() {
        
        //set the settings for recorder
        
        let recordSettings = [
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
            ] as [String : Any]
        
        
        do {
            soundRecorder = try AVAudioRecorder(url: getFileURL() as URL, settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print("AVAudioRecorder error")
        }
    }
    
    func preparePlayer() {
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print("AVAudioPlayer error")
        }
    }
    
    // MARK: audio recorder delegate method
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
        recordButton.setTitle("Record", for: .normal)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error?.localizedDescription)")
    }
    
    
    // MARK: audio player delegate method
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error?.localizedDescription)")
    }
    
}

