//
//  UIColor.swift
//  FlappyBird
//
//  Created by Pedro Saldanha on 12/07/2019.
//  Copyright © 2019 GreenSphereStudios. All rights reserved.
//

import UIKit
import Lottie

extension UIColor {
  public class var coolGreen: UIColor { return UIColor (hex: 0x00ffcc) }
  public class var darkBlue: UIColor { return UIColor(hex: 0x000f21) }
  public class var lightDarkBlue: UIColor { return UIColor(hex: 0x00486f) }
  public class var tetrisLightGrey: UIColor { return UIColor(hexString: "E4E7EA") }
  public class var tetrisLightBlueGrey: UIColor { return UIColor(hexString: "D4ECF5") }
  public class var tetrisText: UIColor { return UIColor(hexString: "CCE8F3") }
  public class var buttonColor: UIColor { return UIColor(hexString: "00FFD2") }
  public class var tetrisDarkBlue: UIColor { return UIColor(hexString: "000F21") }
  public class var tetrisBlue: UIColor { return UIColor(hexString: "00486F") }

  var redValue: CGFloat { return CIColor(color: self).red }
  var greenValue: CGFloat { return CIColor(color: self).green }
  var blueValue: CGFloat { return CIColor(color: self).blue }
  var alphaValue: CGFloat { return CIColor(color: self).alpha }

  convenience public init(hex: Int32) {
    //let alpha = CGFloat((hex & 0x000000) >> 24) / 255.0
    let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
    let blue = CGFloat((hex & 0xFF)) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: 1)
  }

  convenience init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt32()
    Scanner(string: hex).scanHexInt32(&int)
    let a, r, g, b: UInt32
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }

  public class var tetris_color_1: UIColor { return UIColor(hex: 0x28E4EB) }
  public class var tetris_color_2: UIColor { return UIColor(hex: 0x106DED) }
  public class var tetris_color_3: UIColor { return UIColor(hex: 0xBE5BFF) }
  public class var tetris_color_4: UIColor { return UIColor(hex: 0xFF44A6) }
  public class var tetris_color_5: UIColor { return UIColor(hex: 0x00B560) }
  public class var tetris_color_6: UIColor { return UIColor(hex: 0x7BBE2F) }
  public class var tetris_color_7: UIColor { return UIColor(hex: 0xE8D726) }

  func toColorLottie() -> Color {
    return Color(r: Double(self.redValue), g: Double(self.greenValue), b: Double(self.blueValue), a: 1)
  }
}
