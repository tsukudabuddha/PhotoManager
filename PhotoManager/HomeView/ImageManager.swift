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
  case all
}

class ImageManager: ObservableObject {
  @Published var imagesHaveLoaded: Bool = false
  var images: [ImageData] = []
  var thumbnailImages: [ImageData] = []
  let fileManager = FileManager.default
  var sourceImageURLs = [URL]()
  var destinationImagePaths = [String]()
  
  func loadImages(from url: URL, fileType: FileType) {
    do {
      let imagePaths = try fileManager.contentsOfDirectory(atPath: url.path)
      let fullImagePaths = imagePaths.map { return url.path + "/" + $0 }
      
      let filteredImagePaths = fullImagePaths.filter { path in
        if fileType == .all {
          return true
        }
        return NSString(string: path).pathExtension == fileType.rawValue
      }
      DispatchQueue.global(qos: .background).async {
        self.thumbnailImages = filteredImagePaths.compactMap { path in
          let image = self.downSampleImage(path: path, to: CGSize(width: 800, height: 800), scale: 1)
          return ImageData(image: image)
        }
      }
      images = filteredImagePaths.compactMap { path in
        guard let image = NSImage(byReferencingFile: path) else {
          return nil
        }
        
        return ImageData(image: image)
      }
      
      sourceImageURLs = filteredImagePaths.compactMap({ return URL(fileURLWithPath: $0) })
      imagesHaveLoaded = true
    } catch {
      // TODO: Show an error
      // failed to read directory – bad permissions, perhaps?
      print(error)
    }
  }
  
  func saveImages(to destinationUrl: URL, completion: (() -> Void)? = nil) {
    for sourceImageURL in sourceImageURLs {
      let fileName = sourceImageURL.lastPathComponent
      let toURL = destinationUrl.appendingPathComponent(fileName)
      
      _ = !fileManager.secureCopyItem(at: sourceImageURL, to: toURL) // TODO: Handle Errors
    }
    completion?()
  }
  
  private func downSampleImage(path: String, to pointSize: CGSize, scale: CGFloat) -> NSImage {
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
