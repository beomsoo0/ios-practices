//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

struct User {
    var id: String
    var name: String
    var follower: Int
    var follow: Int
    var content: [Content]
}

public struct Content {
    var image: UIImage
    var comment: String
    
    init(image: UIImage, comment: String) {
        self.image = image
        self.comment = comment
    }
}
