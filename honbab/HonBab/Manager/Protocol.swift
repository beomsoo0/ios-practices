//
//  Protocol.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/13.
//

import Foundation
import RxSwift
import RxCocoa

// Use In HomeVC, NearVC, ProfileVC for Fetching In PostVC
protocol PostsHasViewModel: NSObject {
    var postsSubject: BehaviorSubject<[Post]> { get set }
}

// Use In AddPostVC for Fetching In AddImgVC
protocol ImgHasViewModel: NSObject {
    var imgRelay: BehaviorRelay<UIImage> { get set }
}
