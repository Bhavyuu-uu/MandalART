import SwiftUI
import CoreGraphics

struct MandalaPattern {
    enum PatternType: String, CaseIterable {
        case mandala = "Mandala"
        case geometric = "Geometric"
        case floral = "Floral"
        case abstract = "Abstract"
        case waves = "Waves"
        case dots = "Dots"
        case lines = "Lines"
        case mixed = "Mixed"
    }
    
    static func generatePattern(type: PatternType, size: CGSize, colors: [Color]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.systemBackground.cgColor)
            context.cgContext.fill(rect)
            
            switch type {
            case .mandala:
                drawTiledMandalaPattern(context: context, size: size, colors: colors)
            case .geometric:
                drawGeometricPattern(context: context, size: size, colors: colors)
            case .floral:
                drawFloralPattern(context: context, size: size, colors: colors)
            case .abstract:
                drawAbstractPattern(context: context, size: size, colors: colors)
            case .waves:
                drawWavePattern(context: context, size: size, colors: colors)
            case .dots:
                drawDotPattern(context: context, size: size, colors: colors)
            case .lines:
                drawLinePattern(context: context, size: size, colors: colors)
            case .mixed:
                drawMixedPattern(context: context, size: size, colors: colors)
            }
        }
    }
    
    private static func drawTiledMandalaPattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        let motifCount = Int((size.width * size.height) / 9000) // increased density
        let palette = colors.shuffled()
        let minRadius = min(size.width, size.height) * 0.06
        let maxRadius = min(size.width, size.height) * 0.16
        
        for i in 0..<motifCount {
            let center = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            let radius = CGFloat.random(in: minRadius...maxRadius)
            let motifType = Int.random(in: 0...2)
            let colorSet = Array(palette.shuffled().prefix(Int.random(in: 3...6)))
            let rotation = CGFloat.random(in: 0...(2 * .pi))
            
            context.cgContext.saveGState()
            context.cgContext.translateBy(x: center.x, y: center.y)
            context.cgContext.rotate(by: rotation)
            
            switch motifType {
            case 0:
                drawMotifMandala(context: context, radius: radius, colors: colorSet)
            case 1:
                drawMotifStar(context: context, radius: radius, colors: colorSet)
            default:
                drawMotifPolygon(context: context, radius: radius, colors: colorSet)
            }
            // --- Draw additional intertwined shapes inside motif ---
            let innerShapeCount = Int.random(in: 2...4)
            for _ in 0..<innerShapeCount {
                let innerType = Int.random(in: 0...2)
                let innerRadius = radius * CGFloat.random(in: 0.3...0.7)
                let innerRotation = CGFloat.random(in: 0...(2 * .pi))
                let innerColors = Array(palette.shuffled().prefix(Int.random(in: 2...colorSet.count)))
                context.cgContext.saveGState()
                context.cgContext.rotate(by: innerRotation)
                switch innerType {
                case 0:
                    drawMotifStar(context: context, radius: innerRadius, colors: innerColors)
                case 1:
                    drawMotifPolygon(context: context, radius: innerRadius, colors: innerColors)
                default:
                    drawMotifMandala(context: context, radius: innerRadius, colors: innerColors)
                }
                context.cgContext.restoreGState()
            }
            context.cgContext.restoreGState()
        }
        // --- Add a color blending overlay for smooth transitions ---
        let blendColors = palette.shuffled().prefix(3)
        let blendGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: blendColors.map { UIColor($0).withAlphaComponent(0.18).cgColor } as CFArray,
            locations: [0, 0.5, 1]
        )
        context.cgContext.saveGState()
        context.cgContext.setBlendMode(.softLight)
        context.cgContext.drawLinearGradient(
            blendGradient!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size.width, y: size.height),
            options: []
        )
        context.cgContext.restoreGState()
    }
    
    private static func drawMotifMandala(context: UIGraphicsRendererContext, radius: CGFloat, colors: [Color]) {
        let layers = Int.random(in: 3...5)
        for layer in 0..<layers {
            let layerRadius = radius * (1.0 - CGFloat(layer) * 0.18)
            let segments = 8 + layer * 4
            let color = colors[layer % colors.count]
            for i in 0..<segments {
                let angle = Double(i) * 2 * .pi / Double(segments)
                drawPetal(context: context, center: .zero, radius: layerRadius, angle: angle, color: color, size: 0.3)
            }
        }
        // Center
        let centerColor = colors.last ?? .white
        let centerPath = UIBezierPath(arcCenter: .zero, radius: radius * 0.18, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        UIColor(centerColor).setFill()
        centerPath.fill()
    }
    
    private static func drawMotifStar(context: UIGraphicsRendererContext, radius: CGFloat, colors: [Color]) {
        let points = Int.random(in: 6...10)
        let color = colors.randomElement() ?? .white
        let path = UIBezierPath()
        for i in 0..<points {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(points)
            let pt = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
            let midAngle = angle + .pi / CGFloat(points)
            let midPt = CGPoint(x: cos(midAngle) * radius * 0.5, y: sin(midAngle) * radius * 0.5)
            path.addLine(to: midPt)
        }
        path.close()
        UIColor(color).setFill()
        path.fill()
    }
    
    private static func drawMotifPolygon(context: UIGraphicsRendererContext, radius: CGFloat, colors: [Color]) {
        let sides = Int.random(in: 5...8)
        let color = colors.randomElement() ?? .white
        let path = UIBezierPath()
        for i in 0..<sides {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(sides)
            let pt = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.close()
        UIColor(color).setFill()
        path.fill()
    }
    
    private static func drawGeometricPattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        let gridSize = 8
        let cellWidth = size.width / CGFloat(gridSize)
        let cellHeight = size.height / CGFloat(gridSize)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let x = CGFloat(col) * cellWidth
                let y = CGFloat(row) * cellHeight
                let color = colors[(row + col) % colors.count]
                
                // Randomly choose shape
                let shape = Int.random(in: 0...3)
                switch shape {
                case 0:
                    drawRectangle(context: context, rect: CGRect(x: x, y: y, width: cellWidth, height: cellHeight), color: color)
                case 1:
                    drawTriangle(context: context, rect: CGRect(x: x, y: y, width: cellWidth, height: cellHeight), color: color)
                case 2:
                    drawCircle(context: context, rect: CGRect(x: x, y: y, width: cellWidth, height: cellHeight), color: color)
                default:
                    drawDiamond(context: context, rect: CGRect(x: x, y: y, width: cellWidth, height: cellHeight), color: color)
                }
            }
        }
    }
    
    private static func drawFloralPattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        let gridSize = 6
        let cellWidth = size.width / CGFloat(gridSize)
        let cellHeight = size.height / CGFloat(gridSize)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let x = CGFloat(col) * cellWidth + cellWidth/2
                let y = CGFloat(row) * cellHeight + cellHeight/2
                let color = colors[(row + col) % colors.count]
                
                // Draw flower
                drawFlower(context: context, center: CGPoint(x: x, y: y), radius: min(cellWidth, cellHeight) * 0.4, color: color)
            }
        }
    }
    
    private static func drawAbstractPattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        let numberOfLines = 50
        let lineLength = min(size.width, size.height) * 0.3
        
        for _ in 0..<numberOfLines {
            let startX = CGFloat.random(in: 0...size.width)
            let startY = CGFloat.random(in: 0...size.height)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let color = colors.randomElement() ?? .blue
            
            let endX = startX + cos(angle) * lineLength
            let endY = startY + sin(angle) * lineLength
            
            drawLine(context: context, start: CGPoint(x: startX, y: startY), end: CGPoint(x: endX, y: endY), color: color)
        }
    }
    
    private static func drawWavePattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        let numberOfWaves = 5
        let waveHeight = size.height / CGFloat(numberOfWaves)
        
        for i in 0..<numberOfWaves {
            let y = CGFloat(i) * waveHeight
            let color = colors[i % colors.count]
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y))
            
            for x in stride(from: 0, through: size.width, by: 10) {
                let waveY = y + sin(x * 0.02) * waveHeight * 0.3
                path.addLine(to: CGPoint(x: x, y: waveY))
            }
            
            path.lineWidth = 3
            UIColor(color).setStroke()
            path.stroke()
        }
    }
    
    private static func drawDotPattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        let numberOfDots = 200
        let maxDotSize = min(size.width, size.height) * 0.05
        
        for _ in 0..<numberOfDots {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let dotSize = CGFloat.random(in: maxDotSize * 0.2...maxDotSize)
            let color = colors.randomElement() ?? .blue
            
            let path = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: dotSize/2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            UIColor(color).setFill()
            path.fill()
        }
    }
    
    private static func drawLinePattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        let numberOfLines = 30
        let lineSpacing = size.width / CGFloat(numberOfLines)
        
        for i in 0..<numberOfLines {
            let x = CGFloat(i) * lineSpacing
            let color = colors[i % colors.count]
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            
            path.lineWidth = 2
            UIColor(color).setStroke()
            path.stroke()
        }
    }
    
    private static func drawMixedPattern(context: UIGraphicsRendererContext, size: CGSize, colors: [Color]) {
        // Randomly choose 2-3 pattern types to combine
        let patternTypes: [PatternType] = [.geometric, .floral, .waves, .dots, .lines]
        let selectedPatterns = Array(patternTypes.shuffled().prefix(Int.random(in: 2...3)))
        
        for pattern in selectedPatterns {
            switch pattern {
            case .geometric:
                drawGeometricPattern(context: context, size: size, colors: colors)
            case .floral:
                drawFloralPattern(context: context, size: size, colors: colors)
            case .waves:
                drawWavePattern(context: context, size: size, colors: colors)
            case .dots:
                drawDotPattern(context: context, size: size, colors: colors)
            case .lines:
                drawLinePattern(context: context, size: size, colors: colors)
            default:
                break
            }
        }
    }
    
    // Helper drawing functions
    private static func drawRectangle(context: UIGraphicsRendererContext, rect: CGRect, color: Color) {
        let path = UIBezierPath(rect: rect)
        UIColor(color).setFill()
        path.fill()
    }
    
    private static func drawTriangle(context: UIGraphicsRendererContext, rect: CGRect, color: Color) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.close()
        
        UIColor(color).setFill()
        path.fill()
    }
    
    private static func drawCircle(context: UIGraphicsRendererContext, rect: CGRect, color: Color) {
        let path = UIBezierPath(ovalIn: rect)
        UIColor(color).setFill()
        path.fill()
    }
    
    private static func drawDiamond(context: UIGraphicsRendererContext, rect: CGRect, color: Color) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.close()
        
        UIColor(color).setFill()
        path.fill()
    }
    
    private static func drawFlower(context: UIGraphicsRendererContext, center: CGPoint, radius: CGFloat, color: Color) {
        let numberOfPetals = 8
        let petalAngle = 2 * .pi / CGFloat(numberOfPetals)
        
        for i in 0..<numberOfPetals {
            let angle = CGFloat(i) * petalAngle
            let petalPath = UIBezierPath()
            
            petalPath.move(to: center)
            petalPath.addArc(withCenter: center,
                           radius: radius,
                           startAngle: angle - petalAngle/2,
                           endAngle: angle + petalAngle/2,
                           clockwise: true)
            petalPath.close()
            
            UIColor(color).setFill()
            petalPath.fill()
        }
        
        // Draw center
        let centerPath = UIBezierPath(arcCenter: center, radius: radius * 0.3, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        UIColor(color).setFill()
        centerPath.fill()
    }
    
    private static func drawLine(context: UIGraphicsRendererContext, start: CGPoint, end: CGPoint, color: Color) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        path.lineWidth = 2
        UIColor(color).setStroke()
        path.stroke()
    }
    
    // Existing helper functions
    private static func drawPetal(context: UIGraphicsRendererContext, center: CGPoint, radius: CGFloat, angle: Double, color: Color, size: CGFloat) {
        let path = UIBezierPath()
        let startAngle = angle - .pi / 6
        let endAngle = angle + .pi / 6
        
        path.move(to: center)
        path.addArc(withCenter: center,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: true)
        path.addLine(to: center)
        path.close()
        
        context.cgContext.setFillColor(UIColor(color).cgColor)
        path.fill()
        
        // Add gradient effect
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(color).cgColor,
                UIColor(color).withAlphaComponent(0.7).cgColor
            ] as CFArray,
            locations: [0, 1]
        )!
        
        context.cgContext.saveGState()
        path.addClip()
        context.cgContext.drawLinearGradient(
            gradient,
            start: center,
            end: CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            ),
            options: []
        )
        context.cgContext.restoreGState()
    }
    
    private static func drawDecorativeElement(context: UIGraphicsRendererContext, center: CGPoint, radius: CGFloat, angle: Double, color: Color, size: CGFloat) {
        let path = UIBezierPath()
        let elementSize = radius * size
        
        let x = center.x + cos(angle) * radius
        let y = center.y + sin(angle) * radius
        
        path.move(to: CGPoint(x: x - elementSize/2, y: y - elementSize/2))
        path.addLine(to: CGPoint(x: x + elementSize/2, y: y - elementSize/2))
        path.addLine(to: CGPoint(x: x + elementSize/2, y: y + elementSize/2))
        path.addLine(to: CGPoint(x: x - elementSize/2, y: y + elementSize/2))
        path.close()
        
        context.cgContext.setFillColor(UIColor(color).withAlphaComponent(0.5).cgColor)
        path.fill()
    }
    
    private static func drawCenterPiece(context: UIGraphicsRendererContext, center: CGPoint, radius: CGFloat, colors: [Color]) {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors.map { UIColor($0).cgColor } as CFArray,
            locations: [0, 0.5, 1]
        )!
        
        context.cgContext.saveGState()
        path.addClip()
        context.cgContext.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: radius,
            options: []
        )
        context.cgContext.restoreGState()
    }
} 