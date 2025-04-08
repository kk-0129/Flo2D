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
import FloBox

public protocol Undoer{
    func add(undo name:String,_ cb:@escaping ()->())
}

extension Scene2D{
    
    // MARK: FOCUS
    
    func undoableFocus(old:Graph,new:Graph){
        self.focus = new
        undoer.add(undo:_$_.Focus){ [weak self] in
            self?.undoableFocus(old:new,new:old)
        }
    }
    
    // MARK: Graph
    
    func undoablePublish(_ g:Graph){
        g.published = !g.published
        undoer.add(undo:g.published ? _$_.Publish : _$_.Unpublish){
            [weak self] in
            self?.undoablePublish(g)
        }
    }
    
    func undoablePoV(_ s:String,of g:Graph,from old:F3,to new:F3){
        if new != old{
            g.pov = new
            undoer.add(undo:s){ [weak self] in
                self?.undoablePoV(s,of:g,from:new,to:old)
            }
        }
    }
    
    // MARK: Wijis
    
    func undoableExpr(_ b:Box,from old:ParsedExpr,to new:ParsedExpr){
        if b.kind == .EXPR{
            __undoable_expr__(b,old,new,Set<Arc>(),Set<Arc>())
        }
    }
    
    func __undoable_expr__(
        _ b:Box,
        _ old:ParsedExpr,
        _ new:ParsedExpr,
        _ arcs_to_delete:Set<Arc>,
        _ arcs_to_add:Set<Arc>){
        if b.kind == .EXPR{
            let g = b.parent
            g.arcs.subtract(arcs_to_delete)
            let deleted_arcs = b.set(pex:new) // PEX requires NO incoming|outgoing arcs!
            g.arcs.formUnion(arcs_to_add)
            undoer.add(undo:_$_.Expr){ [weak self] in
                self?.__undoable_expr__(b,new,old,arcs_to_add,deleted_arcs)
            }
        }
    }
    
    func undoableOnOff(_ s:Box){
        s.on = !s.on
        undoer.add(undo:_$_.Switch){ [weak self] in
            self?.undoableOnOff(s)
        }
    }
    
    func undoableMetric(_ m:Box,from old:Float32,to new:Float32){
        m.metric = new
        undoer.add(undo:_$_.Meter){
            self.undoableMetric(m,from:new,to:old)
        }
    }
    
    func undoableName(_ b:Box,from old:String,to new:String){
        b.name = new
        undoer.add(undo:_$_.Name){
            self.undoableName(b,from:new,to:old)
        }
    }
    
    func undoableSize(_ a:Box,from old:(F2,F2),to new:(F2,F2)){
        a.xy = new.0
        a.size = new.1
        undoer.add(undo:_$_.Size){ [weak self] in
            self?.undoableSize(a,from:new,to:old)
        }
    }
    
    // MARK: IO Dot Type
    
    func undoableDotType(_ b:Box,_ old:T,_ new:T){
        // TODO: remove any connected arcs !!
        switch b.kind{
        case .INPUT: b.outputs = [Dot.ANON$:new]
        case .OUTPUT: b.inputs = [Dot.ANON$:new]
        default: fatalError()
        }
        undoer.add(undo:_$_.IOType){ [weak self] in
            self?.undoableDotType(b,new,old)
        }
    }
    
    // MARK: Param Values
    
    func undoableParamValue(_ b:Box,_ d:Dot.ID,to v:any Event.Value){
        // TODO:
        let old = b.params
        var new = old
        new[d] = old[d]!.copy(dv:v)
        __change_params__(b,old,new)
    }
    private func __change_params__(_ b:Box,_ old:Ports,_ new:Ports){
        b.params = new
        undoer.add(undo:_$_.Params){ [weak self] in
            self?.__change_params__(b,new,old)
        }
    }
    
    // MARK: XY & RGBA
    
    func undoableXY(_ boxs:[Box],from old:[F2],to new:[F2]){
        __undoable_change__(.xy,of:boxs,from:old,to:new)
    }
    
    func undoableRGBA(_ boxs:[Box],from old:[F4],to new:[F4]){
        __undoable_change__(.rgba,of:boxs,from:old,to:new)
    }
    
    private func __undoable_change__<X:Slot.Value>(_ id:Slot.ID,of boxs:[Box],from old:[X],to new:[X]){
        guard __validate_counts__(boxs.count,old.count,new.count)else{ fatalError() }
        if boxs.isEmpty{
            focus[id] = new[0]
        }else{
            for i in 0..<boxs.count{
                switch id{
                case .xy: boxs[i].xy = new[i] as! F2
                case .rgba: boxs[i].rgba = new[i] as! F4
                default:fatalError()
                }
            }
        }
        var s = "?"
        switch id{
        case .xy: s = _$_.Position
        case .rgba: s = _$_.Colour
        default: fatalError()
        }
        undoer.add(undo:_$_.Change+" \(s)"){ [weak self] in
            self?.__undoable_change__(id,of:boxs,from:new,to:old)
        }
    }
    private func __validate_counts__(_ b:Int,_ o:Int,_ n:Int)->Bool{
        return (o==n) && (b==0 ? n==1 : n==b)
    }
    
    // MARK: ADD & REMOVE PICKS
    
    func undoableAdd(pick p:Pick){
        if let added = __add__(p){
            undoer.add(undo:"add " + __action_name__(p)){ [weak self] in
                self?.undoableRemove(pick:added)
            }
        }
    }
    
    private func __add__(_ p:Pick)->Pick?{
        let boxs = p.boxs.subtracting(focus.boxs)
        let arcs = p.arcs.subtracting(focus.arcs)
        if !(boxs.isEmpty && arcs.isEmpty){
            focus.boxs.formUnion(boxs)
            focus.arcs.formUnion(arcs)
            return Pick(boxs,arcs)
        }
        return nil
    }
    
    func undoableRemove(pick p:Pick){
        if let removed = __remove__(p){
            undoer.add(undo:"remove " + __action_name__(p)){ [weak self] in
                self?.undoableAdd(pick:removed)
            }
        }
    }
    
    private func __remove__(_ p:Pick)->Pick?{
        let boxs = p.boxs.intersection(focus.boxs)
        let arcs = p.arcs.intersection(focus.arcs)
        if !(boxs.isEmpty && arcs.isEmpty){
            focus.arcs.subtract(arcs)
            focus.boxs.subtract(boxs)
            return Pick(boxs,arcs)
        }
        return nil
    }
    
    private func __action_name__(_ p:Pick)->String{
        let bs = p.boxs.count
        let es = p.arcs.count
        if bs > 0{ return es > 0 ? "selection" : (bs == 1 ? "box" : "boxes") }
        return es == 0 ? "error" : (es == 1 ? "arc" : "arcs")
    }
    
}
