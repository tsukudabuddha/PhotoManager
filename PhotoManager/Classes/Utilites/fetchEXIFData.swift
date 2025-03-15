//
//  fetchEXIFData.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 3/14/25.
//

import Foundation
import ImageIO

func fetchEXIFData(from imageURL: URL?) -> EXIFData? {
  guard let imageURL = imageURL else { return nil }
  
  let dict = fetchEXIFDictionary(from: imageURL)
  return EXIFData(from: dict)
}

typealias EXIFDictionary = [String: Any]

fileprivate func fetchEXIFDictionary(from imageURL: URL) -> EXIFDictionary? {
  guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
    print("Error: Could not create image source from URL")
    return nil
  }
  
  guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
    print("Error: Could not get image properties")
    return nil
  }
  
  // The EXIF data is contained within the "{Exif}" dictionary
  if let exifData = imageProperties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
    return exifData
  }
  
  // If you want ALL image metadata (including EXIF, TIFF, GPS, etc.)
  // return imageProperties
  
  return nil
}
