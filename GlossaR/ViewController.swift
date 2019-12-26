//
//  ViewController.swift
//  GlossaR
//
//  Created by Carl Philipp Biagosch on 26.12.19.
//  Copyright © 2019 Project GlossaR. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var AddButton: NSButton!
    @IBOutlet weak var DeleteButton: NSButton!
    @IBOutlet weak var TextEnter: NSTextField!
    @IBOutlet weak var KeywordsEnter: NSTextField!
    @IBOutlet weak var ArticleTitle: NSTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Delegates
        self.ArticleTitle.delegate = self
        self.TextEnter.delegate = self
        // Disable TextEnter until selected
        self.TextEnter.isEditable = false
        self.TextEnter.stringValue = "Nothing selected"
        self.TextEnter.alignment = .center
        self.TextEnter.textColor = NSColor.lightGray
        // Disable KeyWordEnter until selected
        self.KeywordsEnter.stringValue = "Nothing selected"
        self.KeywordsEnter.alignment = .center
        self.KeywordsEnter.textColor = NSColor.lightGray
        // Disable ArticleTitle until selected
        self.ArticleTitle.isEditable = false

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func AddButtonPressed(_ sender: NSButton) {
        // Enable Textfields
        self.ArticleTitle.isEditable = true
        self.TextEnter.isEditable = true
        self.KeywordsEnter.isEditable = true
        // Reset for new input
        self.ArticleTitle.stringValue = "New Title"
        self.ArticleTitle.becomeFirstResponder()
        self.TextEnter.stringValue = ""
        self.TextEnter.alignment = .left
        self.TextEnter.textColor = NSColor.black
        self.KeywordsEnter.stringValue = ""
        self.KeywordsEnter.alignment = .left
        self.KeywordsEnter.textColor = NSColor.black    }
    
    @IBAction func DeleteButtonPressed(_ sender: NSButton) {
    }
    
    @IBAction func textFieldAction(sender: NSTextField) {
        DispatchQueue.main.async {
            sender.window?.makeFirstResponder(nil)
            if(self.ArticleTitle == sender){
                self.TextEnter.becomeFirstResponder()
            }
            else if(self.TextEnter == sender){
                self.KeywordsEnter.becomeFirstResponder()
            }
            else if(self.KeywordsEnter == sender){
                // Save and add to tableview
            }
        }
    }

}

