//
//  ViewAllPhotosView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct PhotoReviewHome: View {
  @ObservedObject var model: PhotoReviewHomeModel
  var sourceText: String {
    return "Photos to Review:"
  }
  var destinationText: String {
    return "Photo Library:"
  }
  
  @State var showImageViewer: Bool = false
  
  var body: some View {
    VStack(alignment: .center) {
      Spacer()
      if showImageViewer, model.images.count > 0, let destination = model.destinationDirectory, model.sourceDirectory != nil {
        PhotoReviewSingle(images: model.images, destinationDirectory: destination, handleBackPress: {
          self.showImageViewer = false
        })
      } else {
        DirectorySelector(text: sourceText, path: model.sourceDirectory?.path ?? "") {
          model.openPanel(type: .source)
        }
        if model.images.count == 0 {
          Text("There are no photos in the selected directory")
            .foregroundColor(.red)
        }
        DirectorySelector(text: destinationText, path: model.destinationDirectory?.path ?? "") {
          model.openPanel(type: .destination)
        }
        Button("Review Images") {
          self.showImageViewer = true
        }
        Spacer()
        Spacer()
      }
      
    }
  }
}
