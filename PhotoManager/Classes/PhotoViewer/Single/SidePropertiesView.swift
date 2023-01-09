//
//  SidePropertiesView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/8/23.
//

import SwiftUI

struct SidePropertiesView: View {
  let imageData: ImageData
  let index: Int
  let count: Int
  
  var body: some View {
    VStack {
      Spacer()
      VStack(spacing: 16) {
        VStack {
          Text("RAW")
            .foregroundColor(imageData.keepRAW ? Color.primary : Color.gray)
            .fontWeight(.bold)
          Text("JPG")
            .foregroundColor(imageData.keepJPG ? Color.primary : Color.gray)
            .fontWeight(.bold)
        }
        Text(String(describing: index + 1) + "/" + String(describing: count))
      }
    }
  }
}
