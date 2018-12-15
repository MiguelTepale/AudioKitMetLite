//
//  ViewController.swift
//  MidiMetronome
//
//  Created by Sam Parsons on 12/12/18.
//  Copyright © 2018 Sam Parsons. All rights reserved.
//
// OPEN TICKETS
// 1. Clean up handleTap()
// 2. Improve accuracy of tap tempo
// ---- dynamic range of values that are averaged
// ---- Create something to wipe clean the taps array
// 3. Refactor visualization


import UIKit
import AudioKit

class ViewController: UIViewController {

    // UI instantiation
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tap: UIButton!
    
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
        slider.isContinuous = false
        
        // label format
        label.text = "120"
        
        // button format
        start.setTitle("Start", for: .normal) // I don't know how to do this really
        
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
                    self.view.backgroundColor = .cyan
                }
            } else if status == 128 {
                DispatchQueue.main.sync {
                    self.view.backgroundColor = .white
                }
            }
            print("beat number: \(noteNumber + 1)")
        }
    }

    @IBAction func handleToggle(_ sender: UIButton) {
        if sequencer.isPlaying {
            start.setTitle("Start", for: .normal) // What does for: .normal
            sequencer.stop()
        } else {
            sequencer.rewind()
            print("restart sequencer position in seconds: ", sequencer.currentPosition.seconds)
            start.setTitle("Stop", for: .normal)
            sequencer.play()
        }
    }
    
    @IBAction func handleSlider(_ sender: Any) {
        var tempTempo = Int(slider.value)
        sequencer.setTempo(Double(tempTempo))
        label.text = "\(tempTempo)"
    }
    
    @IBAction func handleTap(_ sender: Any) {
        print(sequencer.currentPosition.seconds)
        let thisTap = NSDate()
        print(thisTap.timeIntervalSince1970)
        print(taps.count)
        if taps.count < 3 {
            taps.append(thisTap.timeIntervalSince1970)
            // label on view controller says "keep tapping" until minTaps is met
        } else {
            taps.append(thisTap.timeIntervalSince1970)
            var first = taps[taps.count-1]
            var second = taps[taps.count-2]
            var third = taps[taps.count-3]
            var avg = ((first-second)+(second-third)) / 2
            print("bpm: ", 60/avg)
            bpmValue = Int(60/avg)
            let tempVal = Float(60/avg)
            label.text = "\(bpmValue)"
            let labelStr = "\(bpmValue)"
            slider.setValue(tempVal, animated: false)
            sequencer.setTempo(Double(bpmValue))
        }
        print(taps)
        
        print("tap button pressed")
    }
}

