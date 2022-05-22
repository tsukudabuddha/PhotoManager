//
//  URL+isDirectory.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/21/22.
//

import Foundation

extension URL {
  var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}
