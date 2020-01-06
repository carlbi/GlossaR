//
//  ViewController.swift
//  GlossaR
//
//  Created by Carl Philipp Biagosch on 26.12.19.
//  Copyright © 2019 Project GlossaR. All rights reserved.
//

import Cocoa
import CoreData

class ViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var AddButton: NSButton!
    @IBOutlet weak var DeleteButton: NSButton!
    @IBOutlet weak var TextEnter: NSTextField!
    @IBOutlet weak var KeywordsEnter: NSTextField!
    @IBOutlet weak var ArticleTitle: NSTextField!
    @IBOutlet weak var GlossaryList: NSTableView!
    @IBOutlet weak var SearchField: NSSearchField!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var editMode: Bool = false
    var selected: String? = nil
    
    var entries: [NSManagedObject]? = []
    
    var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Fetching from Core Data
        self.updateEntries()
        // Delegates
        self.ArticleTitle.delegate = self
        self.TextEnter.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Show "nothing selected"
        self.nothingSelected()

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func nothingSelected() {
        self.selected = nil
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
        self.ArticleTitle.stringValue = "Please select article"
        self.ArticleTitle.isEditable = false
    }
    
    func somethingSelected(name: String?) {
        self.selected = name
        // Enable Textfields
        self.ArticleTitle.isEditable = true
        self.TextEnter.isEditable = true
        self.KeywordsEnter.isEditable = true
        // Reset for new input
        self.TextEnter.alignment = .left
        self.TextEnter.textColor = NSColor.black
        self.KeywordsEnter.alignment = .left
        self.KeywordsEnter.textColor = NSColor.black
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        self.editMode(enabled: false)
        return true
    }
    
    @IBAction func AddButtonPressed(_ sender: NSButton) {
        // Disable UI
        self.editMode(enabled: false)
        self.somethingSelected(name: nil)
        self.ArticleTitle.stringValue = "New Title"
        self.ArticleTitle.becomeFirstResponder()
        self.TextEnter.stringValue = ""
        self.KeywordsEnter.stringValue = ""
    }
    
    @IBAction func DeleteButtonPressed(_ sender: NSButton) {
        self.deleteEntry(name: self.selected)
        self.reloadFileList()
        self.nothingSelected()
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
                let success: Bool = self.saveEntry()
                if success {
                    self.deleteEntry(name: self.selected)
                    self.reloadFileList()
                    self.editMode(enabled: true)
                    self.nothingSelected()
                }
                else{
                    let msg: String = "Maybe the article title already exists?"
                    _ = self.dialogOKCancel(question: "Unable to save", text: msg)
                    self.ArticleTitle.becomeFirstResponder()
                }
                
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.displayEntry()
    }
    
    func displayEntry() {
        let entrySelected = tableView.selectedRow
        if entrySelected < 0 {
            self.nothingSelected()
            return
        }
        guard let entry = entries?[entrySelected] else {
            return
        }
        let name: String = entry.value(forKey: "name") as! String
        let text: String = entry.value(forKey: "text") as! String
        let keywords: String = entry.value(forKey: "keywords") as! String
        
        self.ArticleTitle.stringValue = name
        self.TextEnter.stringValue = text
        self.KeywordsEnter.stringValue = keywords
        
        self.somethingSelected(name: name)
    }
    
    func reloadFileList() {
        self.updateEntries()
        tableView.reloadData()
    }
    
    func saveEntry() -> Bool {
        let name: String = self.ArticleTitle.stringValue
        let text: String = self.TextEnter.stringValue
        let keywords: String = self.KeywordsEnter.stringValue
        
        if let currentEntries = self.entries {
            for entry in currentEntries {
                if entry.value(forKey: "name") as! String == name {
                    return false
                }
            }
        }
        
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            return false
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Entry",
                                       in: managedContext)!
        let entry = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        entry.setValue(name, forKeyPath: "name")
        entry.setValue(text, forKeyPath: "text")
        entry.setValue(keywords, forKeyPath: "keywords")

        do {
            try managedContext.save()
            self.updateEntries()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        return true
    }
    
    func deleteEntry(name: String?){
        guard let selected = name else {
            return
        }
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Entry")
        guard let result = try? managedContext.fetch(fetchRequest) else { return }
        for object in result {
            if object.value(forKey: "name") as! String == selected {
                managedContext.delete(object)
            }
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateEntries() {
        guard let appDelegate =
            NSApp.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Entry")
        do {
            entries = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func editMode(enabled: Bool){
        self.tableView.isEnabled = enabled
        self.SearchField.isEnabled = enabled
        self.AddButton.isEnabled = enabled
        self.DeleteButton.isEnabled = enabled
    }

    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }


}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entries?.count ?? 0
    }
    
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = entries?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.value(forKey: "name") as! String
            cellIdentifier = "EntryCell"
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
