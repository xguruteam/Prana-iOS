//
//  UIViewController+Orientation.swift
//  ClubRow
//
//  Created by Guru on 7/25/19.
//  Copyright © 2019 CREATORSNEVERDIE. All rights reserved.
//

import UIKit

struct OrientationLock {
  static var lock: UIInterfaceOrientationMask = .portrait
}

extension AppDelegate {
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return OrientationLock.lock
  }
}

extension UIViewController {
  
  func present(_ viewControllerToPresent: UIViewController, as orientationMask: UIInterfaceOrientationMask, curtainColor: UIColor = .black) {
    let landscapeViewController = OrientationLockController(rootViewController: viewControllerToPresent, targetOrientationMask: orientationMask)
    let curtainViewController = CurtainViewController(rootViewController: landscapeViewController)
    curtainViewController.view.backgroundColor = curtainColor
    curtainViewController.modalPresentationStyle = .fullScreen
    present(curtainViewController, animated: true, completion: nil)
  }
  
  func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
    OrientationLock.lock = orientation
  }
  
  func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
    self.lockOrientation(orientation)
    UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    UINavigationController.attemptRotationToDeviceOrientation()
  }
  
}

class OrientationLockController: UIViewController {
  
  var isFirstAppeared = true
  var rootViewController: UIViewController
  var targetOrientationMask: UIInterfaceOrientationMask
  var originalOrientationMask: UIInterfaceOrientationMask = .portrait
  
  init(rootViewController: UIViewController, targetOrientationMask: UIInterfaceOrientationMask) {
    self.rootViewController = rootViewController
    self.targetOrientationMask = targetOrientationMask
    self.originalOrientationMask = OrientationLock.lock
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    lockOrientation(targetOrientationMask, andRotateTo: orientation(mask: targetOrientationMask))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isFirstAppeared {
        rootViewController.modalPresentationStyle = .fullScreen
      self.present(rootViewController, animated: false, completion: nil)
      isFirstAppeared = false
    } else {
      lockOrientation(originalOrientationMask, andRotateTo: orientation(mask: originalOrientationMask))
      self.dismiss(animated: false, completion: nil)
    }
  }
  
  func orientation(mask: UIInterfaceOrientationMask) -> UIInterfaceOrientation {
    switch mask {
    case UIInterfaceOrientationMask.portrait:
      return UIInterfaceOrientation.portrait
    case UIInterfaceOrientationMask.landscapeLeft:
      return UIInterfaceOrientation.landscapeLeft
    case UIInterfaceOrientationMask.landscapeRight:
      return UIInterfaceOrientation.landscapeRight
    default:
      return UIInterfaceOrientation.unknown
    }
  }
}

class CurtainViewController: UIViewController {
  
  var isFirstAppeared = true
  var rootViewController: UIViewController
  
  init(rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isFirstAppeared {
        rootViewController.modalPresentationStyle = .fullScreen
      present(rootViewController, animated: false, completion: nil)
      isFirstAppeared = false
    } else {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
}
