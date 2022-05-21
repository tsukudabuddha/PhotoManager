//
//  ImportView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/20/22.
//

import SwiftUI

struct ImportView: View {
  @ObservedObject var model: ImportViewModel
  @State var isDebug: Bool = false
  var body: some View {
    Form {
      Spacer()
      // MARK: Input
      Section {
        if isDebug {
          debugInputs
        } else {
          VStack(alignment: .trailing, spacing: 4) {
            Picker("Source:", selection: $model.selectedDrive) { // Image Source
              ForEach(model.availableDrives, id: \.self) {
                Text($0.path)
              }
            }
          }
          destinationSelector
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
      Spacer()
      Button("Toggle Debug") {
        isDebug.toggle()
      }
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
  
  @ViewBuilder private var debugInputs: some View {
    HStack { // Image Source
      HStack {
        Text("Source:")
          .bold()
        Text(model.sourceDirectory != nil ? model.sourceDirectory!.path : "Select your image folder")
      }
      Button("Select", action: { model.openPanel(for: .source) })
    }
    destinationSelector
  }
  
  @ViewBuilder private var destinationSelector: some View {
    HStack { // Image Destination
      HStack {
        Text("Destination:")
          .bold()
        Text(model.desinationDirectory != nil ? model.desinationDirectory!.path : "Select your image folder")
      }
      Button("Select", action: { model.openPanel(for: .destination) })
    }
  }
}
