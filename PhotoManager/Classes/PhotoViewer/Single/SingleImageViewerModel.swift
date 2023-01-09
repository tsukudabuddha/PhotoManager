//
//  SingleImageViewerModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/8/23.
//

import Foundation

class SingleImageViewerModel: ObservableObject {
  @Published var index: Int = 0
  var imageData: ImageData {
    return images[index]
  }
  
  @Published var images: [ImageData]
  
  init?(images: [ImageData]) {
    guard images.count > 0 else { return nil }
    self.images = images
  }
  
  
  // MARK: KeyPressHandler
  func keyPressHandler(keyCode: UInt16) {
    switch(keyCode) {
    case 3: // F
      images[index].keepRAW = !imageData.keepRAW
    case 38: // J
      images[index].keepJPG = !imageData.keepJPG
    case 49: // Space
      nextPhoto()
    case 123: // Left Arrow
      previousPhoto()
    case 124: // Right Arrow
      nextPhoto()
    default:
      print(keyCode)
      return
    }
  }
  
  func nextPhoto() {
    index = index < images.count - 1 ? index + 1 : 0
  }
  
  func previousPhoto() {
    index = index > 0 ? index - 1 : images.count - 1
  }
}
