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
    let shouldIncrement = currentlyDisplayedImageIndex + 1 < images.count
    currentlyDisplayedImageIndex = shouldIncrement ? currentlyDisplayedImageIndex + 1 : 0
  }
  
  func goToPreviousImage() {
    let shouldDecrement = currentlyDisplayedImageIndex > 0
    currentlyDisplayedImageIndex = shouldDecrement ? currentlyDisplayedImageIndex - 1 : images.count - 1
  }
}
