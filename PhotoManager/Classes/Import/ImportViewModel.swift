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
  @Published var sourceDirectory: URL? = nil
  @Published var destinationDirectory: URL?
  @Published var importButtonsAreDisabled: Bool = true
  @Published var isPresentingCongratsAlert: Bool = false
  @Published var isPresentingErrorAlert: Bool = false
  @Published var storeRAWSeperately: Bool = true
  @Published var shouldShowReviewImages: Bool = false
  var errorText: String?
  @Published var isLoading: Bool = false
  @Published var progress: CGFloat = 0
  var mountedVolumes: [URL] {
    return fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsRemovableKey, .isVolumeKey, .volumeIsRootFileSystemKey], options: .skipHiddenVolumes) ?? []
  }
  
  var availableDrives: [URL]
  @Published var selectedDrive: URL?
  
  var fileManager: FileManager = FileManager.default
  
  // MARK: Observers
  var selectDirectoryObserver: AnyCancellable?
  var imageHaveLoadedObserver: AnyCancellable?
  
  init(imageManager: ImageManager) {
    self.imageManager = imageManager
    let mountedVolumes = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsRemovableKey, .isVolumeKey, .volumeIsRootFileSystemKey], options: .skipHiddenVolumes) ?? []
    self.availableDrives = mountedVolumes.filter { $0.absoluteString != "file:///" } // Only show removable drives
    self.selectedDrive = availableDrives.first
    self.destinationDirectory = URL(string: (userDefaults.object(forKey: "defaultImageFolder") as? String) ?? "")
    
    imageHaveLoadedObserver = imageManager.$imagesHaveLoaded.didSet.sink { haveLoaded in
      // TODO: Stop Loading indicator
      if haveLoaded {
        self.shouldShowReviewImages = true
      }
    }
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
      updateImportButtonState()
    }
  }
  
  func updateImportButtonState() {
    importButtonsAreDisabled = (sourceDirectory == nil && selectedDrive == nil) || destinationDirectory == nil
  }
  
  func refreshVolumes() {
    availableDrives = mountedVolumes.filter { $0.absoluteString != "file:///" }
    selectedDrive = availableDrives.first
  }
  
  func importJPEG() {
    importImages(fileType: .jpg)
  }
  
  func importRAW() {
    importImages(fileType: .raw)
  }
  
  func importAll() {
    importImages(fileType: .all)
  }
  
  func reviewImages() {
    guard let sourceDirectory = sourceDirectory else {
      return
    }
    // Start Loading indicator
    imageManager.loadImages(from: sourceDirectory, fileType: .all)
  }
  
  // MARK: Helpers
  private func importImages(fileType: FileType) {
    guard let destinationDirectory = destinationDirectory else {
      errorText = "missing destination directory" // TODO: Localize
      isPresentingErrorAlert = true
      return
    }
    isLoading = true
    let from: URL
    if let selectedDrive = selectedDrive {
      from = selectedDrive
    } else if let sourceDirectory = sourceDirectory {
      from = sourceDirectory
    } else {
      errorText = "missing source directory" // TODO: Localize
      isPresentingErrorAlert = true
      return
    }
    DispatchQueue.global(qos: .background).async {
      self.imageManager.saveImages(
        from: from,
        to: destinationDirectory,
        fileType: fileType,
        progressUpdateMethod: { progressIncrement in
          DispatchQueue.main.async {
            self.progress += CGFloat(progressIncrement)
          }
        },
        completion: { [weak self] in
          DispatchQueue.main.async {
            self?.isPresentingCongratsAlert = true
            self?.isLoading = false
            self?.progress = 0
          }
        })
    }
    
  }
}
