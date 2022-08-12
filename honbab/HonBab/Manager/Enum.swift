//
//  Enum.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/13.
//

import Foundation

// User In HomeVC, SortVC
enum SortingType: Int {
    case postDate = 0
    case promiseDate = 1
    case distance = 2
    
    func sortTypeToDBChildStr() -> String {
        switch self {
        case .postDate:
            return "postDate"
        case .promiseDate:
            return "date"
        case .distance:
            return "position"
        }
    }
}

// User In ProfileVC
enum ProfilePostType {
    case myPost
    case promise
    case like
}
