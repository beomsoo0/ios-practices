//
//  Extension.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/26.
//

import Foundation
import UIKit
import NMapsMap

extension String {
    public func safetyEmail() -> String {
        return self.replacingOccurrences(of: "@", with: "=").replacingOccurrences(of: ".", with: "-")
    }
    public func restoreEmail() -> String {
        return self.replacingOccurrences(of: "=", with: "@").replacingOccurrences(of: "-", with: ".")
    }
    public func birthToAge() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        let curYear = Int(dateStr.components(separatedBy: "-")[0]) ?? 0
        
        let birthYear = Int(self.components(separatedBy: "-")[0]) ?? 0
        return "\(String(curYear - birthYear + 1))살"
    }
    public func promiseDay() -> String {
        let dateArr = self.components(separatedBy: "-")
        let year = dateArr[0]
        let mouth = dateArr[1]
        let day = dateArr[2]
        let hour = dateArr[3]
        let minute = dateArr[4]
        
        return " \(year)년 \(mouth)월 \(day)일 \(hour)시 \(minute)분"
    }
    
    public func strToDate() -> Date {
        let dateIntArr = self.components(separatedBy: "-").map { Int($0)! }
        
        let dateComponents = DateComponents(year: dateIntArr[0], month: dateIntArr[1], day: dateIntArr[2], hour: dateIntArr[3], minute: dateIntArr[4])
        let date = Calendar.current.date(from: dateComponents)
        return date!
    }

    public func msgStrToDate() -> Date {
        let dateIntArr = self.components(separatedBy: "-").map { Int($0)! }
        
        let dateComponents = DateComponents(year: dateIntArr[0], month: dateIntArr[1], day: dateIntArr[2], hour: dateIntArr[3], minute: dateIntArr[4], second: dateIntArr[5])
        let date = Calendar.current.date(from: dateComponents)
        return date!
    }
    
    public func posToDistance(curPos: String) -> Double{
        let cur = curPos.components(separatedBy: "-").map { Double($0)! }
        let curLatLng = NMGLatLng(lat: cur[0], lng: cur[1])
        
        let post = self.components(separatedBy: "-").map { Double($0)! }
        let postLatLng = NMGLatLng(lat: post[0], lng: post[1])
        
        return curLatLng.distance(to: postLatLng) / 1000
    }
    

}
extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size)) 
        }
        return renderImage
    }
    
}

extension Date {
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func dateToStr(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateStr = dateFormatter.string(from: self)
        return dateStr
    }
    
    
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
}
