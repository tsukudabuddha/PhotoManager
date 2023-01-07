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
          VStack(alignment: .trailing) {
            let isDisabled = model.selectedDrive == nil
            Picker("SD Card Drive:", selection: $model.selectedDrive) { // Image Source
              ForEach(model.availableDrives, id: \.self) {
                Text($0.path).tag($0 as URL?)
              }
            }
            .disabled(isDisabled)
            if isDisabled {
              HStack {
                Text("There are no attached drives")
                  .foregroundColor(.red)
                Button("Refresh", action: model.refreshVolumes)
              }
              
            }
            destinationSelector
//            HStack(alignment: .bottom) {
//              Text("Seperate RAW files from JPEG")
//              Toggle("", isOn: $model.storeRAWSeperately)
//                .toggleStyle(.checkbox)
//            }
          }.fixedSize(horizontal: true, vertical: false)
        }
      }
      .onAppear {
        model.updateImportButtonState()
      }
      Spacer()
      
      // MARK: Buttons
      Button("Import JPEG Only", action: model.importJPEG)
        .disabled(model.importButtonsAreDisabled)
      Button("Import RAW Only", action: model.importRAW)
        .disabled(model.importButtonsAreDisabled)
      Button("Import All Images", action: model.importAll)
        .disabled(model.importButtonsAreDisabled)
      Button("Import All Videos", action: model.importVideo)
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
    .alert("Congrats!", isPresented: $model.isPresentingCongratsAlert) {
      Button("OK", role: .cancel) { }
    }
    .alert(isPresented: $model.isPresentingErrorAlert) {
      Alert(
        title: Text("An error has occurred"),
        message: Text(model.errorText ?? ""),
        dismissButton: .default(Text("Got it!"))
      )
    }
    
  }
  
  @ViewBuilder private var loadingOverlay: some View {
    if model.isLoading && model.progress <= model.imageManager.total {
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
