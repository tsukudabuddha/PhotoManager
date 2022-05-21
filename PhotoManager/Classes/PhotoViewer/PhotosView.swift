//
//  PhotosView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct PhotosView: View {
  @ObservedObject var model: PhotosViewModel
  
  var body: some View {
    activeView()
  }
  
  func activeView() -> AnyView {
    let oop = AnyView(Text("Oop")) // TODO: Make this better
    switch model.state {
    case .allPhotos:
      return AnyView(AllPhotosView(model: model.allPhotosViewModel))
    case .singlePhoto:
      guard let selectedImage = model.allPhotosViewModel.selectedImage else { return oop }
      return AnyView(SingleImageViewer(image: selectedImage))
    }
  }
}
