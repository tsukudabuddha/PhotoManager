//
//  ImportViewModel.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/20/22.
//

import Combine
import SwiftUI

class ImportViewModel: ObservableObject {
  enum State {
    case showButtons
    case showSelectDirectory
  }
  enum ButtonType {
    case jpeg
    case raw
    case all
    case viewAll
  }
  
  let imageManager: ImageManager
  
  @Published var state: State = .showButtons
  @ObservedObject var selectDirectoryModel = SelectDirectoryViewModel(
    buttonText: "Select the directory you want to store your images in"
  )
  @Published var isViewAllDisabled: Bool = true
  
  // MARK: Observers
  var selectDirectoryObserver: AnyCancellable?
  
  init(imageManager: ImageManager) {
    self.imageManager = imageManager
    
    selectDirectoryObserver = selectDirectoryModel.$selectedDirectoryUrl.didSet.sink { [weak self] url in
      guard let url = url,
            let self = self else { return }
      // TODO: Show Loading Indicator
      self.imageManager.saveImages(to: url) {
        // TODO: Show success or error message
        // TODO: Hide loading indicator
        print("saved images")
      }
    }
  }
  
  func handleButtonTap(_ buttonType: ButtonType) {
    switch buttonType {
    case .jpeg:
      print("Import JPEG")
    case .raw:
      print("Import Raw")
    case .all:
      print("Import all")
    case .viewAll:
      // TODO: Show all photos view
      print("View All")
    }
    
    state = .showSelectDirectory
  }
}
