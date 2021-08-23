//
//  Extension.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

extension String {
    public func safetyEmail() -> String {
        return self.replacingOccurrences(of: "@", with: "=").replacingOccurrences(of: ".", with: "-")
    }
    public func restoreEmail() -> String {
        return self.replacingOccurrences(of: "=", with: "@").replacingOccurrences(of: "-", with: ".")
    }
}

extension UIViewController {
    
    func presentModalVC(vcName: String) {
        DispatchQueue.main.async {
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: vcName) else { return }
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: true, completion: nil)
        }
    }

    
    func alertMessage(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func resignKeyBoard(_ textFields: UITextField...) {
        for textField in textFields {
            textField.text?.removeAll()
            textField.resignFirstResponder()
        }
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
}
