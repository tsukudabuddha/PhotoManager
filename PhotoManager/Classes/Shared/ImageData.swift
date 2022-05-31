//
//  ImageData.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Foundation
import SwiftUI

struct ImageData: Identifiable, Hashable {
  let id: UUID
  let image: NSImage
  let fileType: FileType?
  
  init(id: UUID = UUID(), image: NSImage, fileType: FileType?) {
    self.id = id
    self.image = image
    self.fileType = fileType
  }
}
