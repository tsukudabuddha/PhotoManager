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
  let date: Date?
  
  init(image: NSImage, id: UUID = UUID(), date: Date?) {
    self.id = id
    self.image = image
    self.date = date
  }
}
