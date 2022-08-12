//
//  Model.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//
import UIKit
import Foundation
import RxSwift
import KakaoSDKStory
import NMapsMap

class User {
    var uid: String
    var token: String?
    
    var img: UIImage?                   // 둘 중에 하나 보유 (Upload시 이미지,  Fetching시 URL)
    var imgURL: URL?
    
    var name: String
    var birth: String
    var gender: String
    
    var chatRooms: [ChatRoom] = []      // ChatVC에서 Fetching
    var curPosition: String?            // NearVC에서 Fetching
    var postPuids: [String] = []
    var promisePuids: [String] = []
    
    var age: String {
        return birth.birthToAge()
    }
  
    
    init() {
        self.uid = "Default"
        self.name = "Default"
        self.birth = "Default"
        self.gender = "Default"
    }
    
    init(img: UIImage?, imgURL: URL?, uid: String, name: String, birth: String, gender: String) {
        self.img = img
        self.imgURL = imgURL
        self.uid = uid
        self.img = img
        self.name = name
        self.birth = birth
        self.gender = gender
    }
    
}

class Post {
    var puid: String
    
    var uid: String
    var user: User?
    
    var img: UIImage?           // 둘 중에 하나 보유 (Upload시 이미지,  Fetching시 URL)
    var imgURL: URL?
    
    
    var content: String
    var postDate: String
    
    var place: String
    var promiseDate: String
    var position: String
    var distance: Double?       // HomeVC에서 Sorting시 Fetching
    
    var foodCategory: String
    var promise: Promise
   
    
    
    var postDate_relative: String {
        return postDate.strToDate().relativeTime
    }
    var promiseDate_relative: String {
        return promiseDate.strToDate().relativeTime
    }
    
    
    init() {
        self.puid = "Default"
        self.place = "Default"
        self.content = "Default"
        self.promiseDate = "Default"
        self.uid = "Default"
        self.position = "Default"
        self.postDate = "Defatult"
        self.promise = Promise(hostUid: "Default", maxPeople: -1)
        self.foodCategory = "Default"
    }
    
    init(puid: String, img: UIImage?, imgURL: URL?, place: String, content: String, date: String, uid: String, position: String, postDate: String, promise: Promise, foodCategory: String) {
        self.puid = puid
        self.img = img
        self.imgURL = imgURL
        self.place = place
        self.content = content
        self.promiseDate = date
        self.uid = uid
        self.position = position
        self.postDate = postDate
        self.promise = promise
        self.foodCategory = foodCategory
    }

    func calDistance(curUserPos: String) -> Double {
        let cur = curUserPos.components(separatedBy: "-").map { Double($0) ?? 0.0 }
        let curLatLng = NMGLatLng(lat: cur[0], lng: cur[1])
        
        let post = self.position.components(separatedBy: "-").map { Double($0) ?? 0.0 }
        let postLatLng = NMGLatLng(lat: post[0], lng: post[1])
        
        return curLatLng.distance(to: postLatLng) / 1000
    }
    
}


struct Message {
    var msgUid: String
    var toUid: String
    var fromUid: String
    var content: String
    var date: String
    
    var date_relative: String {
        return date.msgStrToDate().relativeTime
    }
    
    var date_hour_minute: String {
        let dateArr = self.date.components(separatedBy: "-")
//        let year = dateArr[0]
//        let mouth = dateArr[1]
//        let day = dateArr[2]
        let hour = dateArr[3]
        let minute = dateArr[4]
        
        return "\(hour)시 \(minute)분"
    }
    
    
    
    init() {
        self.msgUid = ""
        self.toUid = ""
        self.fromUid = ""
        self.content = ""
        self.date = ""
    }
    
    init(msgUid: String, toUid: String, fromUid: String, content: String, date: String) {
        self.msgUid = msgUid
        self.toUid = toUid
        self.fromUid = fromUid
        self.content = content
        self.date = date
    }
}

class ChatRoom {
    var uid: String
    var user: User?
    var messages: [Message] = [] //채팅방 안에서만 보유
    var lastMsg: Message?
    
    init() {
        self.uid = "Default"
        self.lastMsg = Message(msgUid: "", toUid: "", fromUid: "", content: "", date: "")
    }
    
    init(uid: String, lastMessage: Message?) {
        self.uid = uid
        self.lastMsg = lastMessage
    }
    
}

struct Promise {
    var hostUid: String
    var peoples: [String: String] = [:]
    var users: [User] = []
    var maxPeople: Int
    
    
    
    
    var curNum: Int {
        return peoples.count + 1
    }

    init(hostUid: String, maxPeople: Int) {
        self.hostUid = hostUid
        self.maxPeople = maxPeople
    }
}

struct FoodCategory {
    var name: String
    var image: UIImage
}

class MapPost {
    var puid: String
    var latLng: NMGLatLng
    init(puid: String, latLng: NMGLatLng) {
        self.puid = puid
        self.latLng = latLng
    }
}
