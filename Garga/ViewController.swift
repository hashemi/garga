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
        sourceTextView.font = NSFont(name: "SF Mono", size: 16.0)
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
        
        var allWords = ""
        let say = Value.native(["الكلام"], { variables in
            if let words = variables["الكلام"]?.stringValue {
                allWords = allWords + "\n" + words
            }
            return .true
        })
        
        do {
            var i = Interpreter(variables: ["غول": say])
            var s = Scanner(source: source)
            var tokens: [Token] = []
            repeat {
                tokens.append(try s.nextToken())
            } while tokens.last != .eof
            var p = Parser(tokens: tokens)
            let prog = try p.parse()
            
            _ = try i.eval(prog)
        } catch {
            allWords = "غلط"
            print(error)
        }
        
        synthesizer.startSpeaking(allWords)
    }
}
