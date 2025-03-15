//
//  ImageManager.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import SwiftUI
import CoreGraphics

class ImageManager: ObservableObject {
  @Published var imagesHaveLoaded: Bool = false
  @Published var total: Int = 0 // Used for quick import loading
  
  var imagesForReview: [ReviewImageData] = []
  var thumbnailImages: [ImageData] = []
  let fileManager = FileManager.default
  var sourceImageUrls = [URL]()
  var destinationImagePaths = [String]()
  
  // TODO: Create a func loadImages(for: ImageLoadType) e.g. .review, .view, etc.
  func loadImagesForReview(from url: URL) {
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
    sourceImageUrls = sourceImageUrls.filter { FileType.isValidImageFile(url: $0, fileType: .all) }
    // Group urls by name (to group raw + jpeg images)
    let rawImageUrls = sourceImageUrls.filter { FileType.isValidImageFile(url: $0, fileType: .raw) }
    let jpgImageUrls = sourceImageUrls.filter { FileType.isValidImageFile(url: $0, fileType: .jpg) }
    
    let allFileNamesWithPossibleDuplicates = sourceImageUrls.map { $0.lastPathComponent.dropLast(4)} // TODO: Make sure everything has file extension of length 3 or else this will cause issues
    let allFileNames = Set(allFileNamesWithPossibleDuplicates.map { String($0) })
    
    imagesForReview = []
    for fileName in allFileNames {
      let jpgUrl = jpgImageUrls.first { $0.lastPathComponent.dropLast(4) == fileName }
      let rawUrl = rawImageUrls.first { $0.lastPathComponent.dropLast(4) == fileName }
      let exifData = fetchEXIFData(from: jpgUrl)
      
      var date: Date
      if let jpgUrl = jpgUrl, let jpgDate = getDate(for: jpgUrl) {
        date = jpgDate
      } else if let rawUrl = rawUrl, let rawDate = getDate(for: rawUrl) {
        date = rawDate
      } else {
        return // TODO: Show error creating date
      }
      guard let imageData = ReviewImageData(rawURL: rawUrl, jpgURL: jpgUrl, date: date, exifData: exifData) else {
        return
        // TODO: Show an error
      }
      imagesForReview.append(imageData)
    }
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
