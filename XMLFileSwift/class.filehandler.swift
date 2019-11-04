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
    private var aFileTypes : Array<String>
    private var iSaveCounter : Int
    private var bIsLoad : Bool
    private var sFile : String?
    private var sFileName : String?
    private var oFileManager : FileManager
    private var sDefaultFileName : String
    private var oView : ViewController?
    
    init(aFileTypes : Array<String>) {
        self.aFileTypes = aFileTypes
        self.iSaveCounter = 0
        self.bIsLoad = false
        self.oFileManager = FileManager.default
        self.sDefaultFileName = "test.xml"
    }
    
    func setView(oView: ViewController){
        self.oView = oView
    }
    
    func save(aFields: Array<NSTextField>) -> Bool {
        if aFields[0].stringValue != "" || aFields[1].stringValue != "" || aFields[2].stringValue != "" {
            let rootElem = XMLElement(name: "root")
            let myFile = XMLDocument(rootElement: rootElem)
            myFile.version = "1,0"
            myFile.characterEncoding="UTF-8"
            for field in aFields {
                if field.stringValue != ""{
                    rootElem.addChild(XMLElement(name:"node", stringValue: field.stringValue))
                }
            }
            
            let xmlData = myFile.xmlData
            
            do{
                try xmlData.write(to: URL(fileURLWithPath: "\(self.oFileManager.currentDirectoryPath)/\(self.sDefaultFileName)"))
                return true
            }
            catch{
                print(error.localizedDescription)
                return false
            }
        }
        return false
    }
    
    func load(bCreateBackup: Bool, field: NSTextField) -> Bool {
        let myOpenPanel = NSOpenPanel()
        myOpenPanel.title = "Öffnen"
        myOpenPanel.prompt = "Öffnen"
        myOpenPanel.allowedFileTypes = self.aFileTypes
        
        if myOpenPanel.runModal() == NSApplication.ModalResponse.OK {
            self.sFile = myOpenPanel.url?.path
            
            do {
                var bBackupResult = false
                let textTemp = try String(contentsOfFile:self.sFile!, encoding:
                    String.Encoding.utf8)
                field.stringValue = textTemp
                
                if bCreateBackup {
                    bBackupResult = self.createBackUp(file: self.sFile!, content: textTemp, isSave: false)
                }
                
                self.bIsLoad = true
                
                if bBackupResult {
                    print("Backup wurde angelegt")
                }
                else {
                    if bCreateBackup {
                        print("Es ist ein Fehler aufgetreten, bitte prüfen Sie den Fehlerlog")
                    }
                }
                
                return true
            }
            catch {
                print(error.localizedDescription)
                return false
            }
        }
        
        return false
    }
    
    func createBackUp(file: String, content: String, isSave: Bool) -> Bool {
        let oFileManager = FileManager.default
        var sExtension = ""
        var sFileName = ""
        
        if isSave {
            sExtension = "txt"
            sFileName = "File"
        }
        else {
            sExtension = "bak"
            sFileName = "Backup"
        }
        
        let backupURL = URL(string: "\((file as NSString).deletingPathExtension).\(sExtension)")
        
        do {
            if oFileManager.fileExists(atPath: (backupURL?.path)!) {
                print("\(sFileName) existiert.")
                print("Lösche vorhandens \(sFileName) und lege ein Neues an.")
                try oFileManager.removeItem(atPath: (backupURL?.absoluteString)!)
                print("\(sFileName) gelöscht")
            }
            else {
                print("\(sFileName) existiert nicht")
            }
            
            print("lege \(sFileName) an.")
            try content.write(toFile: "\((file as NSString).deletingPathExtension).\(sExtension)",atomically: true, encoding: .utf8)
            print("\(sFileName) erfolgreich angelegt unter \(String(describing: backupURL?.absoluteString)).")
            
        } catch {
            print(error.localizedDescription)
            return false
        }
        
        return true
    }
}
