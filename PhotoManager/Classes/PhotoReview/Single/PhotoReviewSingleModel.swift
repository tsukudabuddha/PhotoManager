//
//  SingleImageViewerModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/8/23.
//

import AppKit
import Foundation

class PhotoReviewSingleModel: ObservableObject {
  @Published var index: Int = 0
  var imageData: ReviewImageData {
    return images[index]
  }
  
  @Published var images: [ReviewImageData]
  @Published var progress: CGFloat = 0
  @Published var isLoading: Bool = false
  @Published var isPhotoManagerDirectory = false
  @Published var updateImageData = false // Hack to force ui to update when imageData is updated (keepRaw/ keepJPG)
  var isVertical: Bool {
    guard let image = imageData.image else { return false }
    return image.size.width < image.size.height
  }
  
  let imageManager = ImageManager()
  let destinationDirectory: URL
  
  init?(images: [ReviewImageData], destinationDirectory: URL) {
    guard images.count > 0 else { return nil }
    self.images = images
    self.destinationDirectory = destinationDirectory
  }
  
  
  // MARK: KeyPressHandler
  func keyPressHandler(keyCode: UInt16) {
    switch(keyCode) {
      //    case 3: // F
    case 6: // Z
      images[index].keepJPG = !imageData.keepJPG
      updateImageData = !updateImageData
      //    case 38: // J
    case 8: // C
      images[index].keepRAW = !imageData.keepRAW
      updateImageData = !updateImageData
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
  
  func handleMovePhotos(isPhotoManagerDirectory: Bool) {
    savePhotos(move: true, isPhotoManagerDirectory: isPhotoManagerDirectory)
  }
  
  func handleSavePhotos(isPhotoManagerDirectory: Bool) {
    savePhotos(isPhotoManagerDirectory: isPhotoManagerDirectory)
  }
  
  private func savePhotos(move: Bool = false, isPhotoManagerDirectory: Bool) {
    isLoading = true
    progress = 0
    for image in images {
      progress += 1
      if image.keepRAW, let rawURL = image.rawURL {
        imageManager.saveImage(from: rawURL, to: destinationDirectory, fileType: .raw, move: move) { num in
          print(num) // TODO: What it do?
        }
      }
      if image.keepJPG, let jpgURL = image.jpgURL {
        imageManager.saveImage(from: jpgURL, to: destinationDirectory, fileType: .jpg, move: move) { num in
          print(num) // TODO: What it do?
        }
      }
    }
    progress = 0
    isLoading = false
    
  }
}
