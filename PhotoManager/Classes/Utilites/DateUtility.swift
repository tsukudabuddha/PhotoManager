//
//  DateUtility.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 1/8/23.
//

import Foundation

class DateUtility: NSObject {
  static let shared = DateUtility()
  
  let calendar = Calendar.current
  let dateFormatter = DateFormatter()
  
  func getComponents(from date: Date) -> DateComponents {
    return calendar.dateComponents([.day, .month, .year], from: date)
  }
}



