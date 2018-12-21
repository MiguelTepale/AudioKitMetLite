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
// 1. arrIndex needs to be sent and come back from SettingsViewController
// 2. clear up handleSlider() logic
// 3. hook up duration change
//


import UIKit
import AudioKit
import JOCircularSlider

class ViewController: UIViewController, passDataBack {

    // visualization image
    @IBOutlet weak var imageView: UIImageView!
    
    // UI instantiation
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var tempoIndicator: UILabel!
    @IBOutlet weak var knob: Knob!
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tap: UIButton!
    @IBOutlet weak var staticBpmLabel: UILabel!
    
    // AudioKit objects and data
    var sequencer = AKSequencer()
    var bpmValue: Int = 120
    var beepFreq: Double = 880.0
    var arrIndex: Int?
    var arrIndexSent: Int?
    
    // tap tempo data
    let interval: TimeInterval = 0.5
    let minTaps: Int = 3
    var taps: [Double] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()

        arrIndex = 12
        
        // slider format
        slider.minimumValue = 30
        slider.maximumValue = 260
        slider.value = 120
        slider.isContinuous = true
        
        // label format
        label.text = "120"
        
        // button format
        start.applyDesign()
        
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
        var noteNum = UInt8(beepFreq.frequencyToMIDINote())
        print(noteNum)
        for i in 0..<4 {
            sequencer.tracks[0].add(noteNumber: noteNum, velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.025))
        }
        
        // add callback tracks to sequencer
        for i in 0..<4 {
            sequencer.tracks[1].add(noteNumber: MIDINoteNumber(i), velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.05))
        }

        // sequencer callback method
        callbackInst.callback = { status, noteNumber, velocity in
            if status == 144 {
                DispatchQueue.main.sync {
                    self.circularSlider.color1 = UIColor.white
                }
                print("beat number: \(noteNumber + 1)")
            } else if status == 128 {
                DispatchQueue.main.sync {
                    self.circularSlider.color1 = UIColor.lightGray
                }
            }
        }
        knob.setValue(120)
        knob.lineWidth = 4
        knob.pointerLength = 12
        knob.addTarget(self, action: #selector(ViewController.handleSlider(_:)), for: .valueChanged)
        knob.isHidden = true
        
        circularSlider.setValue(120)
        updateTempoLabel(bpm: 120)
        print(sequencer.trackCount)
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
        var tempTempo: Int
        if sender is UISlider {
            knob.setValue(slider.value, animated: true)
            tempTempo = Int(slider.value)
            circularSlider.setValue(Float(tempTempo))
            sequencer.setTempo(Double(tempTempo))
            label.text = "\(tempTempo)"
        } else if sender is JOCircularSlider.CircularSlider {
            print(circularSlider.value)
            slider.value = ((circularSlider.value * 230)+30)
            knob.setValue(slider.value)
            tempTempo = Int(slider.value)
            label.text = "\(tempTempo)"
        } else {
            slider.value = knob.value
            circularSlider.setValue(slider.value)
            tempTempo = Int(slider.value)
            circularSlider.setValue(Float(tempTempo))
            label.text = "\(tempTempo)"
        }
        updateTempoLabel(bpm: tempTempo)
    }
    
    @IBAction func handleTap(_ sender: Any) {
        let thisTap = NSDate()
        if taps.count > 0 && thisTap.timeIntervalSince1970 - taps[taps.count-1] > 2.0 {
            taps.removeAll()
        }
        print(thisTap)
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
            circularSlider.setValue(tempVal)
            updateTempoLabel(bpm: bpmValue)
        }
        
        print("tap button pressed")
    }
    

    @IBAction func showSettings(_ sender: Any) {
        print("show settings", arrIndex)
        let settingsViewController = storyboard?.instantiateViewController(withIdentifier: "sbSettingsID") as! SettingsViewController
        settingsViewController.sequencer = sequencer
        settingsViewController.arrIndex = arrIndex!
//        performSegue(withIdentifier: "indexSegue", sender: self)
        settingsViewController.arrIndexProtocol = self
        present(settingsViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SettingsViewController
        vc.arrIndex = self.arrIndex!
        vc.sequencer = self.sequencer
    }
    
//    func onUserAction(data: Int) {
//        print(data)
//        arrIndex = data
//        print("arrIndex: ", arrIndex)
//        arrIndex = arrIndex!
//    }
    
    private func updateTempoLabel(bpm: Int) {
        print(arrIndex)
        if bpm < 45 {
            tempoIndicator.text = "Grave"
        } else if bpm < 60 {
            tempoIndicator.text = "Largo"
        } else if bpm < 66 {
            tempoIndicator.text = "Larghetto"
        } else if bpm < 76 {
            tempoIndicator.text = "Adagio"
        } else if bpm < 108 {
            tempoIndicator.text = "Andante"
        } else if bpm < 120 {
            tempoIndicator.text = "Moderato"
        } else if bpm < 156 {
            tempoIndicator.text = "Allegro"
        } else if bpm < 176 {
            tempoIndicator.text = "Vivace"
        } else if bpm < 200 {
            tempoIndicator.text = "Presto"
        } else if bpm >= 200 {
            tempoIndicator.text = "Prestissimo"
        }
    }
    
    func setArrIndex(index: Int) {
        print(index)
        arrIndex = index
        print("arrIndex from delegate: ", arrIndex)
    }
}

extension UIButton {
    func applyDesign() {
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

