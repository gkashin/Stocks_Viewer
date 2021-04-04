//
//  UIViewController+Extension.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 04.04.2021.
//

import UIKit

// MARK: - Alerts
extension UIViewController {
    func showAlert(error: NetworkError, actions: @escaping () -> ()) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
            let action = UIAlertAction(title: error.actionTitle, style: .default) { _ in
                actions()
            }

            alertController.addAction(action)
            
            self?.present(alertController, animated: true)
        }
    }
}
