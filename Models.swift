import SwiftUI

// MARK: - DevTool
struct DevTool: Identifiable, Equatable {
    let id: String
    let name: String
    let category: ToolCategory
    let rating: Double
    let ratingCount: Int
    let descriptions: [String: String]
    let source: ToolSource
    let tags: [String]
    let accentColor: String
    let isFeatured: Bool
    let weeklyGrowth: Double
    let githubStars: Int?
    let pricing: ToolPricing
    let platforms: [Platform]
    let websiteURL: String
    let githubURL: String?
    let lastUpdated: Date
    let version: String
    
    func localizedDescription(for lang: AppLanguage) -> String {
        descriptions[lang.rawValue] ?? descriptions["en"] ?? ""
    }
    var formattedRating: String { String(format: "%.1f", rating) }
    var formattedStars: String {
        guard let s = githubStars else { return "" }
        return s >= 1000 ? String(format: "%.1fk", Double(s)/1000) : "\(s)"
    }
    var color: Color { Color(hex: accentColor) ?? .blue }
    static func == (lhs: DevTool, rhs: DevTool) -> Bool { lhs.id == rhs.id }
}

// MARK: - Category
enum ToolCategory: String, CaseIterable, Identifiable {
    case all, aiML, devOps, frontend, backend, database
    case mobile, security, testing, collaboration, cloudInfra, codeEditor, apiTools, monitoring
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .aiML: return "brain.head.profile"
        case .devOps: return "gearshape.2.fill"
        case .frontend: return "display"
        case .backend: return "server.rack"
        case .database: return "cylinder.split.1x2.fill"
        case .mobile: return "iphone"
        case .security: return "lock.shield.fill"
        case .testing: return "checkmark.seal.fill"
        case .collaboration: return "person.3.fill"
        case .cloudInfra: return "cloud.fill"
        case .codeEditor: return "chevron.left.forwardslash.chevron.right"
        case .apiTools: return "network"
        case .monitoring: return "chart.line.uptrend.xyaxis"
        }
    }
    var localizedName: String {
        switch self {
        case .all: return L("cat_all")
        case .aiML: return L("cat_ai")
        case .devOps: return L("cat_devops")
        case .frontend: return L("cat_frontend")
        case .backend: return L("cat_backend")
        case .database: return L("cat_database")
        case .mobile: return L("cat_mobile")
        case .security: return L("cat_security")
        case .testing: return L("cat_testing")
        case .collaboration: return L("cat_collab")
        case .cloudInfra: return L("cat_cloud")
        case .codeEditor: return L("cat_editor")
        case .apiTools: return L("cat_api")
        case .monitoring: return L("cat_monitoring")
        }
    }
    var gradient: [Color] {
        switch self {
        case .all: return [.purple, .blue]
        case .aiML: return [Color(hex:"#FF6B6B") ?? .red, Color(hex:"#FF8E53") ?? .orange]
        case .devOps: return [Color(hex:"#4ECDC4") ?? .teal, Color(hex:"#44A08D") ?? .green]
        case .frontend: return [Color(hex:"#A18CD1") ?? .purple, Color(hex:"#FBC2EB") ?? .pink]
        case .backend: return [Color(hex:"#2196F3") ?? .blue, Color(hex:"#21CBF3") ?? .cyan]
        case .database: return [Color(hex:"#F093FB") ?? .purple, Color(hex:"#F5576C") ?? .red]
        case .mobile: return [Color(hex:"#4FACFE") ?? .blue, Color(hex:"#00F2FE") ?? .cyan]
        case .security: return [Color(hex:"#F7971E") ?? .orange, Color(hex:"#FFD200") ?? .yellow]
        case .testing: return [Color(hex:"#56CCF2") ?? .blue, Color(hex:"#2F80ED") ?? .blue]
        case .collaboration: return [Color(hex:"#11998E") ?? .green, Color(hex:"#38EF7D") ?? .green]
        case .cloudInfra: return [Color(hex:"#FC5C7D") ?? .pink, Color(hex:"#6A3093") ?? .purple]
        case .codeEditor: return [Color(hex:"#434343") ?? .black, Color(hex:"#000000") ?? .black]
        case .apiTools: return [Color(hex:"#00B4DB") ?? .blue, Color(hex:"#0083B0") ?? .blue]
        case .monitoring: return [Color(hex:"#FF416C") ?? .red, Color(hex:"#FF4B2B") ?? .orange]
        }
    }
}

