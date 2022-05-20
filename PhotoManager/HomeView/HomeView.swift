//
//  HomeView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct HomeView: View {
  @StateObject var model: HomeViewModel
  
  var blurRadius: CGFloat {
    return model.isLoading ? 5 : 0
  }
  
  var body: some View {
    VStack {
      if model.state == .selectDirectory {
        SelectDirectoryView(model: model.selectDirectoryModel)
      } else if model.state == .displayImages {
        PhotosView(model: PhotosViewModel(images: model.imageManager.images, state: .allPhotos))
      } else if model.state == .importMenu {
        ImportView(model: model.importModel)
      }
    }
    .padding(EdgeInsets(
      top: 50,
      leading: 50,
      bottom: 50,
      trailing: 50))
    .frame(width: 800, height: 600, alignment: .center)
    .blur(radius: blurRadius)
    .overlay(alignment: .center) {
      if model.isLoading {
        ProgressView()
      } 
    }
    
  }
    
}
