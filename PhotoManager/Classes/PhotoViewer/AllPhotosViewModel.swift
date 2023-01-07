//
//  AllPhotosViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

class AllPhotosViewModel: ObservableObject {
  
  // TODO: Move this to a DirectoryManager or something + reuse
  @Published var sourceDirectory: URL? = nil {
    didSet {
      if let directory = sourceDirectory {
        imageManager.loadImages(from: directory, fileType: .jpg)
        images = imageManager.images.sorted(by: { $0.date ?? Date() < $1.date ?? Date()})
      }
    }
  }
  
  @Published var imageManager = ImageManager()
  
  @Published var index = 0
  
  func openPanel() {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    
    if panel.runModal() == .OK {
      guard let url = panel.url else { return }
      
      sourceDirectory = url
    }
  }
  var columns: [GridItem] = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]
  
  let height: CGFloat = 150
  var images: [ImageData]
  @Published var selectedImage: Image?
  @Published var selectedImageData: ImageData?
  
  init(images: [ImageData]) {
    self.images = images
  }
  
  func handleImageTap(_ imageData: ImageData) {
    self.selectedImageData = imageData
    self.selectedImage = Image(nsImage: imageData.image)
  }
  
  
  
}
