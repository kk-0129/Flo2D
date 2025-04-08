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
import FloGraph
import CoreGraphics
import FloBox
import Collections

class Box2D : Shape, Box.Observer, Actor{
    
    let box:Box
    
    init(_ box:Box){
        self.box = box
        super.init()
        self.path = CGPath(
            ellipseIn:CGRect(x:-20,y:-20,width:40,height:40),
            transform:nil)
        box.observers.add(self)
    }
    required init?(coder c:NSCoder){ fatalError() }
    deinit{ box.observers.rem(self) }
    func enscened(){
        observed(box,box.ids)
        add_all_the_dots()
        notify_redraw()
    }
    
    public override func removeFromParent(){
        super.removeFromParent()
        box.observers.rem(self)
    }
    
    override func notify_redraw(){
        super.notify_redraw()
        strokeColor = colors.fg
        for d in dots{ d.colors = colors }
    }
    
    // MARK: Frame.Observer
    func observed(_ f:Frame,_ slots:[Slot.ID]){
        for id in slots{
            switch id{
            case .xy:
                position = CGPoint(box.xy)
            case .rgba:
                fillColor = Color(box.rgba)
                for d in dots{ d.box_colors = Colors(fillColor) }
            case .inputs,.outputs: add_all_the_dots()
            default: break
            }
        }
    }
    
    // MARK: DOTS
    var dots:[Dot2D]{ return inputs + outputs }
    var inputs = [Dot2D]()
    var outputs = [Dot2D]()
    func add_all_the_dots(){
        // inputs..
        var ds = [Dot2D]()
        var old = Set<Dot2D>(inputs)
        for (name,type) in box.inputs{
            if type.dv == nil{ // not nil ==> param
                if let d = old.first(where:{name==$0.dot_name && type==$0.dot_type}){
                    old.remove(d)
                    ds.append(d)
                }else{ ds.append(Dot2D(Dot(input:box.id,name),type)) }
            }
        }
        for d in old{ d.removeFromParent() }
        self.inputs = ds
        // outputs..
        old = Set<Dot2D>(outputs)
        ds = [Dot2D]()
        for (name,type) in box.outputs{
            if let d = old.first(where:{name==$0.dot_name && type==$0.dot_type}){
                old.remove(d)
                ds.append(d)
            }else{ ds.append(Dot2D(Dot(output:box.id,name),type)) }
        }
        for d in old{ d.removeFromParent() }
        self.outputs = ds
        let c = Colors(fillColor)
        for d in dots{
            d.box_colors = c
            d.colors = scene2d.colors
            if d.parent == nil{ self <-- d }
        }
        layout_all_the_dots()
    }
    func layout_all_the_dots(){
        /* override to layout the dots */
        box.xy = box.xy // will trigger endpoint updates on arcs
    }
    
    // MARK: Actor
    private var __dragged__ = false
    private var __deselect_others_if_not_dragged__ = false
    private var __initial_xy__ = F2(0,0)
    
    func performs(_ action:Action)->Bool{
        switch action{
        case .POINT,.POPUP: return true
        default: return false
        }
    }
    
    func perform(_ action:Action, _ sc:Scene2D){
        switch action{
        case .POINT(_,let delta,let modifiers,let phase): 
            switch phase{
            case .BEGIN:
                sc.__bubble__ = nil
                if Int(delta.x) == 2{
                    if let c = box.child{
                        sc.undoableFocus(old:sc.focus,new:c)
                        return
                    }else if let b = ParamEditor(box,sc){
                        let r = path!.boundingBox
                        let pt = CGPoint(x:r.origin.x + r.width*0.5,y:r.origin.y + r.height*0.85)
                        b.position = convert(pt,to:sc)
                        sc.__bubble__ = b
                        return
                    }
                }
                if modifiers.contains(.SHIFT){
                    if picked{ sc.pick.boxs.remove(box) }
                    else{ sc.pick.boxs.insert(box) }
                }else if picked{
                    __deselect_others_if_not_dragged__ = true
                }else{
                    sc.pick.boxs.removeAll()
                    sc.pick.boxs.insert(box)
                }
                for b in sc.box2Ds.filter({$0.picked}){ b.__initial_xy__ = b.box.xy }
            case .DELTA:
                __dragged__ = true
                let bs = sc.box2Ds.filter({$0.picked})
                if !bs.isEmpty{
                    let dx = CGFloat(delta.x) * sc.cam.xScale
                    let dy = CGFloat(-delta.y) * sc.cam.yScale
                    let p = CGPoint(x:dx,y:dy)
                    for b in bs{
                        b.box.xy = F2(
                            b.box.xy.x + Float32(p.x),
                            b.box.xy.y + Float32(p.y)
                        )
                    }
                }
            case .END:
                if __dragged__{
                    let bs = sc.box2Ds.filter({$0.picked})
                    if !bs.isEmpty{
                        sc.undoableXY(bs.map{$0.box},
                                          from:bs.map{ $0.__initial_xy__ },
                                          to:bs.map{ $0.box.xy })
                    }
                    __dragged__ = false
                }
            }
        case .POPUP(let locator):
            showPopup(at:locator(sc),in:sc)
        case .META(let m):
            __log__.info("BOX! \(m.s$)")
        default: break
        }
    }
    
    // MARK: POPUP
    func showPopup(at pt:CGPoint,in sc:Scene2D){
        let ROOT = Popup(pt)
        willDisplayPopup(ROOT,in:sc)
        let ops = CapAction.all.filter{sc.__can_perform__(cap: $0)}
        if !ops.isEmpty{
            let __caps__ = Popup(pt)
            __caps__.add(.SUBMENU(_$_.Back,ROOT))
            for op in ops{
                __caps__.add(.ACTION(op.name,.CAP(op)))
            }
            ROOT.add(.SUBMENU(_$_.Caps,__caps__))
        }
        if box.has(.rgba){
            ROOT.add(.ACTION(_$_.Colour,.COLORS))
        }
        ROOT.add(.ACTION(_$_.Meta,.META(box.metadata)))
        if !ROOT.items.isEmpty{ sc.popup = ROOT }
    }
    
    func willDisplayPopup(_ p:Popup,in sc:Scene2D){
        /* override to add stuff */
    }
    
}

extension OrderedDictionary where Key == String, Value == T{
    public func index(of s:String)->Int?{
        var i = 0
        for (k,_) in self{ if k == s{ return i }; i += 1 }
        return nil
    }
}
