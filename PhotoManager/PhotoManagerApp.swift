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
        ImportView(model: ImportViewModel(imageManager: ImageManager()))
          .tabItem {
            Text("Import + Review")
          }
        AllPhotosView(model: AllPhotosViewModel(images: []))
          .tabItem {
            Text("View All Images")
          }
      }
      
    }
  }
}
