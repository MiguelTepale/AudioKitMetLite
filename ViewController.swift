//
//  ViewController.swift
//  MidiMetronome
//
//  Created by Sam Parsons on 12/12/18.
//  Copyright © 2018 Sam Parsons. All rights reserved.
//
// OPEN TICKETS
// 1. Start/Stop button label title switch -- what does for: .normal mean??
// 2. Improve accuracy of tap tempo
// ---- Look at timing mechanisms, incorporate more data into calculation
// ---- Create something to wipe clean the taps array
// 3. Change sound from snare to simple synth


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
        start.setTitle("Start", for: .normal) // I don't know how to do this really
        
        let sound = AKSynthSnare()
        var beep = AKOscillatorBank.init(waveform: AKTable(.sine), attackDuration: 0.01, decayDuration: 0.05, sustainLevel: 0.1, releaseDuration: 0.05, pitchBend: 0, vibratoDepth: 0, vibratoRate: 0)
        
        var beepNode = AKMIDINode(node: beep)
//        let envelope = AKAmplitudeEnvelope(beepNode)
//        envelope.attackDuration = 0.01
//        envelope.decayDuration = 0.1
//        envelope.sustainLevel = 0.1
//        envelope.releaseDuration = 0.3
        let callbackInst = AKMIDICallbackInstrument()
        
        AudioKit.output = beepNode
        try! AudioKit.start()
        
        print("here")
    
        let metTrack = sequencer.newTrack()
        sequencer.setLength(AKDuration(beats: 4))
        sequencer.tracks[0].setMIDIOutput(beepNode.midiIn)
        let cbTrack = sequencer.newTrack()
        sequencer.tracks[1].setMIDIOutput(callbackInst.midiIn)
    
        print(sequencer.tracks)
    
        // this will trigger the sampler on the four down beats
        sequencer.tracks[0].add(noteNumber: 80, velocity: 100, position: AKDuration(beats: Double(1)), duration: AKDuration(beats: 0.05))
        
        sequencer.tracks[0].add(noteNumber: 80, velocity: 100, position: AKDuration(beats: Double(0)), duration: AKDuration(beats: 0.05))

        sequencer.tracks[0].add(noteNumber: 80, velocity: 100, position: AKDuration(beats: Double(2)), duration: AKDuration(beats: 0.05))

        sequencer.tracks[0].add(noteNumber: 80, velocity: 100, position: AKDuration(beats: Double(3)), duration: AKDuration(beats: 0.05))
        
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

    @IBAction func handleToggle(_ sender: UIButton) {
        // should restart sequence playback to 0 seconds position
        if sequencer.isPlaying {
            start.setTitle("Start", for: .normal)
            sequencer.stop()
        } else {
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
            sequencer.setTempo(Double(bpmValue))
        }
        print(taps)
        
        print("tap button pressed")
    }
}

