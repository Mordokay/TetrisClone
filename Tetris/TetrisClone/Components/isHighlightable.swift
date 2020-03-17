//
//  isHighlightable.swift
//
//  Created by Amadeu Real on 11/10/2017.
//  Copyright © 2017 Impossible. All rights reserved.
//

import UIKit

//typealias AnimationHandler = (_ isPressingDown: Bool) -> Void

protocol isHighlightable {
  typealias AnimationHandler = (Bool) -> Void
  var lowestAlpha: CGFloat { get }
  var highestAlpha: CGFloat { get }
  var pressDownDuration: TimeInterval { get }
  var pressUpDuration: TimeInterval { get }
  var action: Action? { get }
  var isHighlightable: Bool { get }
  var shouldScale: Bool { get }
  var animationHandler: AnimationHandler? { get set }
}

extension isHighlightable where Self: UIView {

  var animationHandler: AnimationHandler? {
    return nil
  }

  var lowestAlpha: CGFloat {
    return 0.35
  }
  var highestAlpha: CGFloat {
    return 1
  }

  var isEnable: Bool {
    return true
  }
  var action: Action? {
    return nil
  }
  var pressUpDuration: TimeInterval {
    return 0.05
  }
  var pressDownDuration: TimeInterval {
    return 0.1
  }
  var shouldScale: Bool {
    return true
  }
  var isHighlightable: Bool {
    return true
  }

  func clickPressDown(_ invert: Bool = false, _ action: Action? = nil) {
    if !isEnable || !isHighlightable {
      return
    }

    animateAlphaElements(to: lowestAlpha) {
      if invert {
        self.clickPressUp(action)
      }
      action?()
    }

  }

  func clickPressUp(_ action: Action? = nil) {
    if !isEnable || !isHighlightable {
      return
    }

    animateAlphaElements(to: highestAlpha) {
      action?()
    }
  }

  func onClick() {
    if let button = self as? HighlightableButton, button.isInsideFrame {
      button.sendActions(for: .touchUpInside)
    }
  }

  private func animateAlphaElements(to alpha: CGFloat, _ completion: @escaping () -> Void) {
    var duration = pressDownDuration
    var options: UIView.AnimationOptions = [.curveLinear, .allowUserInteraction, .beginFromCurrentState]

    if alpha == highestAlpha {
      changeAlpha(alpha: lowestAlpha)
      duration = pressUpDuration
      options = [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut]
    }

    UIView.animate(withDuration: duration, delay: 0, options: options, animations: {

      self.changeAlpha(alpha: alpha)

    }, completion: {(_) in
      completion()
    })
  }

  func changeAlpha(alpha: CGFloat) {
    guard animationHandler == nil else {
      animationHandler?(alpha != 1)
      return
    }
    self.alpha = alpha

    if shouldScale {
      transform = .init(scaleX: alpha == 1 ? 1 : 0.95, y: alpha == 1 ? 1 : 0.95)
    }
  }

}
