//
//  SingleImageViewer.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import AppKit
import SwiftUI

struct SingleImageViewer: View {
  @ObservedObject var model: SingleImageViewerModel
  let window = NSApplication.shared.windows.first
  
  init?(images: [ImageData]) {
    guard let model = SingleImageViewerModel(images: images) else { return nil }
    self.model = model
  }
  
  var body: some View {
    VStack {
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
