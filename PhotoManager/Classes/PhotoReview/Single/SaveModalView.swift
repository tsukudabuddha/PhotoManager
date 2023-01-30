//
//  SaveModalView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/9/23.
//

import SwiftUI

struct SaveModalView: View {
  var moveAction: (Bool) -> Void
  var copyAction: (Bool) -> Void
  var closeAction: () -> Void
  @State var isPhotoManagerDirectory = false // sd card v photomanager directory (/raw/ vs /all)
  
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
          // TODO: Make this automatic -- e.g. check for where the raw image is stored 
          Toggle("Check this box if you're reviewing images that have been imported by PhotoManager", isOn: $isPhotoManagerDirectory)
              .toggleStyle(.checkbox)
        }
      }
      Spacer(minLength: 24)
      HStack {
        Button("Move") {
          self.moveAction(isPhotoManagerDirectory)
          self.closeAction()
        }
        Button("Copy") {
          self.copyAction(isPhotoManagerDirectory)
          self.closeAction()
        }
      }
    }.padding(32)
  }
}
