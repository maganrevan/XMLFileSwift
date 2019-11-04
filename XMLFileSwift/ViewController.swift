//
//  ViewController.swift
//  XMLFileSwift
//
//  Created by Magnus Kruschwitz on 24.10.19.
//  Copyright © 2019 Magnus Kruschwitz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, XMLParserDelegate{
    
    var helper = helperClass(sFileType: "xml")
    
    @IBOutlet weak var textField1: NSTextField!
    @IBOutlet weak var textField2: NSTextField!
    @IBOutlet weak var textField3: NSTextField!
    @IBOutlet weak var btnWrite: NSButton!
    @IBOutlet weak var btnRead: NSButton!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    @IBOutlet weak var folderPath: NSTextField!
    @IBOutlet weak var messageLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        helper.setView(oView: self)
        folderPath.stringValue = FileManager.default.currentDirectoryPath
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func btnCloseClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        
        if helper.save(aFields: [textField1, textField2, textField3]) {
            messageLabel.stringValue = "Speichern war erfolgreich"
        }
        else {
            messageLabel.stringValue = "Es gab ein Fehler beim Speichern, bitte lies den Fehlerlog."
        }
    }
    
    @IBAction func btnLoadClicked(_ sender: Any) {
        
        if popUpButton.numberOfItems > 0 {
            popUpButton.removeAllItems()
        }
        
        if helper.load() {
            messageLabel.stringValue = "Laden war erfolgreich"
        }
        else {
            messageLabel.stringValue = "Es gab ein Fehler beim Laden, bitte lies den Fehlerlog."
        }
    }
    
    /**
       Diese Methode der View nimmt den aktuellen Pfad des Files, welches exitiert entgegen und parst das XML-File und delegiert es. 
    - returns: Gibt bei Erfolg true zurück, bei Problemen wird fals zurückgegeben und es gibt in der Konsole eine Ausgabe potentieller Fehler.
    
    # Example #
    ```
     if helper.oView!.useParser(path: URL(fileURLWithPath: helper.fileArray["sFileLink"] as! String)) {
           print("erfolg")
     }
     ```
    */
    func useParser(path: URL) -> Bool{
        if let xmlParser = XMLParser(contentsOf: path){
            xmlParser.delegate = self
            xmlParser.parse()
            return true
        }
        else{
            print("laden nicht möglich.")
            return false
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //Gibt den Knotennamen aus (Starttag)
        //print("1. \(elementName)")
        if(attributeDict["fieldIndex"] != nil){
            helper.setTmpPosi(iPosi: Int(attributeDict["fieldIndex"]!)!)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //Gibt den Knotennamen aus (Endtag)
        //print("2. \(elementName)")
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        helper.writeInField(aFields: [textField1, textField2, textField3], text: string)
        popUpButton.addItem(withTitle: string)
    }
}
