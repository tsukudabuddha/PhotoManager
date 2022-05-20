//
//  ImageManager.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import SwiftUI
import CoreGraphics

enum FileType: String {
  case jpg = "JPG"
}

class ImageManager: ObservableObject {
  @Published var imagesHaveLoaded: Bool = false
  var images: [ImageData] = []
  let fileManager = FileManager.default
  var url: URL?
  
  func loadImages(from url: URL, fileType: FileType) {
    do {
      let imagePaths = try fileManager.contentsOfDirectory(atPath: url.path)
      let fullImagePaths = imagePaths.map { return url.path + "/" + $0 }
      
      //      for item in fullImagePaths {
      //        let nsItem = NSString(string: item)
      //        print("Found \(nsItem.pathExtension)")
      //      }
      
      let filteredImagePaths = fullImagePaths.filter { path in
        return NSString(string: path).pathExtension == fileType.rawValue
      }
      images = filteredImagePaths.compactMap { path in
        print(path)
        let image = downSampleImage(path: path, to: CGSize(width: 800, height: 800), scale: 1)
        return ImageData(image: image)
//        return nil // TODO: Show that an image failed to load
      }
      imagesHaveLoaded = true
    } catch {
      // TODO: Show an error
      // failed to read directory – bad permissions, perhaps?
      print(error)
    }
  }
  
  func downSampleImage(path: String, to pointSize: CGSize, scale: CGFloat) -> NSImage {
    let imageURL = NSURL(fileURLWithPath: path)
    
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
    
    let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
    
    let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                      kCGImageSourceShouldCacheImmediately: true,
                                kCGImageSourceCreateThumbnailWithTransform: true,
                                       kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
    let downsampledImage =     CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)!
    
    return NSImage(cgImage: downsampledImage, size: NSSizeFromCGSize(pointSize))
  }
}
