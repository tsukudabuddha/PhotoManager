//
//  FileManager+createDirectoryIfNecessary.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 2/16/23.
//

import Foundation

extension FileManager {
  func createDirectoryIfNecessary(for url: URL) {
    try? createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
  }
}
