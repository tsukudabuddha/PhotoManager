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
  case raw = "RAF" // TODO: Add support for more raw file types
  case all
}

class ImageManager: ObservableObject {
  @Published var imagesHaveLoaded: Bool = false
  var total: CGFloat {
    return CGFloat(sourceImageUrls.count)
  }
  
  var images: [ImageData] = []
  var thumbnailImages: [ImageData] = []
  let fileManager = FileManager.default
  var sourceImageUrls = [URL]()
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
      
      sourceImageUrls = filteredImagePaths.compactMap({ return URL(fileURLWithPath: $0) })
      imagesHaveLoaded = true
    } catch {
      // TODO: Show an error
      // failed to read directory – bad permissions, perhaps?
      print(error)
    }
  }
  
  func saveImages(from sourceUrl: URL, to photoLibraryUrl: URL, fileType: FileType, progressUpdateMethod: @escaping (Int) -> Void, completion: (() -> Void)? = nil) {
    
    guard let imagePaths = try? fileManager.contentsOfDirectory(atPath: sourceUrl.path) else { return } // TODO: Show an error
    let fullImagePaths = imagePaths.map { return sourceUrl.path + "/" + $0 }
    
    let filteredImagePaths = fullImagePaths.filter { path in
      if fileType == .all {
        return true
      }
      return NSString(string: path).pathExtension == fileType.rawValue
    }
    
    sourceImageUrls = filteredImagePaths.compactMap({ return URL(fileURLWithPath: $0) })
    
    for sourceImageURL in sourceImageUrls {
      progressUpdateMethod(sourceImageURL == sourceImageUrls.last ? 0 : 1) // Only add one if not on the last one
      let fileName = sourceImageURL.lastPathComponent

      guard let date = getDate(for: sourceImageURL)
      else {
        // TODO: No images will be copied, show an error
        return
      }
      // Add directory path components. E.g. /Photos -> /Photos/20XX/May
      var toURL = photoLibraryUrl
      for pathComponent in directoryPathComponents(for: date) {
        toURL = toURL.appendingPathComponent(pathComponent)
      }
      createDirectoryIfNecessary(for: toURL)
      
      // Include the filename. E.g. /Photos/20XX/May -> /Photos/20XX/May/DSC0000.JPG
      toURL = toURL.appendingPathComponent(fileName)
      
      _ = !fileManager.secureCopyItem(at: sourceImageURL, to: toURL) // TODO: Handle Errors
    }
    completion?()
  }
  
  
  // MARK: Helpers
  private func directoryPathComponents(for date: Date) -> [String] {
    // TODO: Allow for more user control with directories and names
    let dateFormatter = DateFormatter()
    var pathComponents = [String]()
    // Year
    dateFormatter.dateFormat = "yyyy"
    pathComponents.append(dateFormatter.string(from: date))
    // Month
    dateFormatter.dateFormat = "MMM"
    pathComponents.append(dateFormatter.string(from: date))
    return pathComponents
  }
  
  // TODO: Move to FileManager extension?
  private func createDirectoryIfNecessary(for url: URL) {
    try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
  }
  
  private func getDate(for sourceImageUrl: URL) -> Date? {
    guard let data = NSData(contentsOf: sourceImageUrl),
          let source = CGImageSourceCreateWithData(data, nil),
          let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil),
          let metadataDict = metadata as? [String: AnyObject]
    else {
      // TODO: Log or display metadata error
      return nil
    }
    
    // Check Tiff first -- arbitrary default
    if let tiff = metadataDict["{TIFF}"] as? [String: AnyObject],
       let tiffDateTime = tiff["DateTime"] as? String,
       let tiffDate = createDate(from: tiffDateTime) {
      return tiffDate
    } else if let exif = metadataDict["{Exif}"] as? [String: AnyObject],
              let exifDateTime = exif["DateTimeOriginal"] as? String {
      return createDate(from: exifDateTime)
    }
    return nil
    
  }

  private func createDate(from metadataString: String) -> Date? {
    let dateFormatter = DateFormatter()
    // TODO: Handle more data formats
    dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
    
    return dateFormatter.date(from: metadataString)
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
