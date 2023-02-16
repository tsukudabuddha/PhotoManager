//
//  FileType.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 2/16/23.
//

import Foundation

enum FileType {
  case jpg
  case raw
  case video
  case all
  
  static func isValidImageFile(url: URL, fileType: FileType) -> Bool {
    switch fileType {
    case .jpg:
      return ["JPG", "JPEG" , "JPE" , "JIF" , "JFIF"].contains(url.pathExtension.uppercased())
    case .raw:
      return ["RAF", "RAW" , "GPR" , "ARW" , "NEF", "DNG"].contains(url.pathExtension.uppercased())
    case .video:
      return ["MP4", "MOV"].contains(url.pathExtension.uppercased())
    case .all:
      return FileType.isValidImageFile(url: url, fileType: .raw) || FileType.isValidImageFile(url: url, fileType: .jpg)
    }
  }
  
  static func isRAWImage(url: URL) -> Bool {
    return FileType.isValidImageFile(url: url, fileType: .raw)
  }
}
