//
//  SettingsViewController.swift
//  
//
//  Created by Sam Parsons.
//
// 

import UIKit
import AudioKit

protocol passDataBack {
    func setArrIndex(index: Int, duration: Int)
}

class SettingsViewController: UIViewController, UIWebViewDelegate, UINavigationControllerDelegate {

    var mainView: ViewController = ViewController(nibName: nil, bundle: nil)
    var sequencer = AKSequencer()
    var arrIndexProtocol: passDataBack?
    
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var durLabel: UILabel!
    @IBOutlet weak var decFreqBtn: UIButton!
    @IBOutlet weak var incFreqBtn: UIButton!

    var beepNumberArr: [MIDINoteNumber] = []
    var beepNoteArr: [String] = [
        "A4", "Bb4", "B4", "C5", "Db5", "D5", "Eb5", "E5", "F5", "Gb5", "G5", "Ab5", "A5", "Bb5", "B5", "C6", "Db6", "D6", "Eb6", "E6", "F6", "Gb6", "G6", "Ab6", "A6"
    ]
    var arrIndex: Int = 12 // how to read this variable from segue?
    var beepDuration: Int = 50 //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        for i in 0...25 {
            var tempVar = i + 69
            beepNumberArr.append(MIDINoteNumber(tempVar))
        }
        print(beepNumberArr)
    
        print(arrIndex)
        freqLabel.text = beepNoteArr[arrIndex]
        durLabel.text = "\(beepDuration)"
        print("set up arrINdex: ", arrIndex)
    }
    

    @IBAction func closeSettings(_ sender: Any)  {
        print("arrIndexProtocol")
        print(arrIndex)
//        performSegue(withIdentifier: "indexSegueBack", sender: self)
        arrIndexProtocol?.setArrIndex(index: arrIndex, duration: beepDuration)
//        mainView.onUserAction(data: arrIndex)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        mainView.arrIndex = self.arrIndex
        mainView.sequencer = self.sequencer
    }
    
//    func showAnimate() {
//        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//        self.view.alpha = 0.0;
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.alpha = 1.0
//            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        });
//    }
//
//    func removeAnimate() {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//            self.view.alpha = 0.0;
//        }, completion: {(finished : Bool) in
//            if (finished) {
//                self.view.removeFromSuperview()
//            }
//        });
//    }
    
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
    
    @IBAction func incDuration(_ sender: Any) {
        beepDuration = beepDuration + 1
        durLabel.text = "\(beepDuration)"
        print("incremented duration: ", beepDuration)
    }
    
    
    @IBAction func decDuration(_ sender: Any) {
        beepDuration = beepDuration - 1
        durLabel.text = "\(beepDuration)"
        print("decremented duration: ", beepDuration)
    }
    
    func generateMIDIOutput(note: String, incDec: Bool) {
        print("generating MIDI output number")
        if (incDec) { // incDec is a bool to keep track which button pressed
            if arrIndex == 24 {
                print("max index")
            } else {
                print("increase button pressed")
                arrIndex = arrIndex + 1
                print("index: ", arrIndex)
                freqLabel.text = beepNoteArr[arrIndex]
                
                sequencer.tracks[0].replaceMIDINoteData(with: [])
                
                var noteNum: MIDINoteNumber = MIDINoteNumber(beepNumberArr[arrIndex])
                print(noteNum)
                for i in 0..<4 {
                    sequencer.tracks[0].add(noteNumber: noteNum, velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.025))
                }
                
            }
        } else {
            if arrIndex == 0 {
                print("min index")
            } else {
                print("decrease button pressed")
                arrIndex = arrIndex - 1
                print("index: ", arrIndex)
                freqLabel.text = beepNoteArr[arrIndex]
                print(sequencer.tracks[0])
                
                sequencer.tracks[0].replaceMIDINoteData(with: [])
                
                var noteNum: MIDINoteNumber = MIDINoteNumber(beepNumberArr[arrIndex])
                print(noteNum)
                for i in 0..<4 {
                    sequencer.tracks[0].add(noteNumber: noteNum, velocity: 100, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.025))
                }
            }
        }
    }
    
    private func webViewDidFinishLoad(webView: UIWebView) {
        arrIndexProtocol?.setArrIndex(index: arrIndex, duration: beepDuration)
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

extension SettingsViewController {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (mainView as? ViewController)?.arrIndex = arrIndex
    }
}
