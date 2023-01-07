//
//  SingleImageViewer.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct SingleImageViewer: View {
  let images: [ImageData]
  @State var index: Int = 0
  var image: Image? {
    if index < images.count {
      return Image(nsImage: images[index].image)
    }
    return nil
  }
  
  var body: some View {
    if let img = image {
      img
        .resizable()
        .scaledToFit()
        .frame(maxWidth: 1000, maxHeight: 800)
        .background(KeyEventHandling(keyPressHandler: keyPressHandler))
    }
  }
  
  
  func keyPressHandler(keyCode: UInt16) {
    switch(keyCode) {
    case 123:
      index = index > 0 ? index - 1 : images.count - 1
    case 124:
      index = index < images.count - 1 ? index + 1 : 0
    default:
      return
    }
  }

}
