//
//  Product.swift
//  GoodAsOldPhones
//
//  Created by 김범수 on 2021/08/18.
//

import Foundation

struct Product {
    var name: String
    var cellImageName: String
    var fullscreenImageName: String
    
    init(name: String, cellImageName: String, fullscreenImageName: String) {
        self.name = name
        self.cellImageName = cellImageName
        self.fullscreenImageName = fullscreenImageName
    }
}
