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

class Arc2D : Curve2D, Actor, Frame.Observer{
    
    // MARK: INIT
    init(_ a:Arc,_ sc:Scene2D){
        let s = sc.dot2d(for:a.src)
        let d = sc.dot2d(for:a.dst)
        if let s = s, let d = d{
            arc = a
            src = s
            dst = d
            super.init()
            colors = Colors(sc.backgroundColor)
            (src.parent as! Box2D).box.observers.add(self)
            (dst.parent as! Box2D).box.observers.add(self)
            endpointsUpdate()
            notify_redraw()
        }else{
            if s == nil{ __log__.err("did not find SCR: \(a.src.boxID).\(a.src.dotID)") }
            if d == nil{ __log__.err("did not find DST: \(a.dst.boxID).\(a.dst.dotID)") }
            for b in sc.box2Ds{
                __log__.err("Box2D: \(b.box.id)")
                for d in b.dots{
                    __log__.err("   dot: \(d.dot.dotID)")
                }
            }
            fatalError()
        }
    }
    required init?(coder c: NSCoder){ fatalError() }
    
    override func removeFromParent(){
        super.removeFromParent()
        (src.parent as? Box2D)?.box.observers.rem(self)
        (dst.parent as? Box2D)?.box.observers.rem(self)
    }
    
    // MARK: VARS
    let src,dst:Dot2D
    let arc:Arc
    
    // MARK: NOTIFICATIONS
    // the arc listens to its src & dst boxes !!
    func observed(_ f:Frame,_ slots:[Slot.ID]){
        for id in slots{
            if id == .xy{ endpointsUpdate() }
        }
    }
    
    func endpointsUpdate(){
        zPosition = min(src.zPositionInScene,dst.zPositionInScene) - 1
        endpoints = ((src.positionInScene,src.dir),(dst.positionInScene,dst.dir))
    }
    
    // MARK: Actor
    
    func performs(_ a:Action)->Bool{
        switch a{
        case .POINT(_,_,_,let phase): return phase == .BEGIN
        case .POPUP: return true
        default: return false
        }
    }
    func perform(_ action:Action,_ sc:Scene2D){
        switch action{
        case .POINT(_,_,_,let phase):
            if phase == .BEGIN{ __pick_me__(sc) }
        case .POPUP(let locator):
            __pick_me__(sc)
            let ROOT = Popup(locator(self))
            ROOT.add(.ACTION(_$_.Delete,.CAP(.DELETE)))
            sc.popup = ROOT
        default: break
        }
    }
    private func __pick_me__(_ sc:Scene2D){
        let p = sc.pick
        p.clear()
        p.arcs.insert( arc )
    }
    
}

extension Scene2D{
    
    func dot2d(for dot:Dot)->Dot2D?{
        for b in box2Ds{
            if let d = b.dots.first(where:{$0.dot==dot}){ return d }
        }
        return nil
    }
    
}
