//
//  UIFont.swift
//  FlappyBird
//
//  Created by Pedro Saldanha on 13/07/2019.
//  Copyright © 2019 GreenSphereStudios. All rights reserved.
//

import UIKit

extension UIFont {
  private static func tetrisFont(ofSize size: CGFloat, isBold: Bool = false, isItalic: Bool = false) -> UIFont {
    if isBold {
      return UIFont.boldSystemFont(ofSize: size)
    } else if isItalic {
      return UIFont.italicSystemFont(ofSize: size)
    }

    return UIFont.systemFont(ofSize: size)
  }

//  public static var tetris10: UIFont { return tetrisFont(ofSize: 10) }
//  public static var tetris10Dynamic: UIFont { return tetrisFont(ofSize: CGSize.relativeWidth(10)) }
  public static var tetris15DynamicBold: UIFont { return tetrisFont(ofSize: CGSize.relativeWidth(15), isBold: true) }
  public static var tetris20DynamicBold: UIFont { return tetrisFont(ofSize: CGSize.relativeWidth(20), isBold: true) }
  public static var tetris24DynamicBold: UIFont { return tetrisFont(ofSize: CGSize.relativeWidth(24), isBold: true) }
  public static var tetris28DynamicBold: UIFont { return tetrisFont(ofSize: CGSize.relativeWidth(28), isBold: true) }
  public static var tetris50DynamicBold: UIFont { return tetrisFont(ofSize: CGSize.relativeWidth(50), isBold: true) }
  
}

