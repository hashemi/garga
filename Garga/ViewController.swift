//
//  ViewController.swift
//  Garga
//
//  Created by Ahmad Alhashemi on 2019-03-15.
//  Copyright © 2019 Ahmad Alhashemi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var sourceTextView: NSTextView!

    var source: String {
        return sourceTextView.string
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func run(_ sender: Any) {
        // find an Arabic voice
        guard let voice =
            (NSSpeechSynthesizer
                .availableVoices
                .filter { voice in
                    let attr = NSSpeechSynthesizer.attributes(forVoice: voice)
                    guard let locale = attr[NSSpeechSynthesizer.VoiceAttributeKey.localeIdentifier] as? String else {
                        return false
                    }
                    
                    return locale.starts(with: "ar")
                }
                .first)
        else {
            return
        }
        
        // try to initialize the synthesizer with an arabic voice
        guard let synthesizer = NSSpeechSynthesizer(voice: voice) else {
            return
        }
        
        var s = Scanner(source: source)
        while true {
            do {
                let token = try s.nextToken()
                print(token)
                guard token != .eof else { break }
            } catch {
                print(error)
                break
            }
        }

        synthesizer.startSpeaking(source)
    }
}

