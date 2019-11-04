//
//  class.filehandler.swift
//  XMLFileSwift
//
//  Created by Magnus Kruschwitz on 27.10.19.
//  Copyright © 2019 Magnus Kruschwitz. All rights reserved.
//

import Foundation
import Cocoa

class helperClass {
    private var sfileType : String
    private var oFileManager : FileManager
    private var sDefaultFileName : String
    private var oView : ViewController?
    private var fileArray: [String: Any]
    private var tmpPosi :Int
    
    init(sFileType : String) {
        self.sfileType = sFileType
        self.oFileManager = FileManager.default
        
        self.sDefaultFileName = "\(Bundle.main.infoDictionary!["CFBundleName"] as! String).\(self.sfileType)"
        self.tmpPosi = 0
        self.fileArray = [
            "fileName": self.sDefaultFileName,
            "sFileLink" : "\(self.oFileManager.currentDirectoryPath)/\(self.sDefaultFileName)"
        ]
    }
    
    func setView(oView: ViewController){
        self.oView = oView
    }
    
    /**
       Diese Methode dient der Zwischenspeicherung der aktuellen der aktuellen Position, um den Inhalt aus dem XML-File dem richtigen Inputfeld zuzuordnen. Weiteres in der save-Methode.
    - parameter iPosi: Es wird ein Integer erwatet, welcher den neuen Wert darstellt.
    
    # Example #
    ```
     helper.setTmpPosi(iPosi: 1)
     ```
    */
    func setTmpPosi(iPosi: Int){
        self.tmpPosi = iPosi
    }
    
    /**
        Diese Methode speichert die in den Textfeldern hinterlegten Eingaben und speichert ihre Position in einem XML-File ab. Als Speicherort wird FileManager.default.currentDirectoryPath verwendet.
     - parameter aFields: Übergibt ein Array der aktuellen auf der Oberfläche zu findenen Textfelder
     - returns: Gibt bei Erfolg true zurück, bei Problemen wird fals zurückgegeben und es gibt in der Konsole eine Ausgabe potentieller Fehler.
     
     # Example #
     ```
      if let breturn = helper.save([textfield1,textfield2]) {
            print("erfolg")
      }
      ```
     */
    func save(aFields: Array<NSTextField>) -> Bool {
        if aFields[0].stringValue != "" || aFields[1].stringValue != "" || aFields[2].stringValue != "" {
            let rootElem = XMLElement(name: "base")
            let myFile = XMLDocument(rootElement: rootElem)
            var i = 0
            myFile.version = "1.0"
            myFile.characterEncoding="UTF-8"
            for field in aFields {
                if field.stringValue != ""{
                    let tmpNode = XMLElement(name: "elem", stringValue: field.stringValue)
                    tmpNode.setAttributesAs(["fieldIndex" : NSString(string: "\(i)")])
                    rootElem.addChild(tmpNode)
                }
                i += 1
            }
            
            let xmlData = myFile.xmlData
            
            do{
                try xmlData.write(to: URL(fileURLWithPath: self.fileArray["sFileLink"] as! String))
                return true
            }
            catch{
                print(error.localizedDescription)
                return false
            }
        }
        return false
    }
    
    /**
       Diese Methode lädt aus dem definierten Pfad das XML-File und wenn es existiert wird der Link an die View zum parsen übergeben.
    - returns: Gibt bei Erfolg true zurück, bei Problemen wird fals zurückgegeben und es gibt in der Konsole eine Ausgabe potentieller Fehler.
    
    # Example #
    ```
     if helper.load() {
           print("erfolg")
     }
     ```
    */
    func load() -> Bool {
        if self.oFileManager.fileExists(atPath: self.fileArray["sFileLink"] as! String){
            return self.oView!.useParser(path: URL(fileURLWithPath: self.fileArray["sFileLink"] as! String))
        }
        else{
            let output: NSAlert = NSAlert()
            output.messageText = "Achutung!"
            output.informativeText = "Die Datei: \(self.sDefaultFileName) wurde nicht gefunden."
            output.runModal()
            return false
        }
    }
    
    func writeInField(aFields: Array<NSTextField>, text: String){
        aFields[self.tmpPosi].stringValue = text
        self.tmpPosi = 0
    }
}
