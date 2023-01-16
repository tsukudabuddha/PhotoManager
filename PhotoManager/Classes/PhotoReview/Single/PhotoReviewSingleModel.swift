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
  var imageData: ImageData {
    return images[index]
  }
  
  @Published var images: [ImageData]
  @Published var progress: CGFloat = 0
  @Published var isLoading: Bool = false
  var isVertical: Bool {
    guard let image = imageData.image else { return false }
    return image.size.width < image.size.height
  }
  
  let imageManager = ImageManager()
  let destinationDirectory: URL
  
  init?(images: [ImageData], destinationDirectory: URL) {
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
      //    case 38: // J
    case 8: // C
      images[index].keepRAW = !imageData.keepRAW
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
  
  func handleMovePhotos() {
    savePhotos(move: true)
  }
  
  func handleSavePhotos() {
    savePhotos()
  }
  
  private func savePhotos(move: Bool = false) {
    isLoading = true
    progress = 0
    for image in images {
      progress += 1
      let fromUrl = URL(fileURLWithPath: image.path)
      if image.keepRAW {
        let filename = String(fromUrl.lastPathComponent.dropLast(4)) + ".RAF" // TODO: Support more RAW formats
        let rawImageUrl = fromUrl.deletingLastPathComponent().appendingPathComponent("Raw").appendingPathComponent(filename)
        // TODO: Check if there's a raw file first
        imageManager.saveImage(from: rawImageUrl, to: destinationDirectory, fileType: .raw, move: move) { num in
          print(num) // TODO: What it do?
        }
      }
      if image.keepJPG {
        imageManager.saveImage(from: fromUrl, to: destinationDirectory, fileType: .jpg, move: move) { num in
          print(num) // TODO: What it do?
        }
      }
    }
    progress = 0
    isLoading = false

  }
}
