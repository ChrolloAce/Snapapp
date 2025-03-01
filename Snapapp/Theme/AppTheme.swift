import SwiftUI

/// Centralized theme management for the app
enum AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color(hex: "9747FF")    // Main purple accent
        static let secondary = Color(hex: "00B4D8")  // Blue accent
        static let accent = Color(hex: "00B4D8")     // Blue accent (for backward compatibility)
        
        // Accent Colors
        static let success = Color(hex: "4ECB71")    // Green
        static let warning = Color(hex: "FF6B6B")    // Red
        static let danger = Color(hex: "FF3B30")     // Error red
        static let purple = Color(hex: "9747FF")     // Purple accent
        
        // Add new accent colors
        static let accentBlue = Color(hex: "00B4D8")
        static let accentBlueDark = Color(hex: "0096C7")
        
        // Add gradient colors
        static let backgroundStart = Color(hex: "070B1A")
        static let backgroundEnd = Color(hex: "161838")
        
        // Background Gradient
        static let background = LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "070B1A"),  // Dark blue-black at top
                Color(hex: "060812"),  // Fading to darker
                Color(hex: "05060D"),  // Very dark with slight blue
                Color(hex: "040406")   // Pure dark at bottom
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Surface Colors
        static let surface = Color(hex: "0D0E20")    // Darker navy surface color
        static let surfaceGradient = LinearGradient(
            colors: [
                surface.opacity(0.7),
                surface.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Text Colors
        static let text = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        
        // Timer Colors
        static let timerText = Color.white
        static let timerSecondary = Color.white.opacity(0.7)
        static let timerAccent = Color(hex: "9747FF")
        static let timerBackground = Color(hex: "161838")
    }
    
    // MARK: - Glass Effect
    struct Glass {
        static func surface(_ color: Color = Colors.surface) -> some View {
            ZStack {
                color.opacity(0.7)
                
                LinearGradient(
                    colors: [
                        .white.opacity(0.1),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        static func border(_ color: Color = .white) -> some ViewModifier {
            GlassBorderModifier(color: color)
        }
        
        static func glow(_ color: Color) -> some View {
            color.opacity(0.2)
                .blur(radius: 20)
                .opacity(0.8)
        }
    }
    
    // MARK: - Card Styles
    struct Cards {
        static func premium(color: Color = Colors.accent) -> some ViewModifier {
            PremiumCardModifier(accentColor: color)
        }
        
        static func stat(color: Color = Colors.accent) -> some ViewModifier {
            StatCardModifier(accentColor: color)
        }
    }
    
    // MARK: - Typography
    struct Typography {
        static let titleLarge = Font.system(size: 32, weight: .bold)
        static let titleMedium = Font.system(size: 24, weight: .bold)
        static let titleSmall = Font.system(size: 20, weight: .semibold)
        
        static let bodyLarge = Font.system(size: 18, weight: .regular)
        static let bodyMedium = Font.system(size: 16, weight: .regular)
        static let bodySmall = Font.system(size: 14, weight: .regular)
        
        static let caption = Font.system(size: 12, weight: .medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
    }
    
    // MARK: - Radius
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let circle: CGFloat = 9999
    }
    
    // MARK: - Animations
    struct Animations {
        static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let easeOut = Animation.easeOut(duration: 0.3)
        static let easeInOut = Animation.easeInOut(duration: 0.4)
    }
}

// MARK: - Custom Modifiers
struct GlassBorderModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.5),
                            color.opacity(0.2),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct PremiumCardModifier: ViewModifier {
    let accentColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Glass.surface())
            .cornerRadius(AppTheme.Radius.medium)
            .modifier(AppTheme.Glass.border(accentColor))
            .shadow(color: accentColor.opacity(0.1), radius: 15, x: 0, y: 5)
    }
}

struct StatCardModifier: ViewModifier {
    let accentColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Glass.surface())
            .cornerRadius(AppTheme.Radius.medium)
            .modifier(AppTheme.Glass.border())
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
    }
}

// MARK: - View Extensions
extension View {
    func premiumCard(color: Color = AppTheme.Colors.accent) -> some View {
        modifier(AppTheme.Cards.premium(color: color))
    }
    
    func statCard(color: Color = AppTheme.Colors.accent) -> some View {
        modifier(AppTheme.Cards.stat(color: color))
    }
    
    func glassBorder(color: Color = .white) -> some View {
        modifier(AppTheme.Glass.border(color))
    }
}

// Add Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 