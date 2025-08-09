import UIKit

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let hex: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255)
        
        if a < 1.0 {
            let alphaHex = (Int)(a * 255) << 24
            return String(format: "#%08x", alphaHex | hex)
        }
        
        return String(format: "#%06x", hex)
    }
    
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
                          .replacingOccurrences(of: "#", with: "")
        
        guard
            hex.count == 6 || hex.count == 8,
            let hexNumber = UInt64(hex, radix: 16)
        else { return nil }
        
        let a = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
        let r = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
        let b = hex.count == 8 ? CGFloat(hexNumber & 0x000000FF) / 255 : 1.0
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
