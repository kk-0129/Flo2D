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

class Meter2D : Box2D{
    
    // MARK: STATICS
    
    private static let _w = (lo:-WIDTH*0.6,rad:WIDTH*1.1,rad2:WIDTH*1.03)
    private static let _path = CGMutablePath()
        .arc(CGPoint.zero,WIDTH,π,0,true)
        .line(CGPoint(x:WIDTH*0.6,y:0))
        .arc(CGPoint.zero,WIDTH*0.6,0,π,false)
        .closed
    private static let _clickable_area = CGMutablePath()
        .arc(CGPoint.zero,_w.rad,π,0,true)
        .line(CGPoint(x:_w.rad,y:_w.lo))
        .line(CGPoint(x:-_w.rad,y:_w.lo))
        .closed
    private static let _dragable_area = CGMutablePath()
        .arc(CGPoint.zero,_w.rad,π,0,true)
        .closed
    private static let _needle = CGMutablePath()
        .arc(CGPoint.zero,WIDTH*0.1,π*0.7,π*0.3,false)
        .line(CGPoint(x:0,y:WIDTH*0.9))
        .closed
    private static let _handle = CGMutablePath()
        .arc(CGPoint.zero,WIDTH,π,0,true)
        .arc(CGPoint(x:WIDTH*0.5,y:0),WIDTH*0.5,0,-π*0.5,true)
        .line(CGPoint(x:-WIDTH*0.5,y:-WIDTH*0.5))
        .arc(CGPoint(x:-WIDTH*0.5,y:0),WIDTH*0.5,-π*0.5,-π,true)
        .closed
    
    // MARK: INIT
    
    override init(_ box:Box){
        sign = Label("+",A$(0.4,[]))
        number = Label("0.0",A$(0.6,[]))
        needle = Shape(Meter2D._needle).z(0.011)
        handle = Shape(Meter2D._handle).z(0.011)
        super.init(box)
        path = Meter2D._path
        let p = CGPoint(x:-(WIDTH*1.1),y:-(WIDTH*0.4))
        self <-- handle
        self <-- sign.pos(p.x+25,p.y+2).v(.baseline).h(.right).z(0.1)
        self <-- number.pos(0,p.y).v(.baseline).h(.center).z(0.1)
        self <-- needle
        sign.isHidden = true
        number.isHidden = true
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    
    override var __hit_path__:CGPath?{ return Meter2D._clickable_area }
    private let sign,number:Label
    private let needle,handle:Shape
    private var __value_at_drag_start__:Float32?{ didSet{ __update_emphasis__() }}
    
    // MARK: OBSERVER
    
    override func notify_redraw(){
        fillColor = colors.avg
        needle.strokeColor = colors.fg
        needle.fillColor = colors.fg
        handle.fillColor = .clear
        handle.strokeColor = fillColor
        handle.alpha = 0.5
        let x = colors.fg.alpha(0.8)
        sign.fontcolor = x
        number.fontcolor = x
        super.notify_redraw()
        __update_emphasis__()
    }
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        for id in slots{
            switch id{
            case .metric:
                let val = box.metric
                let v = _box_val_to_dial_val(val) // normalised to -1 .. +1
                needle.zRotation = -(CGFloat(v)*π_2)
                let (s,f) = val.string(7)
                sign.string = (s != nil ? s! : " ")
                number.string = f
                /*
                 case .flip
                 if !dots.isEmpty, let f = slots[.flip] as? [Bool],f.count == 2{
                 dots[0].dir = f[0] ? .top : .left
                 dots[1].dir = f[1] ? .bottom : .right
                 poser.pose(dots,dotBounds)
                 updateArcEndpoints()
                 }
                 super.notify(slots:slots,"Meter.notify")
                 */
            default: break
            }
        }
        super.observed(f,slots)
    }
    
    // MARK: DOT POSTIONS
    override func layout_all_the_dots(){
        let x = WIDTH * 1.05
        for d in [inputs[0],outputs[0]]{
            switch d.dir{
            case .left: d.position = CGPoint(x:-x,y:0)
            case .right: d.position = CGPoint(x:x,y:0)
            case .top: d.position = CGPoint(x:0,y:x+1)
            case .bottom: d.position = CGPoint(x:0,y:-x*0.7)
            case .unknown: break
            }
        }
        super.layout_all_the_dots() // updates incoming/outgoing arcs
    }
    
    // MARK: Actor
    
    override func performs(_ action:Action)->Bool{
        switch action{
        case .POINT: return true
        default: return false
        }
    }
    override func perform(_ action:Action, _ sc:Scene2D){
        switch action{
        case .POINT(let locator,let delta,let modifiers,let phase):
            switch phase{
            case .BEGIN:
                if Meter2D._dragable_area.contains(locator(self)){
                    __value_at_drag_start__ = box.metric
                }else{ super.perform(action,sc) }
            case .DELTA:
                if box.incomingArcs.isEmpty, __value_at_drag_start__ != nil{
                    var dy:Float32 = 0.01
                    if modifiers.contains(.OPTION){ dy *= 0.1 }
                    if modifiers.contains(.SHIFT){ dy *= 0.1 }
                    _change_value(by:Float32(delta.y)*dy)
                }else{ super.perform(action,sc) }
            case .END:
                if let old = __value_at_drag_start__{
                    _undoable_change_value(from:old,to:box.metric)
                    __value_at_drag_start__ = nil
                }else{ super.perform(action,sc) }
            }
       /* case .rotate:
            if e.modifier(.option) || e.modifier(.shift){
                let old = flips
                if e.rotation < -1{
                    if e.modifier(.option){ flips = (old.0,true) }
                    else{ flips = (true,old.1) }
                }else if e.rotation > 1{
                    if e.modifier(.option){ flips = (old.0,false) }
                    else{ flips = (false,old.1) }
                }
            }else{
                __change_box_value__(by: Float32(e.rotation)*0.1)
            }*/
        default: break
        }
    }
    
    // MARK: HELPER
    
    private func __update_emphasis__(){
        let emphasis = __value_at_drag_start__ != nil || picked
        sign.isHidden = !emphasis
        number.isHidden = !emphasis
    }
    
    func _change_value(by dy:Float32){
        let f = _dial_val_to_box_val( (_box_val_to_dial_val(box.metric) - dy).clip(-1,1) )
        box.metric = f
    }
    
    func _undoable_change_value(from old:Float32,to new:Float32){
        box.metric = new
        (scene as! Scene2D).undoer.add(undo:_$_.Meter){
            self._undoable_change_value(from:new,to:old)
        }
    }
    private var lo:Float32{
        return (box.params[Box.Keys.min$]?.dv as? Float32) ?? Float32(-1)
    }
    private var hi:Float32{
        return (box.params[Box.Keys.max$]?.dv as? Float32) ?? Float32(-1)
    }
    private func _dial_val_to_box_val(_ f:Float32)->Float32{
        return lo+((f+1)*(hi-lo)/2)
    }
    private func _box_val_to_dial_val(_ f:Float32)->Float32{
        return (2*(f-lo)/(hi-lo))-1
    }
    
}

// MARK: Float32 +
public extension Float32{
    func string(_ prec:Int)->(String?,String){
        var _sign:String?
        var _digits = " "
        if isNaN{ _digits = "NaN" }
        else if isInfinite{ _digits = "∞" }
        else{
            if self < 0{ _sign = "−" }
            let abs_v = abs(self)
            let n = prec - "\(Int(abs_v))".count
            _digits = String(format: "%.\(n)f", abs_v)
        }
        return (_sign,_digits)
    }
}

