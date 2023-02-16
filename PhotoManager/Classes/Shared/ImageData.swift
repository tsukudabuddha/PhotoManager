//
//  ImageData.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Foundation
import SwiftUI

class ImageData: Identifiable {
  let id: UUID
  var image: NSImage? {
    return NSImage(byReferencingFile: path)
  }
  let path: String
  let date: Date
  
  init(path: String, id: UUID = UUID(), date: Date) {
    self.id = id
    self.path = path
    self.date = date
  }
}

class ReviewImageData: Identifiable {
  let rawURL: URL?
  let jpgURL: URL?
  var image: NSImage? {
    if let url = jpgURL {
      return NSImage(contentsOf: url)
    } else if let url = rawURL {
      return NSImage(contentsOf: url)
    } else {
      return nil
    }
    
  }
  var keepJPG: Bool
  var keepRAW: Bool
  let date: Date
  
  init?(rawURL: URL?, jpgURL: URL?, keepJPG: Bool = false, keepRAW: Bool = false, date: Date) {
    if jpgURL == nil && rawURL == nil {
      return nil
    }
    self.rawURL = rawURL
    self.jpgURL = jpgURL
    self.keepJPG = keepJPG
    self.keepRAW = keepRAW
    self.date = date
  }
}
