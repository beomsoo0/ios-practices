//
//  Extension.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import Foundation

extension String {
    public func safetyEmail() -> String {
        return self.replacingOccurrences(of: "@", with: "=").replacingOccurrences(of: ".", with: "-")
    }
    public func restoreEmail() -> String {
        return self.replacingOccurrences(of: "=", with: "@").replacingOccurrences(of: "-", with: ".")
    }
}
