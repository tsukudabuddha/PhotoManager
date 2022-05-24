//
//  SingleImageViewer.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct SingleImageViewer: View {
  @ObservedObject var model: SingleImageViewModel
  @FocusState private var isFocused: Bool
  
  var body: some View {
    ZStack {
      Image(nsImage: model.currentImage)
        .renderingMode(.original)
        .resizable()
        .aspectRatio(NSSizeToCGSize(model.currentImage.size), contentMode: .fit)
      Text("") // Hidden focused field so I can watch for keyboard input w/out a focus highlight
        .hidden()
        .focusable()
        .focused($isFocused)
        .onMoveCommand { direction in
          switch direction {
          case .right:
            model.goToNextImage()
          case .left:
            model.goToPreviousImage()
          default:
            print("default")
          }
        }
    }
    .onChange(of: isFocused) {
      model.isFocused = $0
    }
    .onAppear {
      self.isFocused = model.isFocused
    }
  }
}
