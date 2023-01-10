//
//  KeyEventHandling.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/6/23.
//

import Foundation
import SwiftUI

struct KeyEventHandling: NSViewRepresentable {
  let keyPressHandler: (_ keyCode: UInt16) -> Void
  
  class KeyView: NSView {
    let keyPressHandler: (_ keyCode: UInt16) -> Void
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
      keyPressHandler(event.keyCode)
    }
    
    init(keyPressHandler: @escaping (_: UInt16) -> Void) {
      self.keyPressHandler = keyPressHandler
      super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let view = KeyView(keyPressHandler: keyPressHandler)
    DispatchQueue.main.async { // wait till next event cycle
      view.window?.makeFirstResponder(view)
    }
    return view
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
  }
}
