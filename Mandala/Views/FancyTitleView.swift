import SwiftUI

struct FancyTitleView: View {
    // Define pastel colors
    private let pastelColors = [
        Color(red: 0.95, green: 0.8, blue: 0.9),  // Pastel pink
        Color(red: 0.8, green: 0.9, blue: 0.95),  // Pastel blue
        Color(red: 0.95, green: 0.8, blue: 0.9)   // Pastel pink
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Decorative line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: pastelColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, 40)
            
            // Title text
            Text("Mandal")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: pastelColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: pastelColors[0].opacity(0.3), radius: 5, x: 0, y: 2)
            
            Text("ART")
                .font(.system(size: 45, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: pastelColors.reversed()),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: pastelColors[0].opacity(0.3), radius: 5, x: 0, y: 2)
                .offset(y: -10)
            
            // Decorative line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: pastelColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, 40)
            
            // Subtitle
            Text("Create Your Unique Wallpaper")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .padding(.top, 5)
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    FancyTitleView()
        .preferredColorScheme(.dark)
} 