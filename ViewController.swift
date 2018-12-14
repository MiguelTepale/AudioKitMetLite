//
//  ViewController.swift
//  MidiMetronome
//
//  Created by Sam Parsons on 12/12/18.
//  Copyright © 2018 Sam Parsons. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var slider: UISlider!

    @IBOutlet weak var label: UILabel!
    let sequencer = AKSequencer()
    
    @IBOutlet weak var tap: UIButton!
    // tap tempo
    let interval: TimeInterval = 0.5
    let minTaps: Int = 3
    var taps: [Double] = []
    var bpmValue: Int = 120
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // slider format
        slider.minimumValue = 30
        slider.maximumValue = 260
        slider.value = 120
        slider.isContinuous = false
        
        // label format
        label.text = "120"
        
        // button format
//        start.setTitle("Start", for: UIControl.State) // I don't know how to do this really
        
        let sound = AKSynthSnare()
        let callbackInst = AKMIDICallbackInstrument()
        
        AudioKit.output = sound
        try! AudioKit.start()
        
        print("here")
    
        let metTrack = sequencer.newTrack()
        sequencer.setLength(AKDuration(beats: 4))
        sequencer.tracks[0].setMIDIOutput(sound.midiIn)
        let cbTrack = sequencer.newTrack()
        sequencer.tracks[1].setMIDIOutput(callbackInst.midiIn)
    
        print(sequencer.tracks)
    
        // this will trigger the sampler on the four down beats
        sequencer.tracks[0].add(noteNumber: 60, velocity: 100, position: AKDuration(beats: Double(1)), duration: AKDuration(beats: 0.05))
        
        sequencer.tracks[0].add(noteNumber: 60, velocity: 100, position: AKDuration(beats: Double(0)), duration: AKDuration(beats: 0.05))

        sequencer.tracks[0].add(noteNumber: 60, velocity: 100, position: AKDuration(beats: Double(2)), duration: AKDuration(beats: 0.05))

        sequencer.tracks[0].add(noteNumber: 60, velocity: 100, position: AKDuration(beats: Double(3)), duration: AKDuration(beats: 0.05))
        
        print(sequencer.tracks[0].getMIDINoteData())
        // set the midiNote number to the current beat number
        sequencer.tracks[1].add(noteNumber: MIDINoteNumber(0), velocity: 100, position: AKDuration(beats: Double(0)), duration: AKDuration(beats: 0.05))
        sequencer.tracks[1].add(noteNumber: MIDINoteNumber(0), velocity: 100, position: AKDuration(beats: Double(1)), duration: AKDuration(beats: 0.05))
        sequencer.tracks[1].add(noteNumber: MIDINoteNumber(0), velocity: 100, position: AKDuration(beats: Double(2)), duration: AKDuration(beats: 0.05))
        sequencer.tracks[1].add(noteNumber: MIDINoteNumber(0), velocity: 100, position: AKDuration(beats: Double(3)), duration: AKDuration(beats: 0.05))

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
        
        sequencer.setTempo(120)
        sequencer.enableLooping()
//        sequencer.play()
    }

    @IBAction func handleToggle(_ sender: Any) {
        // should restart sequence playback to 0 seconds position
        if sequencer.isPlaying {
            sequencer.stop()
        } else {
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
//        if var lastTap = taps.last {
//            if NSTimeIntervalSince1970(Double(lastTap)) > interval {
//                taps.removeAll()
//            }
//        }
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
        }
        print(taps)
//        let firstTap = taps.first
//        let averageIntervals = thisTap.timeIntervalSince(firstTap) / Double(taps.count - 1)
        
        print("tap button pressed")
    }
}

