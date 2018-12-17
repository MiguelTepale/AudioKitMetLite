//
//  ViewController.swift
//  MidiMetronome
//
//  Created by Sam Parsons on 12/12/18.
//  Copyright © 2018 Sam Parsons. All rights reserved.
//
//
//
// OPEN TICKETS
// 1. Improve accuracy of tap tempo - working seemingly better with first refactor
// ---- increasing range of values that are averaged with consecutive clips - make this dynamic?
// ---- wipe clean the taps array at in intervals triggered directly after the "first tap" ***
// 2. Eliminate performance losses through refactoring visualization - refactored, at bpm > 200
// 6. change range of knob instantiation
// 7. clear up handleSlider() logic
// 8. stylize and hook up circularSlider
//
// QUESTIONS
// 1. How to implement "lastTap" callback to wipe taps array clean
// --- How to know what is a last tap? Measure distance from most recent tap time
// --- Similar to setInterval(), using a conditional in the body
// 2. How to extract some data and methods into classes?
// 3. What is .normal in button.setTitle()?
// 4. How to make "Keep Tapping" dynamically fit inside of tap button


import UIKit
import AudioKit

class ViewController: UIViewController {
    
    
    
    // last tap timer
//    var lastTapTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: (#selector(ViewController.)), userInfo: nil, repeats: true)
    var lastTapTimer: Timer?

    // visualization image
    @IBOutlet weak var imageView: UIImageView!
    
    // UI instantiation
    @IBOutlet weak var knob: Knob!
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tap: UIButton!
    @IBOutlet weak var staticBpmLabel: UILabel!
    
    // AudioKit objects and data
    let sequencer = AKSequencer()
    var bpmValue: Int = 120
    
    // tap tempo data
    let interval: TimeInterval = 0.5
    let minTaps: Int = 3
    var taps: [Double] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // slider format
        slider.minimumValue = 30
        slider.maximumValue = 260
        slider.value = 120
        slider.isContinuous = true
        
        // label format
        label.text = "120"
        
        // button format
        start.setTitle("Start", for: .normal) // what is .normal ??
        start.layer.cornerRadius = 4
        
        // visualization format
        self.imageView.isHidden = true
        
        // instrument set up - sound and callback
        var beep = AKOscillatorBank.init(waveform: AKTable(.sine), attackDuration: 0.01, decayDuration: 0.05, sustainLevel: 0.1, releaseDuration: 0.05, pitchBend: 0, vibratoDepth: 0, vibratoRate: 0)
        var beepNode = AKMIDINode(node: beep)
        let callbackInst = AKMIDICallbackInstrument()
        
        // AudioKit final set up phase
        AudioKit.output = beepNode
        try! AudioKit.start()
    
        // instantiating metronome and callback tracks and assigning their respective i/o
        let metTrack = sequencer.newTrack()
        sequencer.tracks[0].setMIDIOutput(beepNode.midiIn)
        let cbTrack = sequencer.newTrack()
        sequencer.tracks[1].setMIDIOutput(callbackInst.midiIn)
        
        // sequencer settings initiation
        sequencer.setLength(AKDuration(beats: 4))
        sequencer.setTempo(120)
        sequencer.enableLooping()
    
        // add audio tracks to sequencer
        for i in 0..<4 {
            sequencer.tracks[0].add(noteNumber: 80, velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.05))
        }
        
        // add callback tracks to sequencer
        for i in 0..<4 {
            sequencer.tracks[1].add(noteNumber: MIDINoteNumber(i), velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.05))
        }

        // sequencer callback method
        callbackInst.callback = { status, noteNumber, velocity in
            if status == 144 {
                DispatchQueue.main.sync {
                    self.imageView.isHidden = false
                }
                print("beat number: \(noteNumber + 1)")
            } else if status == 128 {
                DispatchQueue.main.sync {
                    self.imageView.isHidden = true
                }
            }
        }
        knob.setValue(120)
        knob.lineWidth = 4
        knob.pointerLength = 12
        knob.addTarget(self, action: #selector(ViewController.handleSlider(_:)), for: .valueChanged)
        
    }

    @IBAction func handleToggle(_ sender: UIButton) {
        if sequencer.isPlaying {
            start.setTitle("Start", for: .normal) // What does for: .normal mean
            sequencer.stop()
        } else {
            sequencer.rewind()
            print("restart sequencer position in seconds: ", sequencer.currentPosition.seconds)
            start.setTitle("Stop", for: .normal)
            sequencer.play()
        }
    }
    
    @IBAction func handleSlider(_ sender: Any) {
        if sender is UISlider {
            knob.setValue(slider.value, animated: true)
            var tempTempo = Int(slider.value)
            sequencer.setTempo(Double(tempTempo))
            label.text = "\(tempTempo)"
        } else {
            slider.value = knob.value
            var tempTempo = Int(slider.value)
            label.text = "\(tempTempo)"
        }
//        updateLabel()

    }
    
    @IBAction func handleTap(_ sender: Any) {
        let thisTap = NSDate()
        var avg: Double
        if taps.count < 3 {
            taps.append(thisTap.timeIntervalSince1970)
            tap.setTitle("Keep Tapping", for: .normal) // how to make this dynamically fit in the button without elipses??
            // label on view controller says "keep tapping" until minTaps is met
        } else {
            taps.append(thisTap.timeIntervalSince1970)
            if taps.count == 3 {
                var first = taps[taps.count-1]
                var second = taps[taps.count-2]
                var third = taps[taps.count-3]
                avg = ((first-second)+(second-third)) / 2
            } else {
                var first = taps[taps.count-1]
                var second = taps[taps.count-2]
                var third = taps[taps.count-3]
                var fourth = taps[taps.count-4]
                avg = ((first-second)+(second-third)+(third-fourth)) / 3
            }
            print("bpm: ", 60/avg)
            bpmValue = Int(60/avg)
            let tempVal = Float(60/avg)
            label.text = "\(bpmValue)"
            slider.setValue(tempVal, animated: false)
            sequencer.setTempo(Double(bpmValue))
            knob.setValue(tempVal, animated: true)
        }
        

        

        print("tap button pressed")
        
        // tap interval
//        if (!lastTapTimer.isValid) {
//            lastTapTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { timer in
//                print("checking for last tap")
//            })
//        } else {
//            lastTapTimer?.invalidate()
//        }
        
    }
    
//    private func updateLabel() {
//        label.text = String(format: "%.2f", knob.value)
//    }
    
    
    
//    @objc func checkLastTap() {
//        NSLog("checking for last tap")
//    }
}

