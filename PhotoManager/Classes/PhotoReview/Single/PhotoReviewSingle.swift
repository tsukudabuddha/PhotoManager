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
  
  init?(images: [ImageData], destinationDirectory: URL, handleBackPress: @escaping () -> Void) {
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
      if let nsImage = model.imageData.image {
        HStack {
          Image(nsImage: nsImage)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: window?.frame.width, maxHeight: (window != nil) ? window!.frame.height - 300 : nil)
            .background(KeyEventHandling(keyPressHandler: model.keyPressHandler))
          SidePropertiesView(imageData: model.imageData, index: model.index, count: model.images.count)
        }
        Spacer()
        BottomPropertiesView(imageData: model.imageData, index: model.index, count: model.images.count)
      }
    }.padding(EdgeInsets(top: 32, leading: 32, bottom: 32, trailing: 32))
    
  }
}
