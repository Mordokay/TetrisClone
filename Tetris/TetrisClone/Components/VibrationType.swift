//
//  VibrationType.swift
//  TetrisClone
//
//  Created by kwamecorp on 17/03/2020.
//  Copyright © 2020 GreenSphereStudios. All rights reserved.
//

import Foundation
import AudioToolbox

enum VibrationType: SystemSoundID {
  case pop
  case cancelled
  case tryAgain
  case failed

  var rawValue: SystemSoundID {
    switch self {
    case .pop: return SystemSoundID(1520)
    case .cancelled: return SystemSoundID(1521)
    case .tryAgain: return SystemSoundID(1102)
    case .failed: return SystemSoundID(1520)
    }
  }
}
