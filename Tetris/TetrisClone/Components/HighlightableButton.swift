//
//  HighlightableButton.swift
//
//  Created by Amadeu Real on 11/10/2017.
//  Copyright © 2017 Impossible. All rights reserved.
//

import UIKit

class HighlightableButton: UIButton, isHighlightable {
  var animationHandler: isHighlightable.AnimationHandler?

  var isInsideFrame: Bool = false
  var pressDownDuration: TimeInterval { return 0.1 }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    isInsideFrame = true
    clickPressDown()
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    clickPressUp {
      if self.isInsideFrame {
        self.onClick()

        self.isInsideFrame = false
      }
    }

  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    isInsideFrame = false
    clickPressUp()
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)

      let movedInsideFrame = bounds.contains(location)

      if isInsideFrame != movedInsideFrame {
        if movedInsideFrame {
          clickPressDown()
        } else {
          clickPressUp()
        }
      }

      isInsideFrame = movedInsideFrame
    }
  }
}
