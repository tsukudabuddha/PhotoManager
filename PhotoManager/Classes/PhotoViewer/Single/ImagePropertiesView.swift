//
//  ImagePropertiesView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/8/23.
//

import SwiftUI

struct ImagePropertiesView: View {
  let imageData: ImageData
  let index: Int
  let count: Int
  
  var body: some View {
    VStack {
      // Image Properties
      HStack {
        Text("RAW")
          .foregroundColor(imageData.keepRAW ? Color.black : Color.gray)
          .fontWeight(.bold)
        Text("JPG")
          .foregroundColor(imageData.keepJPG ? Color.black : Color.gray)
          .fontWeight(.bold)
        Text(String(describing: index + 1) + "/" + String(describing: count))
      }
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
