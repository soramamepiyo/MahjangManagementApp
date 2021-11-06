//
//  UIAlert-Extension.swift
//  MahjangManagementApp
//
//  Created by 中西空 on 2021/10/30.
//

import UIKit

extension UIAlertController {
    static func noButtonAlert(title: String?, message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    static func okAlert(title: String?,
                        message: String?,
                        okHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: okHandler))
        return alert
    }

    static func errorAlert(title: String? = "⚠️",
                           errorMsg: String,
                           okHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: errorMsg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: okHandler))
        return alert
    }

    static func fieldAlert(title: String?,
                           message: String?,
                           placeholder: String?,
                           handler: ((String?) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = placeholder
        }
        alert.addAction(.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            handler?(alert.textFields?.first?.text)
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { (action) in
            handler?(nil)
        }))
        return alert
    }
}

extension UIViewController {
    func present(_ alert: UIAlertController, completion: (() -> Void)? = nil) {
        present(alert, animated: true, completion: completion)
    }

    func present(_ alert: UIAlertController, _ autoDismissInterval: TimeInterval, completion: (() -> Void)? = nil) {
        present(alert, animated: true, completion: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissInterval) {
                self?.dismiss(animated: true, completion: completion)
            }
        })
    }
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
