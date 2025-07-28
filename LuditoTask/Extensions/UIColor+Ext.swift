//
//  UIColor+Ext.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 24/07/25.
//

import UIKit

extension UIColor {
    
    static let searchBackColor = UIColor.init(hex: "#E0E0E0")
    static let separatorViewColor = UIColor.init(hex: "#F1F1F1")
    static let addressTitleColor = UIColor.init(hex: "#B0ABAB")
    static let grayBorderClor = UIColor.init(hex: "#F1F1F1")
    static let dragGrayColor = UIColor.init(hex: "#D0CFCF")
    static let greenButtonColor = UIColor.init(hex: "#5BC250")
    
    class func short(red: Int, green: Int, blue: Int, alpha: Double = 1) -> UIColor {
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        let a = CGFloat(alpha)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    convenience init(hex hexFromString: String, alpha: CGFloat = 1.0) {
        var cString: String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue: UInt32 = 10066329 //color #999999 if string has wrong format
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count == 6 {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
