//
//  UIViewController.swift
//  FlappyBird
//
//  Created by Pedro Saldanha on 12/07/2019.
//  Copyright © 2019 GreenSphereStudios. All rights reserved.
//

import UIKit

extension UIViewController {
  var currentWindowSize: CGSize {
    return  UIApplication.shared.keyWindow?.bounds.size ?? UIWindow().bounds.size
  }
  func relativeWidth(_ width: CGFloat) -> CGFloat {
    return currentWindowSize.width * (width / 414)
  }
  func relativeHeight(_ height: CGFloat) -> CGFloat {
    return currentWindowSize.height * (height / 896)
  }
}
