//
//  UIControl.swift
//  iOSTests
//
//  Created by Danil Lahtin on 15.03.2020.
//

import UIKit

extension UIControl {
    func trigger(event: UIControl.Event) {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: event)?.forEach({ action in
                let target = target as NSObject
                target.perform(Selector(action), with: target)
            })
        })
    }
}

extension UIButton {
    func triggerTap() {
        trigger(event: .touchUpInside)
    }
}
