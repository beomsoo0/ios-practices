//
//  StopWatch.swift
//  StopWatch
//
//  Created by 김범수 on 2021/08/19.
//

import Foundation

class StopWatch: NSObject{
    var counter: Double
    var timer: Timer
    
    override init() {
        counter = 0.0
        timer = Timer()
    }
}
