//
//  SaveModalView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/9/23.
//

import SwiftUI

struct SaveModalView: View {
  var moveAction: () -> Void
  var copyAction: () -> Void
  var closeAction: () -> Void
  
  var body: some View {
    VStack {
      HStack {
        // Exit Button
        Button("Exit", action: closeAction)
        // Text
        VStack(alignment: .leading) {
          Text("Save your images")
            .font(.title)
          Text("Do you want to move the files from your SD card? Or did you want to copy them?")
        }
      }
      Spacer(minLength: 24)
      HStack {
        Button("Move") {
          self.moveAction()
          self.closeAction()
        }
        Button("Copy") {
          self.copyAction()
          self.closeAction()
        }
      }
    }.padding(32)
  }
}
