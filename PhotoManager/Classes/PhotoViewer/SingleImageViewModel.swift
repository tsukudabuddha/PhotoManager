//
//  SingleImageViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/23/22.
//

import SwiftUI

class SingleImageViewModel: ObservableObject {
  @Published var currentlyDisplayedImageIndex: Int = 0
  @Published var images: [ImageData]
  @Published var isFocused = true
  var currentImage: NSImage {
    return images[currentlyDisplayedImageIndex].image
  }
  
  init(images: [ImageData]) {
    self.images = images
  }
  
  func goToNextImage() {
    guard currentlyDisplayedImageIndex + 1 < images.count else { return }
    currentlyDisplayedImageIndex += 1
  }
  
  func goToPreviousImage() {
    guard currentlyDisplayedImageIndex > 0 else { return }
    currentlyDisplayedImageIndex -= 1
  }
}
