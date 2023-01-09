//
//  ImagePropertiesView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/8/23.
//

import SwiftUI

struct BottomPropertiesView: View {
  let imageData: ImageData
  let index: Int
  let count: Int
  
  // TODO: Create a model
  var dateString: String {
    return DateFormatter.localizedString(from: imageData.date, dateStyle: .medium, timeStyle: .short)
  }
  
  var body: some View {
    VStack {
      Text(dateString)
      Spacer()
      Spacer()
      // Tips / Instructions
      VStack(alignment: .leading) {
        Text("Press \"F\" to flag to save the RAW file")
        Text("Press \"J\" to flag to save the JPG file")
        Text("Press the space bar to go to the next image")
        Text("You can also navigate using the arrow keys")
      }
    }
  }
}
