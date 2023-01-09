//
//  SingleImageViewer.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct SingleImageViewer: View {
  @ObservedObject var model: SingleImageViewerModel
  
  init?(images: [ImageData]) {
    guard let model = SingleImageViewerModel(images: images) else { return nil }
    self.model = model
  }
  
  var body: some View {
    VStack {
      Image(nsImage: model.imageData.image)
        .resizable()
        .scaledToFit()
        .frame(maxWidth: 1000, maxHeight: 800)
        .background(KeyEventHandling(keyPressHandler: model.keyPressHandler))
      Spacer()
      ImagePropertiesView(imageData: model.imageData, index: model.index, count: model.images.count)
    }
    
  }
}
