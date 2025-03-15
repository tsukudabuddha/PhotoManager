//
//  EXIFData.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 3/15/25.
//

import Foundation
import ImageIO

// TODO: Create a Models folder and move this there along with ImageData. Also move date logic somewhere over there or something

struct EXIFData {
  let shutterSpeed: Double?
  let iso: Int?
  let aperture: Double?
  let focalLength: Double?
  
  init?(from dict: EXIFDictionary?) {
    guard let dict = dict else { return nil }
    
    shutterSpeed = dict[kCGImagePropertyExifExposureTime as String] as? Double
    iso = (dict[kCGImagePropertyExifISOSpeedRatings as String] as? [Int])?.first
    aperture = dict[kCGImagePropertyExifFNumber as String] as? Double
    focalLength = dict[kCGImagePropertyExifFocalLength as String] as? Double
    
    if shutterSpeed == nil &&
        iso == nil &&
        aperture == nil &&
        focalLength == nil {
      return nil
    }
  }
  
  // Display Representations
  var shutterSpeedString: String? {
    guard let speed = shutterSpeed else { return nil }
    
    // Common shutter speeds and their fractional representations
    if speed >= 1.0 {
      // For values >= 1 second, show as integer or decimal seconds
      return String(format: "%.1f s", speed)
    } else {
      // Convert to fraction (1/x)
      let denominator = Int(round(1.0 / speed))
      return "1/\(denominator) s"
    }
  }
  
  var isoString: String? {
    guard let iso = iso else { return nil }
    
    return "ISO \(iso)"
  }
  
  var apertureString: String? {
    guard let aperture = aperture else { return nil }
    
    // Format to one decimal place
    let string = String(format: "f/%.1f", aperture)
    
    // If it ends with ".0", remove the decimal part for clean integers
    if string.hasSuffix(".0") {
      return "f/\(Int(aperture))"
    }
    
    return string
  }
  
  var focalLengthString: String? {
    guard let focalLength = focalLength else { return nil }
    return "\(Int(round(focalLength)))mm"
  }
}
