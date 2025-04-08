/*
 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄
 MIT License

 Copyright (c) 2025 kk-0129

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
import SpriteKit
import FloBox

let STANDARD_LINE_WIDTH = CGFloat(0.5)

extension SKNode{
    var az:CGFloat{ // accummulated z position
        if let p = parent{ return zPosition + p.az }
        return zPosition
    }
    var scene2d:Scene2D{ return scene as! Scene2D }
    @objc func hits(_ pt:CGPoint,_ pt2:CGPoint)->[SKNode]{
        var hs = [SKNode]()
        let cs = children
        for c in cs.sorted(by:{$0.az > $1.az}){
            hs += c.hits( convert(pt,to:c), pt2 )
        }
        return hs
    }
    func handler(for a:Action)->Actor?{
        if let x = self as? Actor, x.performs(a){ return x }
        return parent?.handler(for:a)
    }
    var positionInScene:CGPoint{
        if self is SKScene{ return CGPoint.zero }
        if let p = parent{ return position + p.positionInScene }
        return position
    }
    var zPositionInScene:CGFloat{
        if self is SKScene{ return 0 }
        if let p = parent{ return zPosition + p.zPositionInScene }
        return zPosition
    }
}

// MARK: ■ <--
infix operator <--
public func <--(_ a:SKNode, _ b:SKNode){
    a.addChild(b)
    if let a = a as? SKEffectNode{
        (b as? Box2D)?.enscened()
        (b as? Shape)?.colors = Colors(a.scene!.backgroundColor)
    }
}
public func <--(_ a:SKNode, _ bs:[SKNode]){ for b in bs{ a <-- b } }

public class Shape : SKShapeNode{
    
    //convenience init(_ s:Z, _ c:G){ self.init(cgpath(R(s),c)) }
    convenience init(_ p:CGPath){
        self.init()
        path = p
    }
    override init(){
        super.init()
        _ = linewidth(1)
        self.constraints = nil
        shape_for_highlighting = self
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    func stroke(_ c:Color)->Shape{ strokeColor = c; return self }
    func fill(_ c:Color)->Shape{ fillColor = c; return self }
    func z(_ z:CGFloat)->Shape{ zPosition = z; return self }
    func pos(_ x:CGFloat,_ y:CGFloat)->Shape{ return pos(CGPoint(x:x,y:y)) }
    func pos(_ p:CGPoint)->Shape{ position = p; return self }
    func linewidth(_ g:CGFloat)->Shape{
        lineWidth = STANDARD_LINE_WIDTH * g
        return self.fill(.clear).cap(.round).join(.round)
    }
    func join(_ c: CGLineJoin)->Shape{ lineJoin = c; return self }
    func cap(_ c: CGLineCap)->Shape{ lineCap = c; return self }
    func alias(_ b:Bool)->Shape{ isAntialiased = b; return self }
    func alpha(_ f:CGFloat)->Shape{ alpha = f; return self }
    
    // MARK: colors
    var colors = Colors(.black,.white){ didSet{ notify_redraw() }}
    
    // MARK: hits
    var __hit_path__:CGPath?{ return path }
    override func hits(_ pt:CGPoint,_ pt2:CGPoint)->[SKNode]{
        var hs = super.hits(pt,pt2)
        if let p = __hit_path__, p.contains(pt){ hs.append(self) }
        return hs
    }
    
    // MARK: picks
    var shape_for_highlighting:Shape!
    var picked:Bool = false{ didSet{
        if picked != oldValue{ notify_redraw() }
    }}
    func notify_redraw(){
        shape_for_highlighting.lineWidth = picked ? 2 : 0
    }
    // MARK: enabled
    var enabled = true{ didSet{
        if enabled != oldValue{
            run(.fadeAlpha(to:enabled ? 1 : 0.4,duration:TI₂))
        }
    }}
    
    // MARK: other
    var bodyrect:CGRect{
        if let p = path{
            let b = p.boundingBox
            let p = position
            return CGRect(x:p.x+b.origin.x,y:p.y+b.origin.y,width:b.width,height:b.height)
        }
        return CGRect(x:-10,y:-10,width:20,height:20)
    }
    
}

// MARK: ■ Bubble
enum Bubble{
    
    static func colors(scene:Scene2D)->Colors{
        let x:Float32 = scene.colors.bg.bright ? 0.25 : 0.75
        let bg = Color(x,x,x,1)
        return Colors(bg,bg.contrast)
    }
    
    static let BG = Color.white.scale(1.2).alpha(0.95)
    static let BG2 = Color.white.scale(1.3).alpha(0.95)
    static let BRD = Color.white.scale(1.6)
    static let DX = UNIT*0.05 // arrow width
    static let DY = UNIT*0.1 // arrow height
    
    case Top, Left, Right
    
    public func shape(_ s:CGSize,_ sc:Scene2D)->(Shape,CGPoint){
        var path:CGPath
        var p = CGPoint.zero
        let r = Bubble._corner_radius(s)
        switch self{
        case .Top: path = Bubble._top_path(s,r,&p)
        case .Left: path = Bubble._left_path(s,r,&p)
        case .Right: path = Bubble._right_path(s,r,&p)
        }
        let c = Bubble.colors(scene:sc)
        let s = Shape(path).fill(c.bg).stroke(.clear)
        return ( s, p )
    }
    
    private static func _corner_radius(_ z:CGSize)->CGFloat{
        return min(Bubble.DX, z.height*0.2)
    }
    
    static func _no_arrows(_ size:CGSize,_ CR:CGFloat,_ ctr:inout CGPoint)->CGPath{
        ctr = CGPoint.zero
        return CGPath(roundedRect:CGRect(size:size),cornerWidth:CR,cornerHeight:CR,transform:nil)
    }
    
    static func _top_path(_ size:CGSize,_ CR:CGFloat,_ ctr:inout CGPoint)->CGPath{
        let W = size.width
        let H = size.height
        let TOP = H + DY * 1.5
        let W_2 = ((W + CR) * 0.51)
        let RIGHT = W_2
        let LEFT = -W_2
        let BOTTOM = DY
        ctr = CGPoint(x:0,y:(TOP + BOTTOM)*0.5)
        return [CGPoint.zero].path
            .line(CGPoint(x:-DX,y:BOTTOM))
            .line(CGPoint(x:LEFT + CR,y:BOTTOM))
            .quad(CGPoint(x:LEFT,y:BOTTOM + CR), CGPoint(x:LEFT,y:BOTTOM))
            .line(CGPoint(x:LEFT,y:TOP - CR))
            .quad(CGPoint(x:LEFT + CR,y:TOP), CGPoint(x:LEFT,y:TOP))
            .line(CGPoint(x:RIGHT - CR,y:TOP))
            .quad(CGPoint(x:RIGHT,y:TOP - CR), CGPoint(x:RIGHT,y:TOP))
            .line(CGPoint(x:RIGHT,y:BOTTOM + CR))
            .quad(CGPoint(x:RIGHT - CR,y:BOTTOM), CGPoint(x:RIGHT,y:BOTTOM))
            .line(CGPoint(x:DX,y:BOTTOM))
            .closed
    }
    
    private static func _right_path(_ size:CGSize,_ CR:CGFloat,_ ctr:inout CGPoint)->CGPath{
        let TOP = (size.height + CR) * 0.5
        let BOTTOM = -TOP
        let RIGHT = -Bubble.DY
        let LEFT = RIGHT - size.width - (2*CR)
        ctr = CGPoint(x:(RIGHT + LEFT)*0.5,y:0)
        return [CGPoint.zero].path
            .line(CGPoint(x:RIGHT,y:DX))
            .line(CGPoint(x:RIGHT,y:TOP-CR))
            .quad(CGPoint(x:RIGHT-CR,y:TOP),CGPoint(x:RIGHT,y:TOP))
            .line(CGPoint(x:LEFT+CR,y:TOP))
            .quad(CGPoint(x:LEFT,y:TOP-CR),CGPoint(x:LEFT,y:TOP))
            .line(CGPoint(x:LEFT,y:BOTTOM+CR))
            .quad(CGPoint(x:LEFT+CR,y:BOTTOM),CGPoint(x:LEFT,y:BOTTOM))
            .line(CGPoint(x:RIGHT-CR,y:BOTTOM))
            .quad(CGPoint(x:RIGHT,y:BOTTOM+CR),CGPoint(x:RIGHT,y:BOTTOM))
            .line(CGPoint(x:RIGHT,y:-DX))
            .closed
    }
    
    private static func _left_path(_ size:CGSize,_ CR:CGFloat,_ ctr:inout CGPoint)->CGPath{
        let TOP = (size.height + CR) * 0.5
        let BOTTOM = -TOP
        let LEFT = Bubble.DY
        let RIGHT = LEFT + size.width + (2*CR)
        ctr = CGPoint(x:(RIGHT + LEFT)*0.5,y:0)
        return [CGPoint.zero].path
            .line(CGPoint(x:LEFT,y:DX))
            .line(CGPoint(x:LEFT,y:TOP-CR))
            .quad(CGPoint(x:LEFT+CR,y:TOP),CGPoint(x:LEFT,y:TOP))
            .line(CGPoint(x:RIGHT-CR,y:TOP))
            .quad(CGPoint(x:RIGHT,y:TOP-CR),CGPoint(x:RIGHT,y:TOP))
            .line(CGPoint(x:RIGHT,y:BOTTOM+CR))
            .quad(CGPoint(x:RIGHT-CR,y:BOTTOM),CGPoint(x:RIGHT,y:BOTTOM))
            .line(CGPoint(x:LEFT+CR,y:BOTTOM))
            .quad(CGPoint(x:LEFT,y:BOTTOM+CR),CGPoint(x:LEFT,y:BOTTOM))
            .line(CGPoint(x:LEFT,y:-DX))
            .closed
    }
    
}
