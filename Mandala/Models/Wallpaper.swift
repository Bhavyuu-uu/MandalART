import Foundation
import SwiftUI

struct Wallpaper: Identifiable, Codable {
    let id: UUID
    let imageData: Data
    let colors: [Color]
    let pattern: String
    let resolution: CGSize
    let createdAt: Date
    
    init(id: UUID = UUID(), imageData: Data, colors: [Color], pattern: String, resolution: CGSize, createdAt: Date = Date()) {
        self.id = id
        self.imageData = imageData
        self.colors = colors
        self.pattern = pattern
        self.resolution = resolution
        self.createdAt = createdAt
    }
}

// Extension to make Color codable
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(opacity, forKey: .opacity)
    }
} 