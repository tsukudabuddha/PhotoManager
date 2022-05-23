//
//  CheckboxView.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/22/22.
//

import SwiftUI

struct CheckboxView: View {
  let text: String
  let isOn: Binding<Bool>
  var body: some View {
    HStack(alignment: .bottom) {
      Text(text)
      Toggle("", isOn: isOn)
        .toggleStyle(.checkbox)
    }
  }
}
