//
//  AllPhotosViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

class PhotoReviewHomeModel: ObservableObject {
  @Published var destinationDirectory: URL? = nil
  @Published var imageManager = ImageManager()
  @Published var index = 0
  @Published var selectedImage: Image?
  @Published var selectedImageData: ImageData?
  
  let userDefaults = UserDefaults.standard
  
  // TODO: Move this to a DirectoryManager or something + reuse
  @Published var sourceDirectory: URL? = nil {
    didSet {
      if let directory = sourceDirectory {
//        imageManager.loadImages(from: directory, fileType: .jpg)
        imageManager.loadImagesForReview(from: directory)
        images = imageManager.imagesForReview.sorted(by: { $0.date < $1.date })
      }
    }
  }
  
  
  
  func openPanel(type: DirectoryType) {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    
    if panel.runModal() == .OK {
      guard let url = panel.url else { return }
      switch type {
      case .source:
        sourceDirectory = url
        userDefaults.set(url.absoluteString, forKey: UserDefaultKeys.reviewSourceDirectory.rawValue)
      case .destination:
        destinationDirectory = url
        userDefaults.set(url.absoluteString, forKey: UserDefaultKeys.reviewDestinationDirectory.rawValue)
      }
      
    }
  }
  
  let height: CGFloat = 150
  var images: [ReviewImageData]
  
  init(images: [ReviewImageData]) {
    self.images = images
    self.destinationDirectory = URL(string: (userDefaults.object(forKey: UserDefaultKeys.reviewDestinationDirectory.rawValue) as? String) ?? "")
    self.sourceDirectory = URL(string: (userDefaults.object(forKey: UserDefaultKeys.reviewSourceDirectory.rawValue) as? String) ?? "")
  }
  
  func handleImageTap(_ imageData: ImageData) {
    self.selectedImageData = imageData
    guard let image = imageData.image else { return } // TODO: Show error
    self.selectedImage = Image(nsImage: image)
  }
  
  
  
}
