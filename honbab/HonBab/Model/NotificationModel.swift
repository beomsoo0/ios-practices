//
//  NotificationModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/13.
//

import ObjectMapper
import Alamofire

class NotificationModel: Mappable {
    
    let url = "https://fcm.googleapis.com/fcm/send"
    
    let header: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "key=AAAA7IFJFUU:APA91bEMV23DofO-9xVxrNExjaEXswzOePMVV2OY9tNkPe9AQbDnArLLG2N1g8E6bp3wOGYooCAjE_lZJk_4yiLj9gCjZN3_Ai-gVX6y8OfGMX72hBLcXVSnMtWrGIRiInvBsyfLq5Gc"
    ]
    
    var to: String?
    var notification: Notification = Notification()
    var data: DataModel = DataModel() // For Foreground
    init() {
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
        data <- map["data"]
    }
    
    class Notification: Mappable{
        var title: String?
        var text: String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
        }
    }
    
    // For Foreground
    class DataModel: Mappable {
        var title: String?
        var text: String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
        }
    }
    
}
