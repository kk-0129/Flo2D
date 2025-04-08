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

class Annot2D : Textual2D{
    
    private let _hooks:[_Hook.Corner:_Hook] = [
        .TL:_Hook(.TL),
        .TR:_Hook(.TR),
        .BL:_Hook(.BL),
        .BR:_Hook(.BR)
    ]
    private let hook_shape = Shape()
    
    // MARK: INIT
    
    init(_ box:Box){
        super.init(box,WIDTH*2)
        let p = CGMutablePath()
        for (_,h) in _hooks{
            self <-- h
            p.addPath(h.line.path!)
        }
        hook_shape.path = p
        strokeColor = .clear
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    
    fileprivate var _state_at_ldown:(F2,F2)? // (pos,size)
    
    override var zPosition:CGFloat{
        get{ return super.zPosition }
        set{ super.zPosition = -10000000 } // always behind
    }
    
    // MARK: FUNCS
    override func notify_redraw(){
        super.notify_redraw()
        strokeColor = .clear
        elabel.label.fontcolor = colors.fg.alpha(0.5)
        fillColor = colors.fg.alpha(0.15)
        for (_,h) in _hooks{
            h.line.strokeColor = colors.fg
            h.line.lineWidth = picked ? 2 : 0
        }
    }
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        super.observed(f,slots)
        for id in slots{
            if id == .size{ __size_changed__() }
        }
    }
    
    // MARK: ELabel.Validator
    var __size_on_editor_open__ : F2?
    override func editor(changed txt:String)->Any?{
        if __size_on_editor_open__ == nil{ __size_on_editor_open__ = box.size }
        return super.editor(changed: txt)
    }
    
    override func editor(closed txt:String,validated any:Any){
        super.editor(closed:txt,validated:any)
        __size_on_editor_open__ = nil
    }
    
    // MARK: RECALC PATH
    
    override func recalculatePath(){
        // no need to call super (there are no dots !)
        // called on text change
        if let z = __size_on_editor_open__{
            let s = __min_size__
            box.size = F2(max(s.x,z.x),max(s.y,z.y))
        }else{ __size_changed__() }
    }
    
    var __min_size__:F2{
        let s = elabel.label.size
        return F2(Float32(s.width*1.5),Float32(s.height*1.5))
    }
    
    func __size_changed__(){
        let s = box.size
        let r = CGRect(size:CGSize(width:CGFloat(s.x),height:CGFloat(s.y)))
        elabel.position = CGPoint(x:0,y:CGFloat(s.y*0.5)-elabel.label.size.height*0.8)
        let m = CORNER_RAD
        let left = r.origin.x + m
        let right = left + r.width - 2*m
        let bottom = r.origin.y + m
        let top = bottom + r.height - 2*m
        _ = _hooks[.TL]!.pos(left,top)
        _ = _hooks[.TR]!.pos(right,top)
        _ = _hooks[.BL]!.pos(left,bottom)
        _ = _hooks[.BR]!.pos(right,bottom)
        path = CGPath.make(rect:r,corner:m)
    }
    
    // MARK: HELPER
    // called by dragging corners
    fileprivate func __resize__(_ dx:Float32,_ dy:Float32,_ c:_Hook.Corner?){
        var pos = box.xy
        var size = box.size
        let MIN_SIZE = __min_size__
        var q = c != nil ? (c!.left ? dx : -dx) : 0
        var w = size.x + q
        if w > MIN_SIZE.x{
            pos = F2( pos.x - dx*0.5, pos.y )
            size = F2( w, size.y )
        }
        q = c != nil ? (c!.top ? -dy : dy) : 0
        w = size.y + q
        if w > MIN_SIZE.y{
            pos = F2( pos.x, pos.y - dy*0.5 )
            size = F2( size.x, w )
        }
        box.xy = pos
        box.size = size
    }
    
}

private let CORNER_RAD = CGFloat(10)
private let DEFAULT_SIZE = F2(200,150)

private class _Hook: Shape, Actor{
    enum Corner:Int{
        case TL = -1, TR = 1, BL = -2, BR = 2
        var top:Bool{ return abs(rawValue) == 1 }
        var bottom:Bool{ return abs(rawValue) == 2 }
        var left:Bool{ return rawValue < 0 }
        var right:Bool{ return rawValue > 0 }
    }
    let corner:Corner
    let line = Shape()
    init(_ c:Corner){
        corner = c
        super.init()
        let m = CORNER_RAD
        path = CGPath.make(radius:m)
        let p = CGMutablePath()
        switch c{
        case .TL: _ = p.move(CGPoint(x:-m,y:0)).quad(CGPoint(x:0,y:m),CGPoint(x:-m,y:m))
        case .TR: _ = p.move(CGPoint(x:0,y:m)).quad(CGPoint(x:m,y:0),CGPoint(x:m,y:m))
        case .BL: _ = p.move(CGPoint(x:-m,y:0)).quad(CGPoint(x:0,y:-m),CGPoint(x:-m,y:-m))
        case .BR: _ = p.move(CGPoint(x:0,y:-m)).quad(CGPoint(x:m,y:0),CGPoint(x:m,y:-m))
        }
        line.path = p
        line.lineWidth = 2
        self <-- line
        fillColor = .clear
        strokeColor = .clear
        //isHidden = true
    }
    required init?(coder c: NSCoder){ fatalError() }
    func performs(_ a:Action)->Bool{
        switch a{
        case .POINT: return true
        default: return false
        }
    }
    func perform(_ action:Action,_ sc:Scene2D){
        if let a = parent as? Annot2D{
            switch action{
            case .POINT(_,let delta,_,let phase):
                switch phase{
                case .BEGIN:
                    a._state_at_ldown = (a.box.xy,a.box.size)
                    sc.pick.boxs = [a.box]
                case .DELTA:
                    let dx = -delta.x * Float32(sc.cam.xScale)
                    let dy = delta.y * Float32(sc.cam.yScale)
                    a.__resize__(dx,dy,corner)
                case .END: // UNDO only at end of drag !
                    let old = a._state_at_ldown!
                    let new = (a.box.xy,a.box.size)
                    if (new.0 != old.0) || (new.1 != old.1){
                        sc.undoableSize(a.box,from:old,to:new)
                    }
                }
            default: break
            }
        }
    }
}
