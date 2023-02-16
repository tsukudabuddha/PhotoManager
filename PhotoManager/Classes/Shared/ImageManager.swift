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
  case jpg
  case raw
  case video
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
  @Published var total: Int = 0 // Used for quick import loading
  
  var images: [ImageData] = []
  var thumbnailImages: [ImageData] = []
  let fileManager = FileManager.default
  var sourceImageUrls = [URL]()
  var destinationImagePaths = [String]()
  
  func loadImages(from url: URL, fileType: FileType) {
    guard let directoryUrls = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
      return
    } // TODO: Show an error
    
    var subDirectories = [URL]()
    for url in directoryUrls {
      if url.isDirectory {
        subDirectories.append(contentsOf: findAllSubDirectories(url: url))
      } else {
        subDirectories.append(url)
      }
    }
    
    var sourceImageUrls = [URL]()
    subDirectories.forEach { directory in
      if directory.isFileURL {
        sourceImageUrls.append(directory)
      }
      
    }
    sourceImageUrls = sourceImageUrls.filter { FileType.isValidImageFile(url: $0, fileType: fileType) }
    images = sourceImageUrls.compactMap { url in
      guard let date = getDate(for: url) else {
        return nil
        
      }
      return ImageData(path: url.path, date: date)
    }
    imagesHaveLoaded = true
    self.sourceImageUrls = sourceImageUrls
  }
  
  func saveImage(from sourceImageUrl: URL, to photoLibraryUrl: URL, fileType: FileType, move: Bool, progressUpdateMethod: ((Int) -> Void)? = nil, completion: (() -> Void)? = nil) {
    let fileName = sourceImageUrl.lastPathComponent
    
    guard let date = getDate(for: sourceImageUrl)
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
    let isRaw = (fileType == .raw || fileType == .all) && FileType.isRAWImage(url: sourceImageUrl)
    if isRaw {
      toURL = toURL.appendingPathComponent("Raw")
    }
    fileManager.createDirectoryIfNecessary(for: toURL)
    
    // Include the filename. E.g. /Photos/20XX/May -> /Photos/20XX/May/DSC0000.JPG
    toURL = toURL.appendingPathComponent(fileName)
    
    // TODO: Handle Errors
    if move {
      _ = try? fileManager.moveItem(at: sourceImageUrl, to: toURL)
    } else {
      let success = fileManager.secureCopyItem(at: sourceImageUrl, to: toURL)
    }
  }
  
  func saveImages(from sourceUrl: URL, to photoLibraryUrl: URL, fileType: FileType, move: Bool, progressUpdateMethod: @escaping (Int) -> Void, completion: (() -> Void)? = nil) {
    guard let directoryUrls = try? fileManager.contentsOfDirectory(at: sourceUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
      return
    } // TODO: Show an error
    
    var subDirectories = [URL]()
    for url in directoryUrls {
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
    total = sourceImageUrls.count
    
    for sourceImageURL in sourceImageUrls {
      progressUpdateMethod(sourceImageURL == sourceImageUrls.last ? 0 : 1) // Only add one if not on the last one
      saveImage(from: sourceImageURL, to: photoLibraryUrl, fileType: fileType, move: move)
    }
    self.sourceImageUrls = sourceImageUrls
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
  
  func getDate(for sourceImageUrl: URL) -> Date? {
    guard let attr = try? fileManager.attributesOfItem(atPath: sourceImageUrl.path),
          let creationDate = (attr[.creationDate] as? NSDate) as Date?
    else {
      // TODO: Log or display metadata error
      return nil
    }
    
    return creationDate
  }
  
  private func downSampleImage(path: String, to pointSize: CGSize, scale: CGFloat) -> NSImage? {
    let imageURL = NSURL(fileURLWithPath: path)
    
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
    
    let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
    
    let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                      kCGImageSourceShouldCacheImmediately: true,
                                kCGImageSourceCreateThumbnailWithTransform: true,
                                       kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
    if let downsampledImage =     CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) {
      return NSImage(cgImage: downsampledImage, size: NSSizeFromCGSize(pointSize))
    }
    return nil
    
  }
}
