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
    // TODO: Need to present SingleImageViewer when model.shouldShowReviewImages
    VStack() {
      Spacer()
      inputView
      Spacer()
      buttonStack
      .disabled(model.importButtonsAreDisabled)
      Spacer()
      Spacer()
      Button("Toggle Debug") {
        isDebug.toggle()
      }
    }
    .onAppear {
      model.updateImportButtonState()
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
  
  @ViewBuilder private var buttonStack: some View {
    Button("Review Images", action: model.reviewImages)
    Button("Import JPEG Only", action: model.importJPEG)
    Button("Import RAW Only", action: model.importRAW)
    Button("Import All Images", action: model.importAll)
  }
  
  @ViewBuilder private var inputView: some View {
    Section {
      VStack(alignment: .trailing) {
        if isDebug {
          debugInput
        } else {
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
              Spacer()
            }
          }
        }
        
        destinationSelector
        CheckboxView(text: "Seperate RAW files from JPEG", isOn: $model.storeRAWSeperately)
      }.fixedSize(horizontal: true, vertical: false)
    }
  }
  
  @ViewBuilder private var loadingOverlay: some View {
    if model.isLoading {
      ProgressView("Importing...", value: model.progress, total: model.imageManager.total)
    }
  }
  
  @ViewBuilder private var debugInput: some View {
    VStack(alignment: .trailing) {
      HStack { // Image Source
        HStack {
          Text("Source:")
            .bold()
          Text(model.sourceDirectory?.path ?? "Select your image folder")
        }
        Button("Select", action: { model.openPanel(for: .source) })
      }
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
