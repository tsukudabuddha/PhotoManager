//
//  SingleImageViewer.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import AppKit
import SwiftUI

// TODO: Rename to something better -- ReviewImagesView? Rename ReviewImagesView to ReviewHomeView
struct PhotoReviewSingle: View {
  @ObservedObject var model: PhotoReviewSingleModel
  let window = NSApplication.shared.windows.first
  let handleBackPress: () -> Void
  
  @State var isModalPresented: Bool = false
  
  init?(images: [ReviewImageData], destinationDirectory: URL, handleBackPress: @escaping () -> Void) {
    guard let model = PhotoReviewSingleModel(images: images, destinationDirectory: destinationDirectory) else { return nil }
    self.model = model
    self.handleBackPress = handleBackPress
  }
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Button("Back", action: handleBackPress)
        Spacer()
        Button("Save Images") {
          self.isModalPresented = true
        }
        .sheet(isPresented: $isModalPresented) {
          SaveModalView(moveAction: model.handleMovePhotos, copyAction: model.handleSavePhotos, closeAction: {
            self.isModalPresented = false
          })
        }
      }
      if let nsImage = model.imageData.image, let window = window {
        HStack {
          Image(nsImage: nsImage)
            .resizable()
            .scaledToFit()
            .background(KeyEventHandling(keyPressHandler: model.keyPressHandler))
            
          SidePropertiesView(imageData: model.imageData, index: model.index, count: model.images.count)
        }
        .frame(minWidth: window.frame.width * 0.6, maxWidth: window.frame.width * 0.8, minHeight: window.frame.height * 0.6, maxHeight: window.frame.height * 0.8)
        BottomPropertiesView(imageData: model.imageData, index: model.index, count: model.images.count)
      }
    }
    .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
      .overlay(model.isLoading && model.progress <= CGFloat(model.images.count) ? loadingOverlay : nil)
    
  }
  
  @ViewBuilder private var loadingOverlay: some View {
    // TODO: This is not appearing -- Needs investigation. Might need to move progress to saveImages completion handler
    ProgressView("Saving Images...", value: model.progress, total: CGFloat(model.images.count))
  }
}


