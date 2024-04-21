//
//  Extensions.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 14.03.2024.
//

import Foundation
import UIKit


extension UIColor {
    static var styledOrange: UIColor {
        return UIColor(red: 255/255, green: 122/255, blue: 48/255, alpha: 1.0)
    }
    
    static var styledGreen: UIColor {
        return UIColor(red: 7/255, green: 99/255, blue: 93/255, alpha: 1.0)
    }
    static var styledTabbarSelectedColor: UIColor {
        return UIColor(red: 3/255, green: 53/255, blue: 50/255, alpha: 1.0)
    }
    static var styledTabbarUnselectedColor: UIColor {
        return UIColor(red: 9/255, green: 137/255, blue: 128/255, alpha: 1.0)
    }
    
    static var styledLightGray: UIColor {
        return UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1.0)
    }
    static var styledDarkGray: UIColor {
        return UIColor(red: 105/255, green: 103/255, blue: 103/255, alpha: 1.0)
    }
 
    static var styledErrorRed: UIColor {
        return UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1.0)
    }
    static var styledWhite: UIColor {
        return UIColor(red: 254/255, green: 251/255, blue: 246/255, alpha: 1.0)
    }
}

extension UIFont{
    
    static func styledHeavyFont(size: CGFloat) -> UIFont {
         return UIFont(name: "Avenir-Heavy", size: size) ?? UIFont.systemFont(ofSize: size)
     }
    static func styledLightFont(size: CGFloat) -> UIFont {
         return UIFont(name: "Avenir-Light", size: size) ?? UIFont.systemFont(ofSize: size)
     }
    
}
//extension UITextField {
//
//    func underline() {
//        let borderWidth = CGFloat(1.0)
//        let endBorderHeight = CGFloat(10.0)
//
//        let bottom = CALayer()
//        bottom.frame = CGRect(
//            x: 1,
//            y: self.frame.height - borderWidth,
//            width: self.frame.width - 2,
//            height: borderWidth)
//
//        bottom.borderWidth = borderWidth
//        bottom.borderColor = UIColor.lightGray.cgColor
//
//
//        self.layer.addSublayer(bottom)
//        }
//
//
//
//}
