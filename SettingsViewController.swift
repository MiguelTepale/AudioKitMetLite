//
//  SettingsViewController.swift
//  
//
//  Created by Andrew Seeley.
//  Modified for MidiMetronome by Sam Parsons on 12/18/18.
//
// 

import UIKit
import AudioKit

class SettingsViewController: UIViewController {

//    var mainView: ViewController = ViewController(nibName: nil, bundle: nil)
    var sequencer = AKSequencer()
    
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var decFreqBtn: UIButton!
    @IBOutlet weak var incFreqBtn: UIButton!
    
    var beepFreqArr: [Double] = [
        440.00, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61,
        880.00, 932.33, 987.77, 1046.5, 1108.7, 1174.7, 1244.5, 1318.5, 1396.9, 1480.0, 1568.0, 1661.2, 1760.0
    ]
    var beepNoteArr: [String] = [
        "A4", "Bb4", "B4", "C5", "Db5", "D5", "Eb5", "E5", "F5", "Gb5", "G5", "Ab5", "A5", "Bb5", "B5", "C6", "Db6", "D6", "Eb6", "E6", "F6", "Gb6", "G6", "Ab6", "A6"
    ]
    var arrIndex = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        self.showAnimate()
        print(sequencer.trackCount)
//        print(mainView.sequencer.trackCount)
    }
    

    @IBAction func closeSettings(_ sender: Any)  {
        dismiss(animated: true, completion: nil)
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion: {(finished : Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        });
    }
    
    @IBAction func increaseFreq(_ sender: Any) {
        print("increasing frequency")
        var tempLabel = freqLabel.text
        generateMIDIOutput(note: tempLabel ?? "C5", incDec: true)
    }
    
    @IBAction func decreaseFreq(_ sender: Any) {
        print("decreasing frequency")
        var tempLabel = freqLabel.text
        generateMIDIOutput(note: tempLabel ?? "C5", incDec: false)
    }
    
    func generateMIDIOutput(note: String, incDec: Bool) {
        print("generating MIDI output number")
        if (incDec) { // incDec is a bool to keep track which button pressed
            if beepFreqArr[arrIndex] == 1760.00 {
                print("max index")
            } else {
                print("increase button pressed")
                arrIndex = arrIndex + 1
                print("index: ", arrIndex)
                freqLabel.text = beepNoteArr[arrIndex]
                
                sequencer.tracks[0].replaceMIDINoteData(with: [])
                
                var noteNum = UInt8(beepFreqArr[arrIndex].frequencyToMIDINote())
                print(noteNum)
                for i in 0..<4 {
                    sequencer.tracks[0].add(noteNumber: noteNum, velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.025))
                }
                print(beepFreqArr[arrIndex])
            }
        } else {
            if beepFreqArr[arrIndex] == 440.00 {
                print("min index")
            } else {
                print("decrease button pressed")
                arrIndex = arrIndex - 1
                print("index: ", arrIndex)
                freqLabel.text = beepNoteArr[arrIndex]
                print(sequencer.tracks[0])
                
                sequencer.tracks[0].replaceMIDINoteData(with: [])
                
                var noteNum = UInt8(beepFreqArr[arrIndex].frequencyToMIDINote())
                print(noteNum)
                for i in 0..<4 {
                    sequencer.tracks[0].add(noteNumber: noteNum, velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.025))
                }
                print(beepFreqArr[arrIndex])
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
