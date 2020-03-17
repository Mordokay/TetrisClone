//
//  Comparable+Extension.swift
//
//  Created by kwamecorp on 02/01/2020.
//  Copyright © 2020 Impossible. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
