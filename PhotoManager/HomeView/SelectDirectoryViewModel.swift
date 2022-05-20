//
//  SelectDirectoryViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import SwiftUI

class SelectDirectoryViewModel: ObservableObject {
  @Published var selectedDirectoryUrl: URL?
  
  var directoryName = "Directory"
  let buttonText: String
  
  init(buttonText: String) {
    self.buttonText = buttonText
  }
  
  
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

