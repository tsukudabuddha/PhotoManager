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
    VStack {
      Spacer()
      // MARK: Input
      VStack(alignment: .trailing, spacing: 4) {
        HStack { // Image Source
          HStack {
            Text("Source:")
              .bold()
            Text(model.sourceDirectory != nil ? model.sourceDirectory!.path : "Select your image folder")
          }
          
          Button("Select", action: { model.openPanel(for: .source) })
        }
        HStack { // Image Destination
          HStack {
            Text("Destination:")
              .bold()
            Text(model.desinationDirectory != nil ? model.desinationDirectory!.path : "Select your image folder")
          }
          
          Button("Select", action: { model.openPanel(for: .destination) })
        }
      }
      
      Spacer()
      
      // MARK: Buttons
      Button("Import JPEG Only", action: model.importJPEG)
        .disabled(model.importButtonsAreDisabled)
      Button("Import RAW Only", action: model.importRAW)
        .disabled(model.importButtonsAreDisabled)
      Button("Import All Images") {
        model.importAll()
      }
      .disabled(model.importButtonsAreDisabled)
      Spacer()
    }
    .padding(EdgeInsets(
      top: 50,
      leading: 50,
      bottom: 50,
      trailing: 50))
    .frame(width: 800, height: 600, alignment: .center)
    .blur(radius: model.isLoading ? 5 : 0)
    .overlay(loadingOverlay)
    .alert("Congrats!", isPresented: $model.isPresentingAlert) {
      Button("OK", role: .cancel) { }
    }
    
  }
  
  @ViewBuilder private var loadingOverlay: some View {
    if model.isLoading {
      ProgressView("Importing...", value: model.progress, total: model.imageManager.total)
    }
  }
}
