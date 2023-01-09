//
//  ViewAllPhotosView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct AllPhotosView: View {
  @ObservedObject var model: AllPhotosViewModel
  var destinationText: String {
    return "Photo Library:"
  }
  
  var body: some View {
    ScrollView {
      if let images = model.images, images.count > 0 {
        SingleImageViewer(images: images)
      } else {
        destinationSelector
        LazyVGrid(columns: model.columns, spacing: 16) {
          ForEach(model.images) { imageData in
            let image = Image(nsImage: imageData.image)
            VStack {
              image
                .resizable()
                .scaledToFit()
            }
            .contentShape(Rectangle())
            .frame(minWidth: 100, idealWidth: 250, maxWidth: 300, minHeight: 100, idealHeight: 250, maxHeight: 300, alignment: .center)
            .onTapGesture {
              model.handleImageTap(imageData)
            }
            
          }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      
    }
  }
  
  @ViewBuilder private var destinationSelector: some View {
    HStack { // Image Destination
      HStack {
        Text(destinationText)
          .bold()
        Text(model.sourceDirectory?.path ?? "Select your image folder")
      }
      Button("Select", action: model.openPanel)
    }
  }
}
