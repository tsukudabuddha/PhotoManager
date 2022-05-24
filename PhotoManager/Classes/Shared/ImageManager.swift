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
  
  static func isValidImageFile(url: URL, fileType: FileType) -> Bool {
    switch fileType {
    case .jpg:
      return ["JPG", "JPEG" , "JPE" , "JIF" , "JFIF"].contains(url.pathExtension.uppercased())
    case .raw:
      return ["RAF", "RAW" , "GPR" , "ARW" , "NEF", "DNG"].contains(url.pathExtension.uppercased())
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
    return CGFloat(sourceImageUrls.count)
  }
  
  var images: [ImageData] = []
  var thumbnailImages: [ImageData] = []
  let fileManager = FileManager.default
  var sourceImageUrls = [URL]()
  var destinationImagePaths = [String]()
  
  func loadImages(from url: URL, fileType: FileType) {
    guard let imageURLs = getAllFiles(at: url) else {
      // TODO: Show an error
      return
    }
    
    let filteredImageUrls = imageURLs.filter { FileType.isValidImageFile(url: $0, fileType: fileType) }

    images = filteredImageUrls.compactMap {
      guard let nsImage = NSImage(contentsOf: $0) else { return nil }
      return ImageData(image: nsImage)
    }
    
    DispatchQueue.global(qos: .background).async {
      self.thumbnailImages = filteredImageUrls.compactMap { url in
        if !FileType.isValidImageFile(url: url, fileType: .raw) { // TODO: Support RAW file downsampling
          let image = self.downSampleImage(at: url, to: CGSize(width: 800, height: 800), scale: 1)
          return ImageData(image: image)
        } else {
          return nil
        }
      }
    }
    
    sourceImageUrls = filteredImageUrls
    imagesHaveLoaded = true
  }

  func saveImages(from sourceUrl: URL, to photoLibraryUrl: URL, fileType: FileType, progressUpdateMethod: @escaping (Int) -> Void, completion: (() -> Void)? = nil) {
    guard let allSourceFiles = getAllFiles(at: sourceUrl) else { return }
    
    sourceImageUrls = allSourceFiles.filter { FileType.isValidImageFile(url: $0, fileType: fileType) }
    
    for sourceImageURL in sourceImageUrls {
      print(sourceImageURL)
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
      let isRaw = (fileType == .raw || fileType == .all) && FileType.isRAWImage(url: sourceImageURL)
      if isRaw {
        toURL = toURL.appendingPathComponent("Raw")
      }
      createDirectoryIfNecessary(for: toURL)
      
      // Include the filename. E.g. /Photos/20XX/May -> /Photos/20XX/May/DSC0000.JPG
      toURL = toURL.appendingPathComponent(fileName)
      
      _ = !fileManager.secureCopyItem(at: sourceImageURL, to: toURL) // TODO: Handle Errors
    }
    completion?()
  }
  
  
  // MARK: Helpers
  
  private func getAllFiles(at url: URL) -> [URL]? {
    guard let sourceContents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return nil } // TODO: Show an error
    
    var subDirectories = [URL]()
    var fileURLs = [URL]()
    for url in sourceContents {
      if url.isDirectory {
        subDirectories.append(url)
        subDirectories.append(contentsOf: findAllSubDirectories(url: url))
      } else {
        fileURLs.append(url)
      }
    }
    
    subDirectories.forEach { directory in
      let subFileURLs = findSubfiles(for: directory)
      fileURLs.append(contentsOf: subFileURLs)
    }
    
    return fileURLs
  }
  
  private func findSubfiles(for directory: URL) -> [URL] {
    guard let subfileURLs = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) else {
      return []
    }
    return subfileURLs.filter { !$0.isDirectory }
  }
  
  private func findAllSubDirectories(url: URL, currentSubDirectories: [URL] = []) -> [URL] {
    guard let subURLs = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) else {
      return currentSubDirectories
      
    } // TODO: Show an error
    var subDirectories = [URL]()
    for url in subURLs {
      if url.isDirectory {
        subDirectories.append(url)
        subDirectories.append(contentsOf: findAllSubDirectories(url: url, currentSubDirectories: subDirectories))
      }
    }
    return subDirectories
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
  
  private func downSampleImage(at url: URL, to pointSize: CGSize, scale: CGFloat) -> NSImage {
    let imageURL = url as NSURL
    
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
