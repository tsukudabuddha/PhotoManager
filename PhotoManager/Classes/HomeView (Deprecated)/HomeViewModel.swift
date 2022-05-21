//
//  HomeViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
  enum State {
    case importMenu
    case selectDirectory
    case displayImages
  }
  
  lazy var importModel: ImportViewModel = ImportViewModel(imageManager: imageManager)
  @ObservedObject var imageManager = ImageManager()
  @Published var state: State = .selectDirectory
  @Published var isLoading: Bool = false
  
  var imageManagerObserver: AnyCancellable?
  
  init() {
    imageManagerObserver = imageManager.$imagesHaveLoaded.didSet.sink { [weak self] _ in
      guard let self = self else { return }
      self.handleImageManagerDidChange()
    }
    
  }
  
  func handleImageManagerDidChange() {
    if imageManager.images.count > 0 {
      // End loading
//      self.isLoading = false
      self.state = .importMenu
    }
  }
  
  func handleDirectoryDidChange(url: URL?) {
//    guard let url = url else { return } // TODO: Show some kind of error
//
//    if selectDirectoryModel.directoryName != "Directory" { // TODO: Change this signal
//      // Start loading
////      self.isLoading = true
//      DispatchQueue.global(qos: .background).async {
//        self.imageManager.loadImages(from: url, fileType: .jpg) // TODO: Allow for more image types
//      }
//    }
  }
  
}
