//
//  UIView.swift
//  FlappyBird
//
//  Created by Pedro Saldanha on 12/07/2019.
//  Copyright © 2019 GreenSphereStudios. All rights reserved.
//

import UIKit

extension UIView {
  func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
    let border = UIView()
    border.backgroundColor = color
    border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
    addSubview(border)
  }
  
  func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
    let border = UIView()
    border.backgroundColor = color
    border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
    addSubview(border)
  }
  
  var currentWindowSize: CGSize {
    return  UIApplication.shared.keyWindow?.bounds.size ?? UIWindow().bounds.size
  }
  func relativeWidth(_ width: CGFloat) -> CGFloat {
    return currentWindowSize.width * (width / 414)
  }
  func relativeHeight(_ height: CGFloat) -> CGFloat {
    return currentWindowSize.height * (height / 896)
  }
  
  func pin(into view: UIView, safeMargin: Bool = true, padding: CGFloat = 0) {
    if !view.subviews.contains(self) { view.addSubview(self) }
    translatesAutoresizingMaskIntoConstraints = false
    if safeMargin {
      let margin = view.layoutMarginsGuide
      NSLayoutConstraint.activate([
        leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: padding),
        trailingAnchor.constraint(equalTo: margin.trailingAnchor, constant: -padding),
        topAnchor.constraint(equalTo: margin.topAnchor, constant: padding),
        bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -padding)
      ])
    } else {
      NSLayoutConstraint.activate([
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding)
      ])
    }
  }
  
  func removeAllSubLayers() {
    layer.sublayers?.forEach() {
      $0.removeFromSuperlayer()
    }
  }

  func setAutoLayoutGradient(colorTop: UIColor, colorBottom: UIColor) {
    removeAllSubLayers()
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
    gradientLayer.frame = self.bounds
    
    self.layer.insertSublayer(gradientLayer, at: 0)
  }

  
  func setVerticalGradient(startColor: UIColor, endColor: UIColor) {
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.frame.size = self.frame.size
    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    self.layer.addSublayer(gradientLayer)
  }
  
  func setTripleHorizontalGradient(startColor: UIColor, middleColor: UIColor, endColor: UIColor) {
    removeAllSubLayers()
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.frame.size = self.frame.size
    gradientLayer.colors = [startColor.cgColor, middleColor.cgColor, endColor.cgColor]
    gradientLayer.locations = [0.0, 0.5, 1.0]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    self.layer.addSublayer(gradientLayer)
  }
  
  func setDiagonalGradient(startColor: UIColor, endColor: UIColor) {
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.frame.size = self.frame.size
    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    self.layer.addSublayer(gradientLayer)
  }
}
