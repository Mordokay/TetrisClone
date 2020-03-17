//
//  Date+Extension.swift
//  TetrisClone
//
//  Created by kwamecorp on 17/03/2020.
//  Copyright © 2020 GreenSphereStudios. All rights reserved.
//

import Foundation

extension Date {

  var millisecondsSince1970: Double {
    return Double((self.timeIntervalSince1970 * 1000.0).rounded())
  }
}
