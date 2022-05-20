//
//  AllPhotosViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

class AllPhotosViewModel: ObservableObject {
  var columns: [GridItem] = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]
  
  let height: CGFloat = 150
  let images: [ImageData]
  @Published var selectedImage: Image?
  
  init(images: [ImageData]) {
    self.images = images
  }
  
  func handleImageTap(_ image: Image) {
    self.selectedImage = image
  }
  
  
}
