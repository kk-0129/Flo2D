// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import FloGraph

extension Box{
    
    var box2d:Box2D{
        var b:Box2D?
        switch kind{
        case .ANNOT: b = Annot2D(self)
        case .CLOCK: b = Clock2D(self)
        case .EXPR: b = Expr2D(self)
        case .GRAPH: b = Graph2D(self)
        case .INPUT: b = InOut2D(self)
        case .METER: b = Meter2D(self)
        case .OUTPUT: b = InOut2D(self)
        case .PROXY: b = Proxy2D(self)
        case .SWITCH: b = Switch2D(self)
        case .TEXT: b = Text2D(self)
        case .IMU: b = IMU3D(self)
        case .HISTO: b = Histogram2D(self)
        }
        return b!
    }
    
}
