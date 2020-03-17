//
//  PaddingLabel.swift
//
//  Created by rrocha on 6/2/17.
//  Copyright © 2017 Impossible. All rights reserved.
//

import UIKit
import TTTAttributedLabel

@IBDesignable
class PaddingLabel: TTTAttributedLabel {

  @IBInspectable var topInset: CGFloat = 5.0
  @IBInspectable var bottomInset: CGFloat = 5.0
  @IBInspectable var leftInset: CGFloat = 17.0
  @IBInspectable var rightInset: CGFloat = 17.0

  convenience init(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
    self.init()
    topInset = top
    bottomInset = bottom
    leftInset = left
    rightInset = right
  }

  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset,
                  height: size.height + topInset + bottomInset)
  }
}
