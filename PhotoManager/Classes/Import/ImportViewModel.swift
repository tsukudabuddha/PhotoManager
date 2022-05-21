//
//  ImportViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/20/22.
//

import Combine
import SwiftUI

class ImportViewModel: ObservableObject {
  let imageManager: ImageManager
  @Published var sourceDirectory: URL?
  var desinationDirectory: URL? {
    didSet {
      
    }
  }
  @Published var importButtonsAreDisabled: Bool = true
  @Published var isPresentingAlert: Bool = false
  
  // MARK: Observers
  var selectDirectoryObserver: AnyCancellable?
  
  init(imageManager: ImageManager) {
    self.imageManager = imageManager
  }
  
  enum DirectoryType {
    case source
    case destination
  }
  
  func openPanel(for directory: DirectoryType) {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    
    if panel.runModal() == .OK {
      guard let url = panel.url else { return }

      switch directory {
      case .source:
        sourceDirectory = url
      case .destination:
        desinationDirectory = url
      }
      
      guard sourceDirectory != nil && desinationDirectory != nil else { return }
      importButtonsAreDisabled = false
    }
  }
  
  func importImages(fileType: FileType) {
    guard let sourceDirectory = sourceDirectory,
          let destinationDirectory = desinationDirectory else { return } // TODO: Show an error
    imageManager.saveImages(
      from: sourceDirectory,
      to: destinationDirectory,
      fileType: fileType,
      completion: { [weak self] in
        self?.isPresentingAlert = true
      })
  }
  
  func importJPEG() {
    importImages(fileType: .jpg)
  }
  
  func importRAW() {
    importImages(fileType: .raw)
  }
  
  func importAll() {

  }
}
