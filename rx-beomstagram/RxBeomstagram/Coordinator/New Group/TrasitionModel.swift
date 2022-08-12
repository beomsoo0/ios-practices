//
//  TrasitionModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/10.
//

import Foundation

enum TransitionStyle {
    case root
    case push
    case modal
}

enum TransitionError: Error {
    case navigationControllerMissing
    
}
