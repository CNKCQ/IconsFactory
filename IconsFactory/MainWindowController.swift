//
//  MainWindowController.swift
//  IconMaker
//
//  Created by KingCQ on 16/9/24.
//  Copyright © 2016年 KingCQ. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let window = self.window {
            let button = window.standardWindowButton(NSWindowButton.zoomButton)
            button?.isHidden = true
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }
    }
    
}
