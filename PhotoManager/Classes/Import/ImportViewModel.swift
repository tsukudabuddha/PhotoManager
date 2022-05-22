//
//  ImportViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/20/22.
//

import Combine
import SwiftUI

class ImportViewModel: ObservableObject {
  let userDefaults = UserDefaults.standard
  @ObservedObject var imageManager: ImageManager
  @Published var sourceDirectory: URL?
  @Published var destinationDirectory: URL?
  @Published var importButtonsAreDisabled: Bool = true
  @Published var isPresentingAlert: Bool = false
  @Published var isLoading: Bool = false
  @Published var progress: CGFloat = 0
  
  var availableDrives: [URL]
  @Published var selectedDrive: URL
  
  var fileManager: FileManager = FileManager.default
  
  // MARK: Observers
  var selectDirectoryObserver: AnyCancellable?
  
  init(imageManager: ImageManager) {
    self.imageManager = imageManager
    self.availableDrives = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsRemovableKey, .isVolumeKey, .volumeIsRootFileSystemKey], options: .skipHiddenVolumes) ?? []
    self.selectedDrive = availableDrives.first ?? URL(string: "")! // TODO: Should I change this??
    self.destinationDirectory = URL(string: (userDefaults.object(forKey: "defaultImageFolder") as? String) ?? "")
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
        destinationDirectory = url
        userDefaults.set(url.absoluteString, forKey: "defaultImageFolder")
      }
      
      guard sourceDirectory != nil && destinationDirectory != nil else { return }
      importButtonsAreDisabled = false
    }
  }
  
  func importImages(fileType: FileType) {
    guard let sourceDirectory = sourceDirectory,
          let destinationDirectory = destinationDirectory else { return } // TODO: Show an error
    isLoading = true
    DispatchQueue.global(qos: .background).async {
      self.imageManager.saveImages(
        from: sourceDirectory,
        to: destinationDirectory,
        fileType: fileType,
        progressUpdateMethod: { progressIncrement in
          DispatchQueue.main.async {
            self.progress += CGFloat(progressIncrement)
          }
        },
        completion: { [weak self] in
          DispatchQueue.main.async {
            self?.isPresentingAlert = true
            self?.isLoading = false
            self?.progress = 0
          }
        })
    }
    
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
