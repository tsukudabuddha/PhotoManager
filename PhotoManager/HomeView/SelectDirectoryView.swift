//
//  SelectDirectoryView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct SelectDirectoryView: View {
  @ObservedObject var model: SelectDirectoryViewModel
  
  var body: some View {
    HStack {
      Text(model.directoryName)
      Button(model.buttonText, action: model.openPanel)
    }
  }
}
