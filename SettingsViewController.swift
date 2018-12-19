//
//  SettingsViewController.swift
//  
//
//  Created by Andrew Seeley.
//  Modified for MidiMetronome by Sam Parsons on 12/18/18.
//
// OPEN TICKETS
// 1. wtf kind of data structures can I use and how do I use them?

import UIKit
import AudioKit

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var decFreqBtn: UIButton!
    @IBOutlet weak var incFreqBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        self.showAnimate()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func closeSettings(_ sender: Any) {
//        self.view.removeFromSuperview()
        self.removeAnimate()
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
        generateNextNote(note: tempLabel ?? "C5")
    }
    
    @IBAction func decreaseFreq(_ sender: Any) {
        print("decreasing frequency")
        var tempLabel = freqLabel.text
        generateMIDIOutput(note: tempLabel ?? "C5", incDec: false)
        generateNextNote(note: tempLabel ?? "C5")
    }
    
    func generateMIDIOutput(note: String, incDec: Bool) {
        print("generating MIDI output number")
        if (incDec) { // incDec is a bool to keep track which button pressed
            print("increase button pressed")
        } else {
            print("decrease button pressed")
        }
    }
    
    func generateNextNote(note: String) {
        print(note)
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
