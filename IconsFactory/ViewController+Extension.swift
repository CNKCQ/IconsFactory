//
//  ViewController+Extension.swift
//  IconMaker
//
//  Created by KingCQ on 16/9/24.
//  Copyright © 2016年 KingCQ. All rights reserved.
//

import Cocoa

enum IMError: Error {
    case stringError(String)
    case cancelPressed
}

// MARK: Generate icons
extension ViewController {
    
    func generateWith(originalImage: NSImage?) {
        let path = Bundle.main.bundleURL
        var jsonPath = getIconJSONPath(iconFolderPath: path)
        if let json = URL(string: UserDefaults.standard.object(forKey: "json") as! String) {
            jsonPath = json
        }
        var savePath = URL(string: "/Users/KingCQ/Desktop/Icons/")
        if let saveDir = URL(string: UserDefaults.standard.object(forKey: "savePath") as! String) {
            savePath = saveDir
        }
        print(savePath, "savepath")
        print(jsonPath, "jsonpath")
        do {
            let jsonDict = try? getJSONDict(jsonDictPath: jsonPath)
            print(jsonDict, "jsonDict")
            guard let sizesArray = jsonDict?["images"] as? NSArray else {
                fatalError("error")
            }
            for singleSize in sizesArray {
                guard let si = singleSize as? NSMutableDictionary,
                    let size = si["size"] as? String,
                    let scale = si["scale"] as? String else {
                        fatalError("error")
                }
                guard let saveUrl = savePath, let img = originalImage else {
                    fatalError("")
                }
                do {
                    let resultName = try resizeImage(img: img, stringSize: size, stringScale: scale, savePath: saveUrl)
                    si["filename"] = resultName
                    
                } catch {
                    print(IMError.stringError("an problem"))
                }
            }
        }
    }
    
    func getIconJSONPath(iconFolderPath: URL) -> URL {
        return iconFolderPath.appendingPathComponent("Contents/Resources/Contents.json")
    }
    
    func getJSONDict(jsonDictPath: URL) throws -> NSDictionary {
        print(jsonDictPath)
        guard let data = NSData(contentsOf: jsonDictPath) else {
            throw IMError.stringError("Loading icon JSON failed")
        }
        guard let jsonDict = try? JSONSerialization.jsonObject(with: data as Data, options: [.mutableContainers]) as? NSDictionary else {
            throw IMError.stringError("Parsing icon JSON failed")
        }
        return jsonDict!
    }
    
    
    func resizeImage(img: NSImage, stringSize: String, stringScale: String, savePath: URL) throws -> String {
        guard let size = Double(stringSize.components(separatedBy: "x").first!),
            let scale = Double(stringScale.components(separatedBy: "x").first!) else {
                throw IMError.stringError("Error retrieving icon size or scale")
        }
        let resultSize = NSSize(width: size * scale, height: size * scale)
        img.size = resultSize
        _ = NSBitmapImageRep(focusedViewRect: NSRect(x: 0.0, y: 0.0, width: img.size.width, height: img.size.height))
        let data = try dataFromImage(image: img, size: Int(size * scale))
        let imgName = "Icon-\(Int(resultSize.width))x\(Int(resultSize.height))@\(stringScale).png"
        print(imgName,data,savePath.appendingPathComponent(imgName))
        try? data.write(to: savePath.appendingPathComponent(imgName), options: [Data.WritingOptions.withoutOverwriting])
        return imgName
    }
    
    func dataFromImage(image: NSImage, size: Int) throws -> Data {
        if let representation = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                 pixelsWide: size,
                                                 pixelsHigh: size,
                                                 bitsPerSample: 8,
                                                 samplesPerPixel: 4,
                                                 hasAlpha: true,
                                                 isPlanar: false,
                                                 colorSpaceName: NSCalibratedRGBColorSpace,
                                                 bytesPerRow: 0,
                                                 bitsPerPixel: 0) {
            representation.size = NSSize(width: size, height: size)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: representation))
            image.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
                       from: NSZeroRect,
                       operation: NSCompositingOperation.copy,
                       fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            guard let imageData = representation.representation(using: NSBitmapImageFileType.PNG, properties: [String : AnyObject]()) else {
                throw IMError.stringError("Error obtaining data for icon image")
            }
            return imageData
        } else {
            throw IMError.stringError("Error obtaining representation for icon image")
        }
    }
}

