//
//  DirectorySelector.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 2/16/23.
//

import SwiftUI

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
