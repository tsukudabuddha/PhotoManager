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
      HomeView(model: HomeViewModel())
    }
  }
}
