//
//  PlaybackAudioViewController.swift
//  Pitch Perfect
//
//  Created by Ramesh Parthasarathy on 10/26/16.
//  Copyright © 2016 Ramesh Parthasarathy. All rights reserved.
//

import UIKit
import AVFoundation

class PlaybackAudioViewController: UIViewController {
    
    // MARK: Properties
    var playSound: Int = Int()
    var recordedAudioURL: NSURL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
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
    
    enum SoundEffect: Int {
        case slow
        case fast
        case funny
        case evil
        case echo
        case reverb
    }
    
    // MARK: Outlets
    @IBOutlet var portraitLayout: UIStackView!
    @IBOutlet var landscapeLayout: UIStackView!
    @IBOutlet var background: UIImageView!
    @IBOutlet var slowButtons: [UIButton]!
    @IBOutlet var fastButtons: [UIButton]!
    @IBOutlet var funnyButtons: [UIButton]!
    @IBOutlet var evilButtons: [UIButton]!
    @IBOutlet var echoButtons: [UIButton]!
    @IBOutlet var reverbButtons: [UIButton]!
    @IBOutlet var stopButtons: [UIButton]!
    
    // MARK: Actions
    @IBAction func startPlayback(_ sender: UIButton) {
        
        // Set playback action
        playSound = sender.tag
        
        // Disable playback controls
        disablePlaybackControls()
        
        // Display playback choice
        displaySelectedSoundEffects()
        
        // Playback sound effects
        switch playSound {
        case SoundEffect.slow.rawValue:
            playSound(rate: 0.5)
        case SoundEffect.fast.rawValue:
            playSound(rate: 1.5)
        case SoundEffect.funny.rawValue:
            playSound(pitch: 1000)
        case SoundEffect.evil.rawValue:
            playSound(pitch: -1000)
        case SoundEffect.echo.rawValue:
            playSound(echo: true)
        case SoundEffect.reverb.rawValue:
            playSound(reverb: true)
        default:
            break
        }
    }
    
