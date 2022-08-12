//
//  TrasitionModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation

enum TransitionStyle {
    
    case root, modal, push
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}

