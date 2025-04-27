import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

enum PaletteType: String, CaseIterable, Codable {
    case vibrant, pastel, customImage, customManual
}

class WallpaperViewModel: ObservableObject {
    @Published var wallpapers: [Wallpaper] = []
    @Published var selectedResolution: CGSize = CGSize(width: 1242, height: 2688) // iPhone XS Max
    @Published var selectedPattern: String = "Mandala"
    @Published var selectedColors: [Color] = [
        Color(red: 0.95, green: 0.8, blue: 0.9),  // Pastel pink
        Color(red: 0.8, green: 0.9, blue: 0.95),  // Pastel blue
        Color(red: 0.9, green: 0.95, blue: 0.8)   // Pastel green
    ]
    @Published var paletteType: PaletteType = .vibrant
    @Published var customPalette: [Color] = []
    @Published var imagePalette: [Color] = []
    
    private let vibrantPalette: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan,
        Color(red: 0.9, green: 0.3, blue: 0.4),
        Color(red: 0.2, green: 0.7, blue: 0.9),
        Color(red: 0.8, green: 0.6, blue: 0.2),
        Color(red: 0.3, green: 0.9, blue: 0.5)
    ]
    private let pastelPalette: [Color] = [
        Color(red: 0.98, green: 0.82, blue: 0.89),
        Color(red: 0.8, green: 0.9, blue: 0.95),
        Color(red: 0.95, green: 0.95, blue: 0.8),
        Color(red: 0.9, green: 0.8, blue: 0.95),
        Color(red: 0.8, green: 0.95, blue: 0.85),
        Color(red: 0.95, green: 0.9, blue: 0.8),
        Color(red: 0.85, green: 0.8, blue: 0.95),
        Color(red: 0.8, green: 0.85, blue: 0.95)
    ]
    
    private let context = CIContext()
    
    init() {
        loadWallpapers()
    }
    
    func setImagePalette(from colors: [Color]) {
        imagePalette = colors
    }
    
    func generateWallpaper() {
        let patternType = MandalaPattern.PatternType(rawValue: selectedPattern) ?? .mandala
        let palette = getCurrentPalette().shuffled()
        let image = MandalaPattern.generatePattern(
            type: patternType,
            size: selectedResolution,
            colors: palette
        )
        
        if let imageData = image.pngData() {
            let wallpaper = Wallpaper(
                imageData: imageData,
                colors: palette,
                pattern: selectedPattern,
                resolution: selectedResolution
            )
            wallpapers.append(wallpaper)
            saveWallpapers()
        }
    }
    
    func regenerateWallpaper(_ wallpaper: Wallpaper) {
        if let index = wallpapers.firstIndex(where: { $0.id == wallpaper.id }) {
            let patternType = MandalaPattern.PatternType(rawValue: wallpaper.pattern) ?? .mandala
            let palette = wallpaper.colors.shuffled()
            let image = MandalaPattern.generatePattern(
                type: patternType,
                size: wallpaper.resolution,
                colors: palette
            )
            
            if let imageData = image.pngData() {
                let newWallpaper = Wallpaper(
                    id: wallpaper.id,
                    imageData: imageData,
                    colors: palette,
                    pattern: wallpaper.pattern,
                    resolution: wallpaper.resolution,
                    createdAt: wallpaper.createdAt
                )
                wallpapers[index] = newWallpaper
                saveWallpapers()
            }
        }
    }
    
    func getCurrentPalette() -> [Color] {
        switch paletteType {
        case .vibrant:
            return vibrantPalette
        case .pastel:
            return pastelPalette
        case .customImage:
            return imagePalette.isEmpty ? vibrantPalette : imagePalette
        case .customManual:
            return customPalette.isEmpty ? selectedColors : customPalette
        }
    }
    
    func deleteWallpaper(_ wallpaper: Wallpaper) {
        wallpapers.removeAll { $0.id == wallpaper.id }
        saveWallpapers()
    }
    
    func clearAllWallpapers() {
        wallpapers.removeAll()
        saveWallpapers()
    }
    
    private func saveWallpapers() {
        if let encoded = try? JSONEncoder().encode(wallpapers) {
            UserDefaults.standard.set(encoded, forKey: "savedWallpapers")
        }
    }
    
    private func loadWallpapers() {
        if let data = UserDefaults.standard.data(forKey: "savedWallpapers"),
           let decoded = try? JSONDecoder().decode([Wallpaper].self, from: data) {
            wallpapers = decoded
        }
    }
} 