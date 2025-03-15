//
//  SidePropertiesView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/8/23.
//

import SwiftUI

struct SidePropertiesView: View {
  let imageData: ReviewImageData
  let index: Int
  let count: Int
  let update: Bool // Hack to update JPG/ RAW text
  
  var body: some View {
    VStack {
      if let exifData = imageData.exifData {
        VStack(alignment: .leading) {
          if let iso = exifData.isoString {
            Text(iso)
          }
          if let focalLength = exifData.focalLengthString {
            Text(focalLength)
          }
          if let aperture = exifData.apertureString {
            Text(aperture)
          }
          if let shutterSpeed = exifData.shutterSpeedString {
            Text(shutterSpeed)
          }
        }.foregroundStyle(.gray)
      }
      Spacer()
      VStack(spacing: 16) {
        HStack(spacing: 2) {
          if imageData.jpgURL != nil {
            Text("JPG")
              .foregroundColor(imageData.keepJPG ? Color.primary : Color.gray)
              .fontWeight(.bold)
          }
          if imageData.rawURL != nil {
            Text("RAW")
              .foregroundColor(imageData.keepRAW ? Color.primary : Color.gray)
              .fontWeight(.bold)
          }
          
        }
        Text(String(describing: index + 1) + "/" + String(describing: count))
      }
    }
  }
}
