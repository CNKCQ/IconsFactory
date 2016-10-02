//
//  ViewController.swift
//  IconMaker
//
//  Created by KingCQ on 16/9/20.
//  Copyright © 2016年 KingCQ. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSOpenSavePanelDelegate {

    @IBOutlet weak var dragView: DragView!
    @IBOutlet weak var jsonField: NSTextField!
    @IBOutlet weak var saveField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        dragView.delegate = self
        
    }
    
    @IBAction func setting(_ sender: NSButtonCell) {
        let window = NSApplication.shared().windows.first!
        let height = window.frame.height
        changePanel(open: height == 320, animated: true)
    }
    
    @IBAction func jsonClick(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("Select output path.", comment: "Select output path.")
        openPanel.message = NSLocalizedString("Images will put in there after compress.", comment: "Images will put in there after compress.")
        openPanel.showsResizeIndicator=true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        openPanel.delegate = self
        openPanel.begin { (result) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                let path = openPanel.url!.path
                print(self.jsonField.stringValue)
                self.jsonField.textColor = NSColor.red
                self.jsonField.stringValue = path
                UserDefaults.standard.set(path, forKey: "json")
                print("selected folder is \(path)");
            }
        }
    }
    
    @IBAction func saveClick(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("Select output path.", comment: "Select output path.")
        openPanel.message = NSLocalizedString("Images will put in there after compress.", comment: "Images will put in there after compress.")
        openPanel.showsResizeIndicator=true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        openPanel.delegate = self
        openPanel.begin { (result) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                let path = openPanel.url!.path
                self.saveField.stringValue = path
                UserDefaults.standard.set(path, forKey: "savePath")
                print("selected folder is \(path)");
            }
        }
    }
    
    func changePanel(open: Bool, animated: Bool) {
        let window = NSApplication.shared().windows.first!
        let frame = window.frame
        let height = window.frame.height
        var t = height
        if open {
            t = 400
        } else {
            t = 320
        }
        let newFrame = CGRect.init(x: frame.origin.x, y: frame.origin.y + (height - t), width: frame.size.width, height: t)
        window.setFrame(newFrame, display: true, animate: animated)
    }

    
}

extension ViewController: DragViewDelegate {
    func draggingEntered() {
        print("draggingEntered")
    }
    
    func draggingExit() {
        print("draggingExit")
    }
    
    func draggingFileAccept(files:Array<NSURL>) {
        let originalImage = NSImage(contentsOf: files.first! as URL)
        generateWith(originalImage: originalImage)
    }
}

