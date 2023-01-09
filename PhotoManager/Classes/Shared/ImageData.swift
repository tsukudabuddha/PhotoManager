//
//  ImageData.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Foundation
import SwiftUI

struct ImageData: Identifiable {
  let id: UUID
  var image: NSImage? {
    return NSImage(byReferencingFile: path)
  }
  let path: String
  var keepJPG: Bool
  var keepRAW: Bool
  let date: Date
  
  init(path: String, id: UUID = UUID(), date: Date, keepJPG: Bool = false, keepRAW: Bool = false) {
    self.id = id
    self.path = path
    self.date = date
    self.keepJPG = keepJPG
    self.keepRAW = keepRAW
  }
}
