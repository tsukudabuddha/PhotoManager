//
//  SingleImageViewer.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import SwiftUI

struct SingleImageViewer: View {
  let image: Image
  var body: some View {
    image
      .resizable()
      .dynamicTypeSize(.large)
  }
}
