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
      if let images = model.images, showImageViewer, images.count > 0, let destination = model.destinationDirectory, model.sourceDirectory != nil {
        PhotoReviewSingle(images: images, destinationDirectory: destination, handleBackPress: {
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
        // Grid view of all
//        LazyVGrid(columns: model.columns, spacing: 16) {
//          ForEach(model.images) { imageData in
//            if let nsImage = imageData.image, let image = Image(nsImage: nsImage) {
//              VStack {
//                image
//                  .resizable()
//                  .scaledToFit()
//              }
//              .contentShape(Rectangle())
//              .frame(minWidth: 100, idealWidth: 250, maxWidth: 300, minHeight: 100, idealHeight: 250, maxHeight: 300, alignment: .center)
//              .onTapGesture {
//                model.handleImageTap(imageData)
//              }
//            }
//
//          }
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      
    }
  }
}

// TODO: Move to it's own shared file

struct DirectorySelector: View {
  var text: String
  var path: String?
  var selectText: String
  var buttonAction: () -> Void
  
  init(text: String, path: String, selectText: String = "Select your image folder", buttonAction: @escaping () -> Void) {
    self.text = text
    self.path = path
    self.selectText = selectText
    self.buttonAction = buttonAction
  }
  var body: some View {
    HStack { // Image Destination
      HStack {
        Text(text)
          .bold()
        Text(path ?? selectText)
      }
      Button("Select", action: buttonAction)
    }
  }
}
