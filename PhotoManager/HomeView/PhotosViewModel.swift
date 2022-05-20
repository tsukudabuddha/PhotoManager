//
//  PhotosViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import SwiftUI

class PhotosViewModel: ObservableObject {
  enum State {
    case allPhotos
    case singlePhoto
  }
  
  @Published var state: State
  @ObservedObject var allPhotosViewModel: AllPhotosViewModel
  
  
  var images: [ImageData]
  var cancellable: AnyCancellable?
  
  init(images: [ImageData], state: State) {
    self.allPhotosViewModel = AllPhotosViewModel(images: images)
    self.images = images
    self.state = state
    
    cancellable = allPhotosViewModel.objectWillChange
      .makeConnectable()
      .autoconnect()
       .sink { [weak self] in
           DispatchQueue.main.async { [weak self] in
             if self?.allPhotosViewModel.selectedImage != nil {
               self?.state = .singlePhoto
             }
           }
       }
  }
  
}
