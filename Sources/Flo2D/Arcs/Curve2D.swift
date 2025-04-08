// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import FloGraph
import FloBox
import CoreGraphics

public class Curve2D : Shape{
    
    // MARK: INIT
    
    init(_ show_dots:Bool = false){
        the_curve = Shape().cap(.butt)
        if show_dots{
            _dots = (
                Shape(Dot2D.endpoint(.unknown)),
                Shape(Dot2D.endpoint(.unknown))
            )
        }
        super.init()
        shape_for_highlighting = the_curve
        _ = self.fill(.clear).stroke(.clear)
        if let (a,b) = _dots{ self <-- [a,b] }
        self <-- the_curve.z(0.1)
    }
    required init?(coder c: NSCoder){ fatalError() }
    
    // MARK: VARS
    
    private let the_curve:Shape
    private var _dots:(Shape,Shape)?
    
    // MARK: NOTIFICATIONS
    
    override func notify_redraw(){
        super.notify_redraw()
        the_curve.lineWidth = picked ? 2.5 : 1
        if let (a,b) = _dots{
            _ = a.fill(colors.fg).stroke(colors.fg)
            _ = b.fill(colors.fg).stroke(colors.fg)
        }
        _ = the_curve.stroke(colors.fg)
    }
    
    // MARK: ENDPOINTS
    
    var endpoints:((CGPoint,Dot2D.Dir),(CGPoint,Dot2D.Dir))?{ didSet{
        picked = false // endpoints != nil
        if let ((sp,sd),(ep,ed)) = endpoints{
            if let (a,b) = _dots{
                a.position = sp // start point
                b.position = ep // end point
                _ = a.alpha(1)
                _ = b.alpha(1)
            }
            let p = CGMutablePath()
            let r = Dot2D.Radius * 0.5
            
            var _b = ep // escape the dot radius
            switch ed{
            case .left: _b = ep - CGPoint(x:r,y:0); _dots?.1.zRotation = π
            case .right: _b = ep + CGPoint(x:0,y:r); _dots?.1.zRotation = 0
            case .top: _b = ep + CGPoint(x:0,y:r); _dots?.1.zRotation = π_2
            case .bottom: _b = ep - CGPoint(x:0,y:r); _dots?.1.zRotation = -π_2
            case .unknown: break // only for dragging
            }
            switch sd{ // SOURCE
            case .left:
                _dots?.0.zRotation = π
                let _a = sp - CGPoint(x:r,y:0) // escape the dot radius
                p.move(to:_a)
                switch ed{
                case .left: _ = p.line(_b)
                case .right: _ = p.line(_b)
                case .top: _ = p.line(_b)
                case .bottom: _ = p.line(_b)
                case .unknown: _ = p.line(_b)
                }
            case .right:
                _dots?.0.zRotation = 0
                let _a = sp + CGPoint(x:r,y:0) // escape the dot radius
                let dx = max( abs(_b.x - _a.x) * 0.5, min( abs(_b.y - _a.y), 20 ) )
                let dy = max( abs(_b.y - _a.y) * 0.5, min( abs(_b.x - _a.x), 20 ) )
                p.move(to:_a)
                switch ed{
                case .left: p.addCurve(to:_b,control1:_a+CGPoint(x:dx,y:0),control2:_b-CGPoint(x:dx,y:0))
                case .right: _ = p.line(_b)
                case .top: p.addCurve(to:_b,control1:_a+CGPoint(x:dx,y:0),control2:_b+CGPoint(x:0,y:dy))
                case .bottom: p.addCurve(to:_b,control1:_a+CGPoint(x:dx,y:0),control2:_b-CGPoint(x:0,y:dy))
                case .unknown: _ = p.line(_b)
                }
            case .top:
                _dots?.0.zRotation = π_2
                let _a = sp + CGPoint(x:0,y:r) // escape the dot radius
                p.move(to:_a)
                switch ed{
                case .left: _ = p.line(_b)
                case .right: _ = p.line(_b)
                case .top: _ = p.line(_b)
                case .bottom: _ = p.line(_b)
                case .unknown: _ = p.line(_b)
                }
            case .bottom:
                _dots?.0.zRotation = -π_2
                let _a = sp - CGPoint(x:0,y:r) // escape the dot radius
                p.move(to:_a)
                let dy = max( abs(_b.y - _a.y) * 0.5, min( abs(_b.x - _a.x), 20 ) )
                switch ed{
                case .left:
                    let dx = max( abs(_b.x - _a.x) * 0.5, min( abs(_b.y - _a.y), 20 ) )
                    p.addCurve(to:_b,control1:_a-CGPoint(x:0,y:dy),control2:_b-CGPoint(x:dx,y:0))
                case .right: _ = p.line(_b)
                case .top: p.addCurve(to:_b,control1:_a-CGPoint(x:0,y:dy),control2:_b+CGPoint(x:0,y:dy))
                case .bottom: _ = p.line(_b)
                case .unknown: _ = p.line(_b)
                }
            case .unknown: _ = p.line(_b)
            }
            the_curve.path = p
            path = p.copy(strokingWithWidth:STANDARD_LINE_WIDTH*15,lineCap:lineCap,lineJoin:lineJoin,miterLimit:miterLimit)
        }else{
            the_curve.path = nil
            path = nil
            if let (a,b) = _dots{
                _ = a.alpha(0)
                _ = b.alpha(0)
            }
        }
    } }
    
}