    @IBAction func stopPlayback(_ sender: UIButton) {
        
        // Stop playback
        stopAudio()
        
        // Enable playback controls
        enablePlaybackControls()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize
        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(false)
        
        // Initialize playback controls
        initializePlaybackControls()
        
        // Setup screen contents
        setupPlaybackAudioScene()
        
        // Enable playback controls
        enablePlaybackControls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Stop playback
        stopAudio()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Setup screen contents
        setupPlaybackAudioScene()
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
    func setupPlaybackAudioScene() {
        
        // Get device orientation
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        
        // Display screen background
        if orientation.isPortrait {
            background.image = UIImage(named: "TheaterBackground-Portrait")
        } else if orientation.isLandscape {
            background.image = UIImage(named: "TheaterBackground-Landscape")
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
    
    // MARK: Playback Status
    func initializePlaybackControls() {
        
        // Initialize slow playback effects button
        for slowButton in slowButtons {
            slowButton.isExclusiveTouch = true
        }
        
        // Initialize fast playback effects button
        for fastButton in fastButtons {
            fastButton.isExclusiveTouch = true
        }
        
        // Initialize funny playback effects button
        for funnyButton in funnyButtons {
            funnyButton.isExclusiveTouch = true
        }
        
        // Initialize evil playback effects button
        for evilButton in evilButtons {
            evilButton.isExclusiveTouch = true
        }
        
        // Initialize echo playback effects button
        for echoButton in echoButtons {
            echoButton.isExclusiveTouch = true
        }
        
        // Initialize reverb playback effects button
        for reverbButton in reverbButtons {
            reverbButton.isExclusiveTouch = true
        }
        
        // Initialize stop button
        for stopButton in stopButtons {
            stopButton.isExclusiveTouch = true
        }
    }
    
    func enablePlaybackControls() {
        
        // Enable slow playback effects button
        for slowButton in slowButtons {
            slowButton.isEnabled = true
            slowButton.setImage(UIImage(named: "Slow"), for: .normal)
        }
        
        // Enable fast playback effects button
        for fastButton in fastButtons {
            fastButton.isEnabled = true
            fastButton.setImage(UIImage(named: "Fast"), for: .normal)
        }
        
        // Enable funny playback effects button
        for funnyButton in funnyButtons {
            funnyButton.isEnabled = true
            funnyButton.setImage(UIImage(named: "Funny"), for: .normal)
        }
        
        // Enable evil playback effects button
        for evilButton in evilButtons {
            evilButton.isEnabled = true
            evilButton.setImage(UIImage(named: "Evil"), for: .normal)
        }
        
        // Enable echo playback effects button
        for echoButton in echoButtons {
            echoButton.isEnabled = true
            echoButton.setImage(UIImage(named: "Echo"), for: .normal)
        }
        
        // Enable reverb playback effects button
        for reverbButton in reverbButtons {
            reverbButton.isEnabled = true
            reverbButton.setImage(UIImage(named: "Reverb"), for: .normal)
        }
        
        // Disable stop button
        for stopButton in stopButtons {
            stopButton.isEnabled = false
            stopButton.setImage(UIImage(named: "StopPlayback-Disabled"), for: .disabled)
        }
    }
    
    func disablePlaybackControls() {
        
        // Disable slow playback effects button
        for slowButton in slowButtons {
            slowButton.isEnabled = false
            slowButton.setImage(UIImage(named: "Slow-Disabled"), for: .disabled)
        }
        
        // Disable fast playback effects button
        for fastButton in fastButtons {
            fastButton.isEnabled = false
            fastButton.setImage(UIImage(named: "Fast-Disabled"), for: .disabled)
        }
        
        // Disable funny playback effects button
        for funnyButton in funnyButtons {
            funnyButton.isEnabled = false
            funnyButton.setImage(UIImage(named: "Funny-Disabled"), for: .disabled)
        }
        
        // Disable evil playback effects button
        for evilButton in evilButtons {
            evilButton.isEnabled = false
            evilButton.setImage(UIImage(named: "Evil-Disabled"), for: .disabled)
        }
        
        // Disable echo playback effects button
        for echoButton in echoButtons {
            echoButton.isEnabled = false
            echoButton.setImage(UIImage(named: "Echo-Disabled"), for: .disabled)
        }
        
        // Disable reverb playback effects button
        for reverbButton in reverbButtons {
            reverbButton.isEnabled = false
            reverbButton.setImage(UIImage(named: "Reverb-Disabled"), for: .disabled)
        }
        
        // Enable stop button
        for stopButton in stopButtons {
            stopButton.isEnabled = true
            stopButton.setImage(UIImage(named: "StopPlayback"), for: .normal)
        }
    }
    
    func displaySelectedSoundEffects() {
        
        // Display selected sound effects
        switch playSound {
        case SoundEffect.slow.rawValue:
            for slowButton in slowButtons {
                slowButton.setImage(UIImage(named: "Slow-Selected"), for: .disabled)
            }
        case SoundEffect.fast.rawValue:
            for fastButton in fastButtons {
                fastButton.setImage(UIImage(named: "Fast-Selected"), for: .disabled)
            }
        case SoundEffect.funny.rawValue:
            for funnyButton in funnyButtons {
                funnyButton.setImage(UIImage(named: "Funny-Selected"), for: .disabled)
            }
        case SoundEffect.evil.rawValue:
            for evilButton in evilButtons {
                evilButton.setImage(UIImage(named: "Evil-Selected"), for: .disabled)
            }
        case SoundEffect.echo.rawValue:
            for echoButton in echoButtons {
                echoButton.setImage(UIImage(named: "Echo-Selected"), for: .disabled)
            }
        case SoundEffect.reverb.rawValue:
            for reverbButton in reverbButtons {
                reverbButton.setImage(UIImage(named: "Reverb-Selected"), for: .disabled)
            }
        default:
            break
        }
    }
}

