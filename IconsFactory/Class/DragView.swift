//
//  DragView.swift
//  IconMaker
//
//  Created by KingCQ on 16/9/21.
//  Copyright © 2016年 KingCQ. All rights reserved.
//

import Foundation
import AppKit

protocol DragViewDelegate {
    func draggingEntered()
    func draggingExit()
    func draggingFileAccept(files:Array<NSURL>)
}

class DragView: NSView {
    var delegate : DragViewDelegate?
    let acceptTypes = ["png", "jpg", "jpeg"]
    let normalColor: CGFloat = 0.95
    let highlightColor: CGFloat = 0.99
    let borderColor: CGFloat = 0.85
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer?.backgroundColor = NSColor.red.cgColor
        self.register(forDraggedTypes: [NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF]);
    }
    
    func checkExtension(draggingInfo: NSDraggingInfo) -> Bool {
        if let board = draggingInfo.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray {
            for path in board {
                let url = NSURL(fileURLWithPath: path as! String)
                if let fileExtension = url.pathExtension?.lowercased(){
                    if acceptTypes.contains(fileExtension) {
                        return true
                    }
                }
            }
        }
        return false
    }

}

// MARK: NSDraggingDestination
extension DragView {
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.backgroundColor = NSColor(white: highlightColor, alpha: 1).cgColor;
        let res = checkExtension(draggingInfo: sender)
        if let delegate = self.delegate {
            delegate.draggingEntered();
        }
        if res {
            return NSDragOperation.generic
        }
        return NSDragOperation.copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor(white: normalColor, alpha: 1).cgColor;
        if let delegate = self.delegate {
            delegate.draggingExit();
        }
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        var files = Array<NSURL>()
        if let board = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray {
            for path in board {
                let url = NSURL(fileURLWithPath: path as! String)
                if let fileExtension = url.pathExtension?.lowercased() {
                    if acceptTypes.contains(fileExtension) {
                        files.append(url)
                    }
                }
            }
        }
        if let delegate = self.delegate {
            delegate.draggingFileAccept(files: files);
        }
        return true
    }
}