// MARK: - Source
enum ToolSource: String, CaseIterable {
    case github="GitHub", producthunt="Product Hunt", official="Official", npm="npm", pypi="PyPI"
    var icon: String {
        switch self {
        case .github: return "chevron.left.forwardslash.chevron.right"
        case .producthunt: return "flame.fill"
        case .official: return "checkmark.seal.fill"
        case .npm: return "shippingbox.fill"
        case .pypi: return "swift"
        }
    }
    var color: Color {
        switch self {
        case .github: return Color(hex:"#24292E") ?? .black
        case .producthunt: return Color(hex:"#DA552F") ?? .orange
        case .official: return .green
        case .npm: return Color(hex:"#CB3837") ?? .red
        case .pypi: return Color(hex:"#3776AB") ?? .blue
        }
    }
}

// MARK: - Pricing
enum ToolPricing {
    case free, openSource, freemium(String), paid(String)
    var displayText: String {
        switch self {
        case .free: return L("free")
        case .openSource: return L("open_source")
        case .freemium(let p): return "Freemium · \(p)"
        case .paid(let p): return p
        }
    }
    var color: Color {
        switch self {
        case .free, .openSource: return .green
        case .freemium: return .orange
        case .paid: return .blue
        }
    }
}

// MARK: - Platform
enum Platform: String, CaseIterable {
    case web="Web", ios="iOS", android="Android"
    case macOS="macOS", windows="Windows", linux="Linux", cli="CLI"
    var icon: String {
        switch self {
        case .web: return "globe"
        case .ios: return "iphone"
        case .android: return "candybarphone"
        case .macOS: return "desktopcomputer"
        case .windows: return "pc"
        case .linux: return "terminal"
        case .cli: return "terminal.fill"
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in:.whitespacesAndNewlines).replacingOccurrences(of:"#", with:"")
        var rgb: UInt64 = 0
        guard Scanner(string:h).scanHexInt64(&rgb) else { return nil }
        self.init(red:Double((rgb>>16)&0xFF)/255, green:Double((rgb>>8)&0xFF)/255, blue:Double(rgb&0xFF)/255)
    }
}

// MARK: - Extensions
extension Int {
    var formattedWithCommas: String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return f.string(from: NSNumber(value:self)) ?? "\(self)"
    }
}
extension Double {
    var percentFormatted: String { String(format:"+%.1f%%", self) }
}

// MARK: - Haptics
import UIKit
struct HapticFeedback {
    static func light() { UIImpactFeedbackGenerator(style:.light).impactOccurred() }
    static func medium() { UIImpactFeedbackGenerator(style:.medium).impactOccurred() }
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}

// MARK: - Card Style
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius:cornerRadius, style:.continuous))
            .shadow(color:.black.opacity(0.06), radius:10, x:0, y:4)
    }
}
extension View {
    func cardStyle(cornerRadius: CGFloat = 18) -> some View { modifier(CardModifier(cornerRadius:cornerRadius)) }
}

// MARK: - Star Rating
struct StarRatingView: View {
    let rating: Double
    var size: CGFloat = 12
    var color: Color = .yellow
    var body: some View {
        HStack(spacing:2) {
            ForEach(0..<5, id:\.self) { i in
                Image(systemName: rating >= Double(i)+1 ? "star.fill" : (rating >= Double(i)+0.5 ? "star.leadinghalf.filled" : "star"))
                    .font(.system(size:size)).foregroundColor(color)
            }
        }
    }
}

// MARK: - Bounce Button
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response:0.3, dampingFraction:0.6), value:configuration.isPressed)
    }
}

// MARK: - Shimmer
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        GeometryReader { g in
            LinearGradient(stops:[
                .init(color:.clear, location:0),
                .init(color:.white.opacity(0.6), location:0.45),
                .init(color:.white.opacity(0.6), location:0.55),
                .init(color:.clear, location:1)
            ], startPoint:.leading, endPoint:.trailing)
            .frame(width:g.size.width*3)
            .offset(x: phase * g.size.width*3 - g.size.width)
        }
        .onAppear { withAnimation(.linear(duration:1.4).repeatForever(autoreverses:false)) { phase=1 } }
    }
}

