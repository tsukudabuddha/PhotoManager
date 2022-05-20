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
    case selectDirectory
    case displayImages
  }
  
  @ObservedObject var selectDirectoryModel = SelectDirectoryViewModel()
  @ObservedObject var imageManager = ImageManager()
  @Published var state: State = .selectDirectory
  
  var selectDirectoryObserver: AnyCancellable?
  var imageManagerObserver: AnyCancellable?
  
  init() {
    selectDirectoryObserver = selectDirectoryModel.$selectedDirectoryUrl.didSet.sink { [weak self] url in
      self?.handleDirectoryDidChange(url: url)
    }
    
    imageManagerObserver = imageManager.$imagesHaveLoaded.didSet.sink { [weak self] _ in
      guard let self = self else { return }
      self.handleImageManagerDidChange()
    }
    
  }
  
  func handleImageManagerDidChange() {
    if imageManager.images.count > 0 {
      self.state = .displayImages
    }
  }
  
  func handleDirectoryDidChange(url: URL?) {
    guard let url = url else { return } // TODO: Show some kind of error
    
    if selectDirectoryModel.directoryName != "Directory" { // TODO: Change this signal
      imageManager.loadImages(from: url, fileType: .jpg) // TODO: Allow for more image types
    }
  }
  
}
