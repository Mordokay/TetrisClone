//
//  UINavigationController+Extension.swift
//
//  Created by kwamecorp on 13/12/2019.
//  Copyright © 2019 Impossible. All rights reserved.
//

import UIKit

extension UINavigationController {
  func fadeTo(_ viewController: UIViewController, navBarHidden: Bool) {
    let transition: CATransition = CATransition()
    transition.duration = 0.3
    transition.type = CATransitionType.fade
    view.layer.add(transition, forKey: nil)
    self.setNavigationBarHidden(navBarHidden, animated: false)
    pushViewController(viewController, animated: false)
  }

  func popFade(navBarHidden: Bool) {
    let transition: CATransition = CATransition()
    transition.duration = 0.3
    transition.type = CATransitionType.fade
    view.layer.add(transition, forKey: nil)
    self.setNavigationBarHidden(navBarHidden, animated: false)
    popViewController(animated: false)
  }

  func popFadeToViewController(ofClass: AnyClass, navBarHidden: Bool) {
    if let vc = viewControllers.filter({ $0.isKind(of: ofClass) }).last {
      let transition: CATransition = CATransition()
      transition.duration = 0.3
      transition.type = CATransitionType.fade
      view.layer.add(transition, forKey: nil)

      self.setNavigationBarHidden(navBarHidden, animated: false)
      popToViewController(vc, animated: false)
    }
  }

  func popToViewController(ofClass: AnyClass, animated: Bool = true, navBarHidden: Bool = false) {
    if let vc = viewControllers.filter({ $0.isKind(of: ofClass) }).last {
      self.setNavigationBarHidden(navBarHidden, animated: false)
      popToViewController(vc, animated: animated)
    }
  }

  func hasViewControllerOfType(ofClass: AnyClass) -> Bool {
    return viewControllers.filter({ $0.isKind(of: ofClass) }).count > 0
  }
}
