import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF,
                  green: (hex >> 8) & 0xFF,
                  blue: hex & 0xFF)
    }
    
    static let borderGrey = UIColor(red: 130, green: 130, blue: 130)
    
    static let backgroundGrey = UIColor(red: 33, green: 33, blue: 33)
    
    static let sectionGrey = UIColor(hex: 0x404040)
    
    static let kindOfWhite = UIColor(red: 205, green: 205, blue: 205)
    
    static let kindOfOrange = UIColor(red: 252, green: 208, blue: 82)
}

enum FontWeight: String {
    case regular = "HelveticaNeue"
    case bold = "HelveticaNeue-Bold"
}

enum FontSize: CGFloat {
    case big = 16
    case standard = 14
    case small = 12
    case tiny = 6
}

enum FontColor {
    case white
    case orange
    case black
    
    var uiColor: UIColor {
        switch self {
        case .white:
            return .kindOfWhite
        case .orange:
            return .kindOfOrange
        case .black:
            return .black
        }
    }
}

extension UIFont {
    class func defaultFont(size: CGFloat, weight: FontWeight) -> UIFont {
        return UIFont(name: weight.rawValue, size: size)!
    }
}

extension UIFont {
    class func defaultFont(size: FontSize, weight: FontWeight) -> UIFont {
        return UIFont.defaultFont(size: size.rawValue, weight: weight)
    }
}

extension UILabel {
    func applyStyle(_ fontColor: FontColor, _ fontSize: FontSize, _ fontWeight: FontWeight = .regular) {
        font = UIFont.defaultFont(size: fontSize, weight: fontWeight)
        textColor = fontColor.uiColor
    }
}
