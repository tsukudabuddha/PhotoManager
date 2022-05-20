//
//  ImportView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/20/22.
//

import SwiftUI

struct ImportView: View {
  @ObservedObject var model: ImportViewModel
  var body: some View {
    if model.state == .showButtons {
      VStack {
        Button("Import JPEG Only") {
          model.handleButtonTap(.jpeg)
        }
        Button("Import RAW Only") {
          model.handleButtonTap(.raw)
        }
        Button("Import All Images") {
          model.handleButtonTap(.all)
        }
        Button("View All") {
          model.handleButtonTap(.viewAll)
        }
        .disabled(model.isViewAllDisabled)
      }
    } else if model.state == .showSelectDirectory {
      SelectDirectoryView(model: model.selectDirectoryModel)
    }
    
  }
}
