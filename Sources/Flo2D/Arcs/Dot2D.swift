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
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class Dot2D : Shape,Actor{
    
    enum Dir{ case left,right,top,bottom,unknown }
    
    // MARK: STATICS
    
    static let Attrs = A$(0.9,[])
    static let Radius = UNIT * 0.1
    static let DY = UNIT * 0.45
    static let DX = DY * 0.3 // spacing to label
    static func defaultLabelPosition(_ L:Bool)->CGPoint{
        return CGPoint(x: L ? DX : -DX,y: -DX*0.6)
    }
    static func endpoint(_ dir:Dir)->CGPath{
        let s = Radius * 0.6
        var a,b:CGFloat!
        switch dir{
        case .left: a = -3*π_8; b = -a 
        case .right: a = 5*π_8; b = -a
        case .top: a = -7*π_8; b = -1*π_8
        case .bottom: a = 1*π_8; b = 7*π_8
        case .unknown: return CGPath.make(radius:s*0.4)
        }
        return CGMutablePath().arc(CGPoint.zero,s,a,b,true).closed
    }
    
    // MARK: INIT
    
    init(_ dot:Dot,_ t:T){
        self.dot = dot
        self.dot_type = t
        dir = dot.input ? .left : .right
        super.init()
        if !dot.dotID.isEmpty && "_" != dot.dotID.first && Box.on$ != dot.dotID{
            label = Label(dot.dotID,Dot2D.Attrs).alpha(MAX_ALPHA).z(0)
        }
        zPosition = 1.1
        dot_shape = Shape()
        path = CGPath.make(radius:Dot2D.Radius * 1.2) // outer 'hit' radius
        let h:Hᴬ = dot.input ? .left : .right
        if let l = label{
            l.position = Dot2D.defaultLabelPosition(dot.input)
            self <-- l.v(.baseline).h(h).z(0.3)
        }
        self <-- dot_shape
        _ = fill(.clear).stroke(.clear).z(0.01) // outer radius, not inner dot
        __dir_changed__()
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    let dot:Dot
    var dot_name:String{ return dot.dotID }
    let dot_type:T
    var dir:Dir{ didSet{ __dir_changed__() } }
    var box2d:Box2D{ return parent as! Box2D }
    var dot_shape: Shape!
    var label: Label?
    var dot_color = Color(0,0,0,1)
    var text_color = Color(1,1,1,1){ didSet{ label?.fontcolor = text_color }}
    var textwidth:CGFloat{
        if let l = label{ return l.size.width }
        else{ return 0 }
    }
    private var _timer: Timer?{ didSet{ oldValue?.invalidate() } }
    private var _ep:Dot2D?{ didSet{
        oldValue?._picked = false
        _ep?._picked = true
    }}
    private var _eps = [Dot2D]() // VALID ENDPOINTS
    private var _eps_x = [Dot2D]() // NON-VALID ENDPOINTS
    
    // MARK: NOTIFICATIONS
    
    var box_colors = Colors(.white,.black){ didSet{
        text_color = box_colors.fg
        label?.fontcolor = text_color
    }}
    override func notify_redraw(){
        dot_color = colors.fg.alpha(Float32(MAX_ALPHA))
        _ = dot_shape.fill(dot_color).stroke(dot_color)
        super.notify_redraw()
    }
    /*
    func box(colors:Colors){
        text_color = colors.fg
        label?.fontcolor = text_color
    }*/
    
    // MARK: Actor
    
    func performs(_ a:Action)->Bool{
        switch a{
        case .POINT: return true
        default: return false
        }
    }
    
    func perform(_ action:Action,_ sc:Scene2D){
        switch action{
        case .POINT(let locator,_,_,let phase):
            switch phase{
            case .BEGIN:
                _picked = true
                sc.pick.clear()
                if let b = _make_info_bubble(dot_type,sc){
                    let x:CGFloat = dot.input ? -Dot2D.Radius : Dot2D.Radius
                    b.position = convert(CGPoint(x:x,y:0),to:sc)
                    _timer = Timer.scheduledTimer(withTimeInterval:0.3,repeats:false){ [weak sc] _ in
                        DispatchQueue.main.async {
                            if let sc = sc{
                                sc.__bubble__ = b
                            }
                        }
                    }
                }
            case .DELTA:
                if _timer != nil{
                    _timer = nil
                    sc.__bubble__ = nil
                    _eps.removeAll()
                    _eps_x.removeAll()
                    for b in sc.box2Ds{
                        for d in b.dots{
                            if self.__can_connect__(to:d){ _eps.append(d) }
                            else{
                                _eps_x.append(d)
                                if self != d{ d.__fade(to:0.2) }
                            }
                        }
                    }
                }
                let _1 = positionInScene
                let _2 = locator(sc)
                sc.draggedCurve(pts:((_1,dir),(_2,.unknown)))
                _ep = nil
                for ep in _eps{
                    let p = ep.dot_shape.convert(_2,from:sc)
                    if ep.path!.contains(p){
                        _ep = ep
                        break
                    }
                }
                //sc.updateCameraForDragging(R(_2.x-10,_2.y-10,20,20))
            case .END:
                if let t = _timer{
                    t.invalidate()
                    sc.__bubble__ = nil
                }
                sc.draggedCurve(pts:nil)
                _picked = false
                for d in _eps_x{ if self != d{ d.__fade(to:MAX_ALPHA) } }
                _eps.removeAll()
                _eps_x.removeAll()
                if let ep = _ep{
                    let s = dot.input ? ep.dot : dot
                    let d = dot.input ? dot : ep.dot
                    sc.undoableAdd(pick:Pick([Arc(s,d)]))
                    _ep = nil
                }
            }
        default: break
        }
    }
    
    // MARK: INFO BUBBLE
    
    private func _make_info_bubble(_ t:T,_ sc:Scene2D)->Shape?{
        let c = sc.colors.bg.contrast.contrast
        if sc.focus[dot.boxID] != nil{ 
            let T1 = T$(t.s$,A$(0.8,[],c))
            //var T2:T$?
            let h = T1.size.height//ᵁ * 0.4
            let w = T1.size.width
            /*if !q.isEmpty{
                T2 = T$(q,A$(0.7,false,c))
                w += T2!.size.width + 15
            }*/
            let z = CGSize(width:w,height:h)
            let (bub,ctr) = dot.input ? Bubble.Right.shape(z,sc) : Bubble.Left.shape(z,sc)
            bub.zPosition = 1000000
            bub <-- Label(T1).v(.center).pos(ctr.x,ctr.y).h(.center)
            /*if let t = T2{
                let _w = T1.size.width + 7
                bub <-- Label(t).v(.baseline).pos(dx + (input ? -_w : _w),dy+3).h(.center)
            }*/
            return bub
        }
        return nil
    }
    
    // MARK: HELPER
    
    private var _picked = false{ didSet{
        // animations = OK wrt render-update
        if let l = label{
            l.run(.group([
                .scale(to:_picked ? 1.03 : 1,duration:TI),
                .fadeAlpha(to:_picked ? 1 : MAX_ALPHA,duration:TI)
            ]))
        }
        dot_shape.run(.scale(to:_picked ? 1.2 : 1,duration:TI))
    }}
    
    private func __dir_changed__(){
        if dot_shape.parent != nil{ dot_shape.removeFromParent() }
        dot_shape = Shape(Dot2D.endpoint(dir)).linewidth(0.5).fill(dot_color).stroke(dot_color)
        self <-- dot_shape
    }
    
    private func __fade(to a:CGFloat){
        // animations = OK wrt render-update
        run(.fadeAlpha(to:a,duration:TI₂))
    }
    
    private func __can_connect__(to d:Dot2D)->Bool{
        if dot != d.dot && dot.input != d.dot.input{
            let t1 = dot.input ? box2d.box.inputs[dot.dotID] : box2d.box.outputs[dot.dotID]
            let t2 = dot.input ? d.box2d.box.outputs[d.dot.dotID] : d.box2d.box.inputs[d.dot.dotID]
            return t1 == t2
        }
        return false
    }
    
}

private let MAX_ALPHA = CGFloat(1)
