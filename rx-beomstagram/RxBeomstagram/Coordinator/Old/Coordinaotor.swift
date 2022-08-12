//
//  Coordinaotor.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/08.
//

import Foundation

protocol ViewControllerHandler: AnyObject {
    func click(event: Event)
    func tabbarIndex(index: Int)
}

enum Event {
    case push
    case pop
    case present
    case dismiss
}

protocol Coordinator {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
    
}
