//
//  ViewController.swift
//  EggTimer
//
//  Created by Angela Yu on 08/07/2019.
//  Updated by Leon McLeggan on 23/04/2020.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var areEggsBeingCooked = false
    let eggCookingTimeDict = ["soft": 300, "medium": 420, "hard": 720]
    var player: AVAudioPlayer!
    var timer: Timer!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cookingTimeProgress: UIProgressView!
    @IBOutlet weak var cancelOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3")
            self.player = try AVAudioPlayer(contentsOf: url!)
        } catch {
            print("Hmmm... could not locate sound.")
        }
        
        self.cookingTimeProgress.layer.cornerRadius = 10.0
        self.cookingTimeProgress.clipsToBounds = true
        resetUI()
    }
    
    @objc func resetUI() {
        self.cookingTimeProgress.setProgress(0.0, animated: true)
        self.titleLabel.text = "How do you like your eggs?"
        self.cancelOrderButton.isHidden = true
    }
    
    // UI functions
    @IBAction func selectCookingTime(_ sender: UIButton) {
        // Prevent multiple eggs from being cooked. It will just get messy!
        if (!areEggsBeingCooked) {
            guard let cookingTime = eggCookingTimeDict[sender.currentTitle!.lowercased()] else {
                // No matching element in eggCookingTimeDict
                return
            }
            // Prepare cooking area
            self.titleLabel.text = "Preparing your eggs..."
            performCountDown(from: cookingTime)
            areEggsBeingCooked.toggle()
            cancelOrderButton.isHidden = false
        }
    }
    
    @IBAction func cancelOrder(_ sender: UIButton) {
        timer.invalidate()
        areEggsBeingCooked.toggle()
        resetUI()
    }
    
    func performCountDown(from:Int = 5) {
        var seconds = from
        let sentinel = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            // Update progress bar
            self.cookingTimeProgress.setProgress(1.0-(Float(seconds)/Float(from)), animated: true)
            if (self.cookingTimeProgress.progress > 0.75) {
                self.titleLabel.text = "Just a little longer..."
            }
            
            seconds -= 1
            if (seconds < sentinel) {
                self.player.play()
                // Update UI
                self.titleLabel.text = "Done! Who\'s next?"
                self.areEggsBeingCooked.toggle()
                self.cancelOrderButton.isHidden = true
                Timer.scheduledTimer(timeInterval: 3.75, target: self, selector: #selector(self.resetUI), userInfo: nil, repeats: false)
                timer.invalidate()
            }
        })
    }
}
