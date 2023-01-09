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
  let image: NSImage
  var keepJPG: Bool
  var keepRAW: Bool
  let date: Date?
  
  init(image: NSImage, id: UUID = UUID(), date: Date?, keepJPG: Bool = false, keepRAW: Bool = false) {
    self.id = id
    self.image = image
    self.date = date
    self.keepJPG = keepJPG
    self.keepRAW = keepRAW
  }
}
