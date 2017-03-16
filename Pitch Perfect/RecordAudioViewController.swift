//
//  RecordAudioViewController.swift
//  Pitch Perfect
//
//  Created by Ramesh Parthasarathy on 10/22/16.
//  Copyright © 2016 Ramesh Parthasarathy. All rights reserved.
//

/**
 * Credits/Acknowledgements:
 *
 * Code for formatting m4a to AAC is taken from Apple WWDC16 Media on
 * A guide to audio best practices and APIs, Session 507
 * http://devstreaming.apple.com/videos/wwdc/2016/507n0zrhzxdzmg20zcl/507/507_delivering_an_exceptional_audio_experience.pdf
 */

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Properties
    var canRecord = true
    var canStop = false
    var audioRecorder: AVAudioRecorder!
    
    // MARK: Types
    enum ScreenHeight {
        enum PhoneSE: CGFloat {
            case Portrait = 568.0
            case Landscape = 320.0
        }
        
        enum Phone: CGFloat {
            case Portrait = 667.0
            case Landscape = 375.0
        }
        
        enum PhonePlus: CGFloat {
            case Portrait = 736.0
            case Landscape = 414.0
        }
    }
    
    // MARK: Outlets
    @IBOutlet var portraitLayout: UIStackView!
    @IBOutlet var landscapeLayout: UIStackView!
    @IBOutlet var background: UIImageView!
    @IBOutlet var recordButtons: [UIButton]!
    @IBOutlet var stopButtons: [UIButton]!
    @IBOutlet var statusLabels: [UILabel]!
    
    // MARK: Actions
    @IBAction func startRecording(_ sender: UIButton) {
        
        // Disable record button
        for recordButton in recordButtons {
            recordButton.isEnabled = false
        }
        
        // Enable stop button
        for stopButton in stopButtons {
            stopButton.isEnabled = true
        }
        
        // Set record actions
        canRecord = false
        canStop = true
        
        // Display on-screen recording status
        for statusLabel in statusLabels {
            statusLabel.text = "RECORDING..."
        }
        
        // Change audio control display
        setAudioControlDisplay()
        
        /**
         * Design Considerations:
         *
         * To reduce the audio file size, .m4a format is implemented instead of .wav format.
         * This enables the user to record a longer conversation.
         * However, the downside is .m4a has a reduced audio output quality compared to .wav.
         */
        
        // Set audio file name and path
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        //let recordingName = "recordedVoice.wav"
        let recordingName = "recordedVoice.m4a"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        
        // Create session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        
        // Start recording
        let formatSettings = [AVSampleRateKey : 44100.0,
                              AVNumberOfChannelsKey : 1,
                              AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                              AVEncoderBitRateKey : 192000,
                              AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue] as [String : Any]
        
        //try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        try! audioRecorder = AVAudioRecorder.init(url: filePath!, settings: formatSettings)
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        
        // Disable stop button
        for stopButton in stopButtons {
            stopButton.isEnabled = false
        }
        
        // Set record actions
        canStop = false
        
        // Display on-screen recording status
        for statusLabel in statusLabels {
            statusLabel.text = ""
        }
        
        // Change audio control display
        setAudioControlDisplay()
        
        // Stop recording
        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(false)
        
        /**
         * Design Considerations:
         *
         * Label Color property can be set directly in IB.
         * However, RGB color set through IB is visually duller than the same set through code.
         *
         * Label Text property can be set directly in IB.
         * It is set through code for consistency, since the remaining label properties are all set through code.
         */
        
        // Initialize screen contents
        for statusLabel in statusLabels {
            statusLabel.textColor = UIColor(red: 84.0/255, green: 84.0/255, blue: 84.0/255, alpha: 1.0)
            statusLabel.text = "TAP TO RECORD"
        }
        
        // Initialize record button
        for recordButton in recordButtons {
            recordButton.isExclusiveTouch = true
            recordButton.isEnabled = true
        }
        
        // Initialize stop button
        for stopButton in stopButtons {
            stopButton.isExclusiveTouch = true
            stopButton.isEnabled = false
        }
        
        // Setup screen contents
        setupRecordAudioScene()
        
        // Initialize audio control display
        setAudioControlDisplay()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Setup screen contents
        setupRecordAudioScene()
    }
    
    override func viewWillLayoutSubviews() {
        
        // Get screen height
        let currentScreenHeight = UIScreen.main.bounds.size.height
        
        // Display app title
        switch currentScreenHeight {
        case ScreenHeight.PhoneSE.Portrait.rawValue:
            navigationController?.navigationBar.setBackgroundImage(UIImage(named: "AppTitleImage-568h-Portrait"), for: .default)
        case ScreenHeight.PhoneSE.Landscape.rawValue:
            navigationController?.navigationBar.setBackgroundImage(UIImage(named: "AppTitleImage-568h-Landscape"), for: .default)
        case ScreenHeight.Phone.Portrait.rawValue, ScreenHeight.PhonePlus.Portrait.rawValue:
            navigationController?.navigationBar.setBackgroundImage(UIImage(named: "AppTitleImage-Portrait")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        case ScreenHeight.Phone.Landscape.rawValue, ScreenHeight.PhonePlus.Landscape.rawValue:
            navigationController?.navigationBar.setBackgroundImage(UIImage(named: "AppTitleImage-Landscape")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        default:
            break
        }
        
        // Initialize fonts
        for statusLabel in statusLabels {
            switch currentScreenHeight {
            case ScreenHeight.PhoneSE.Portrait.rawValue:
                statusLabel.font = UIFont(name: "Helvetica-Bold", size: 26.0/2)
            case ScreenHeight.PhoneSE.Landscape.rawValue:
                statusLabel.font = UIFont(name: "Helvetica-Bold", size: 26.0/2)
            case ScreenHeight.Phone.Portrait.rawValue:
                statusLabel.font = UIFont(name: "Helvetica-Bold", size: 32.0/2)
            case ScreenHeight.Phone.Landscape.rawValue:
                statusLabel.font = UIFont(name: "Helvetica-Bold", size: 32.0/2)
            case ScreenHeight.PhonePlus.Portrait.rawValue:
                statusLabel.font = UIFont(name: "Helvetica-Bold", size: 55.0/3)
            case ScreenHeight.PhonePlus.Landscape.rawValue:
                statusLabel.font = UIFont(name: "Helvetica-Bold", size: 55.0/3)
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        
        // Hide status bar
        return true
    }
    
    // MARK: Screen Setup
    func setupRecordAudioScene() {
        
        // Get device orientation
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        
        // Display screen background
        if orientation.isPortrait {
            background.image = UIImage(named: "StudioBackground-Portrait")
        } else if orientation.isLandscape {
            background.image = UIImage(named: "StudioBackground-Landscape")
        }
        
        // Layout screen
        if orientation.isPortrait {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.portraitLayout.isHidden = false
                self.landscapeLayout.isHidden = true
            }
        } else if orientation.isLandscape {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.portraitLayout.isHidden = true
                self.landscapeLayout.isHidden = false
            }
        }
    }
    
    func setAudioControlDisplay() {
        
        /**
         * Design Considerations:
         *
         * Button background images for Default & Disabled states can be set directly in IB.
         * However to avoid the flickering effect upon state transition, the same are set through code for better UX.
         */
        
        if canRecord {
            // Set record button normal image
            for recordButton in recordButtons {
                recordButton.setImage(UIImage(named: "Record"), for: .normal)
            }
        } else {
            // Set record button disabled image
            for recordButton in recordButtons {
                recordButton.setImage(UIImage(named: "Record-Disabled"), for: .disabled)
            }
        }
        
        if canStop {
            // Set stop button normal image
            for stopButton in stopButtons {
                stopButton.setImage(UIImage(named: "Stop"), for: .normal)
            }
        } else {
            // Set stop button disabled image
            for stopButton in stopButtons {
                stopButton.setImage(UIImage(named: "Stop-Disabled"), for: .disabled)
            }
        }
    }
    
    // MARK: Exit
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if (flag) {
            self.performSegue(withIdentifier: "toPlaybackAudio", sender: audioRecorder.url)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toPlaybackAudio") {
            let playbackAudioVC = segue.destination as! PlaybackAudioViewController
            let recordedAudioURL = sender as! NSURL
            playbackAudioVC.recordedAudioURL = recordedAudioURL
        }
    }
}

