//
//  Publisher+didSet.swift
//  PhotoManager
//
//  Created by Andrew Tsukuda on 5/19/22.
//

import Combine
import Foundation

extension Published.Publisher {
  var didSet: AnyPublisher<Value, Never> { // TODO: Investigate usage-- caused some issues
    self.receive(on: RunLoop.main).eraseToAnyPublisher()
  }
}
