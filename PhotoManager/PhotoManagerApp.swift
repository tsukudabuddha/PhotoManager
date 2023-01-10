//
//  PhotoManagerApp.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

@main
struct PhotoManagerApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        PhotoReviewHome(model: PhotoReviewHomeModel(images: []))
          .tabItem {
            Text("Review Images")
          }
        ImportView(model: ImportViewModel(imageManager: ImageManager()))
          .tabItem {
            Text("Quick Import")
          }
      }
      
    }
  }
}
