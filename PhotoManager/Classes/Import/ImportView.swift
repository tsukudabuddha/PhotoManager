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
  var destinationText: String {
    return isDebug ? "Destination:" : "Photo Library:"
  }
  var body: some View {
    VStack() {
      Spacer()
      // MARK: Input
      Section {
        if isDebug {
          debugInputs
        } else {
          VStack { // WIP
            Picker("SD Card Drive:", selection: $model.selectedDrive) { // Image Source
              ForEach(model.availableDrives, id: \.self) {
                Text($0.path)
              }
            }
            destinationSelector
          }.fixedSize(horizontal: true, vertical: false)
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
    VStack(alignment: .trailing) {
    HStack { // Image Source
      HStack {
        Text("Source:")
          .bold()
        Text(model.sourceDirectory?.path ?? "Select your image folder")
      }
      Button("Select", action: { model.openPanel(for: .source) })
    }
    destinationSelector
    }
  }
  
  @ViewBuilder private var destinationSelector: some View {
    HStack { // Image Destination
      HStack {
        Text(destinationText)
          .bold()
        Text(model.destinationDirectory?.path ?? "Select your image folder")
      }
      Button("Select", action: { model.openPanel(for: .destination) })
    }
  }
}
