//
//  ImageManager.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import SwiftUI
import CoreGraphics

enum FileType: String { // TODO: Do these string values matter?
  case jpg = "JPG"
  case raw = "RAF" // TODO: Add support for more raw file types
  case video = "MP4"
  case all
  
  static func isValidImageFile(url: URL, fileType: FileType) -> Bool {
    switch fileType {
    case .jpg:
      return ["JPG", "JPEG" , "JPE" , "JIF" , "JFIF"].contains(url.pathExtension.uppercased())
    case .raw:
      return ["RAF", "RAW" , "GPR" , "ARW" , "NEF", "DNG"].contains(url.pathExtension.uppercased())
    case .video:
      return ["MP4", "MOV"].contains(url.pathExtension.uppercased())
    case .all:
      return FileType.isValidImageFile(url: url, fileType: .raw) || FileType.isValidImageFile(url: url, fileType: .jpg)
    }
  }
  
  static func isRAWImage(url: URL) -> Bool {
    return FileType.isValidImageFile(url: url, fileType: .raw)
  }
}

class ImageManager: ObservableObject {
  @Published var imagesHaveLoaded: Bool = false
  var total: CGFloat {
    print(sourceImageUrls.count)
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
    guard let directoryUrls = try? fileManager.contentsOfDirectory(at: sourceUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
      return
    } // TODO: Show an error
    
    var subDirectories = [URL]()
    for url in directoryUrls {
      print(url)
      if url.isDirectory {
        subDirectories.append(contentsOf: findAllSubDirectories(url: url))
      } else {
        subDirectories.append(url)
      }
    }
    
    var sourceImageUrls = [URL]()
    subDirectories.forEach { directory in
      let fileUrls = findSubfiles(for: directory)
      sourceImageUrls.append(contentsOf: fileUrls)
    }
    sourceImageUrls = sourceImageUrls.filter { FileType.isValidImageFile(url: $0, fileType: fileType) }
    
    for sourceImageURL in sourceImageUrls {
//      print(sourceImageURL)
      progressUpdateMethod(sourceImageURL == sourceImageUrls.last ? 0 : 1) // Only add one if not on the last one
      let fileName = sourceImageURL.lastPathComponent
      
      guard let date = getDate(for: sourceImageURL)
      else {
        // TODO: No images will be copied, show an error
        return
      }
      // Add directory path components. E.g. /Photos -> /Photos/20XX/May
      var toURL = photoLibraryUrl
      if fileType == .video {
        toURL = toURL.appendingPathComponent("Videos")
      }
      for pathComponent in directoryPathComponents(for: date) {
        toURL = toURL.appendingPathComponent(pathComponent)
      }
      let isRaw = (fileType == .raw || fileType == .all) && FileType.isRAWImage(url: sourceImageURL)
      if isRaw {
        toURL = toURL.appendingPathComponent("Raw")
      }
      createDirectoryIfNecessary(for: toURL)
      
      // Include the filename. E.g. /Photos/20XX/May -> /Photos/20XX/May/DSC0000.JPG
      toURL = toURL.appendingPathComponent(fileName)
      
      self.sourceImageUrls = sourceImageUrls
      _ = !fileManager.secureCopyItem(at: sourceImageURL, to: toURL) // TODO: Handle Errors
    }
    completion?()
  }
  
  
  // MARK: Helpers
  
  private func findSubfiles(for directory: URL) -> [URL] {
    guard let subfileURLs = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) else {
      return []
    }
    return subfileURLs
  }
  
  private func findAllSubDirectories(url: URL) -> [URL] {
    guard let subURLs = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) else {
      return []
      
    } // TODO: Show an error
    var subDirectories = [URL]()
    for url in subURLs {
      print(url)
      if url.isDirectory {
        subDirectories.append(contentsOf: findAllSubDirectories(url: url))
      }
    }
    return subURLs
  }
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
    guard let attr = try? fileManager.attributesOfItem(atPath: sourceImageUrl.path),
          let creationDate = (attr[.creationDate] as? NSDate) as Date?
    else {
      // TODO: Log or display metadata error
      return nil
    }
    
    return creationDate
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
