//
//  HomeView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct HomeView: View {
  @StateObject var model: HomeViewModel
  
  var body: some View {
    if model.state == .selectDirectory {
      SelectDirectoryView(model: model.selectDirectoryModel)
    } else if model.state == .displayImages {
      PhotosView(model: PhotosViewModel(images: model.imageManager.images, state: .allPhotos))
    }
      
  }
    
}
