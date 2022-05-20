//
//  SelectDirectoryViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import SwiftUI

class SelectDirectoryViewModel: ObservableObject {
  var directoryName = "Directory"
  @Published var selectedDirectoryUrl: URL?
  
  func openPanel() {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    
    if panel.runModal() == .OK {
      directoryName = panel.url?.absoluteString ?? "<none>"
      selectedDirectoryUrl = panel.url
    }
  }
}

