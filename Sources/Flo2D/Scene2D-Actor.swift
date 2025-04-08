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
import FloGraph
import FloBox

public enum Action{
    public enum Phase{ case BEGIN,DELTA,END }
    public enum Modifier{ case SHIFT, OPTION, COMMAND }
    public typealias Locator = (SKNode?)->(CGPoint)
    case SCROLL(CGSize?) // translation
    case MAGNIFY(Locator,Float32?) // location & magnification
    case POINT(Locator,F2,Set<Modifier>,Phase)
    case ADD_BOX(Box.Kind,CGPoint?=nil,(Device.Proxy,Skin)?=nil)
    case COLORS
    case KEY(Character,Set<Modifier>)
    case CAP(CapAction)
    case POPUP(Locator) // location
    case IO_TYPE(Box,T)
    case PUBLISH(Graph,Bool)
    case META(Struct)
}

public protocol Actor{
    func performs(_ a:Action)->Bool
    func perform(_ a:Action,_ sc:Scene2D)
}

let MIN_ZOOM = CGFloat(0.25)
let MAX_ZOOM = CGFloat(4.5)

public extension Scene2D{
    
    func canPerform(_ action:Action)->Bool{
        switch action{
        case .CAP(let cap): return __can_perform__(cap:cap)
        default: return true
        }
    }
    
    func perform(_ action:Action){
        color_changer = nil
        switch action{
        case .POINT(let locator,let delta,let modifiers,let phase):
            switch phase{
            case .BEGIN:
                #if os(macOS)
                view?.window?.makeKeyAndOrderFront(self)
                #endif
                __paste_position__ = locator(self)
                __actor__ = __actor__(at:__paste_position__)
                if let el = __actor__ as? ELabel{
                    pick.clear()
                    el.perform(action,self)
                    return
                }
                __bubble__ = nil
                editor.eLabel = nil
                if let n = (__actor__ as? SKNode)?.handler(for:action){
                    n.perform(action,self)
                    return // handled by handler
                }else{
                    if delta.x == 2{ // x = click count
                        if modifiers.isEmpty{
                            if let p = focus.parent?.parent{
                                undoableFocus(old:focus,new:p)
                            }
                        }else{
                            undoablePoV(_$_.PoV,of:focus,from:cam.pov,to:F3.defaultPOV)
                        }
                    }
                }
                popup = nil
                if !modifiers.contains(.SHIFT){ pick.clear() }
            case .DELTA:
                if let n = (__actor__ as? SKNode)?.handler(for:action),!(n is Scene2D){
                    n.perform(action,self)
                }else if cam.dragband(locator(self)){ // first drag
                    if modifiers.contains(.SHIFT){
                        __selected_boxes_at_start_of_dragband__ = Set<Box>(box2Ds.filter({$0.picked}).map{$0.box})
                    }
                }else if let r = cam.updateBand(){
                    var boxs = Set<Box>( box2Ds.filter({$0.bodyrect.intersects(r)}).map({$0.box}) )
                    if let bs = __selected_boxes_at_start_of_dragband__{ // only set for modifier.shift
                        boxs = bs.symmetricDifference(bs)
                    }
                    pick.boxs = boxs
                }else{
                    __selected_boxes_at_start_of_dragband__ = nil
                }
            case .END:
                _ = cam.dragband(nil)
                __selected_boxes_at_start_of_dragband__ = nil
                if let n = (__actor__ as? SKNode)?.handler(for:action){
                    n.perform(action,self)
                }
                __actor__ = nil
            }
        case .SCROLL(let translation):
            if popup != nil{ return }
            if let tx = translation{
                if __initial_pov__ == nil{ __initial_pov__ = cam.pov }
                let pov = cam.pov
                let x = pov.x - (Float32(tx.width) * pov.z)
                let y = pov.y + (Float32(tx.height) * pov.z)
                focus.pov = F3(x,y,pov.z)
            }else if let old = __initial_pov__{
                undoablePoV(_$_.Scroll,of:focus,from:old,to:focus.pov)
                __initial_pov__ = nil
            }
        case .MAGNIFY(let locator,let magnification):
            if popup != nil{ return }
            if let mag = magnification{
                if __initial_pov__ == nil{ __initial_pov__ = cam.pov }
                let pov = cam.pov
                let oldP = CGPoint(x:CGFloat(pov.x),y:CGFloat(pov.y))
                let offP = locator(self) - oldP
                let oldZ = CGFloat(pov.z)
                var newZ = oldZ * CGFloat(1 - mag)
                if newZ < MIN_ZOOM{ newZ = MIN_ZOOM }
                else if newZ > MAX_ZOOM{ newZ = MAX_ZOOM }
                let rat = oldZ / newZ
                let new_offP = CGPoint(x:offP.x * rat,y:offP.y * rat)
                let newP = oldP + new_offP - offP
                focus.pov = F3(Float32(newP.x),Float32(newP.y),Float32(newZ))
            }else if let old = __initial_pov__{ // onEnd
                undoablePoV(_$_.Zoom,of:focus,from:old,to:focus.pov)
                __initial_pov__ = nil
            }
        case .COLORS:
            if Color.picker != nil{
                let boxs = pick.boxs.filter({$0.has(.rgba)})
                self.color_changer = ColorChanger(self,boxs)
            }
        case .ADD_BOX(let kind,let pt,let px):
            let pt = pt ?? __paste_position__
            let slots:Slots = [.xy:pt.f2]
            let box:Box?
            if kind == .PROXY{
                if let (proxy,skin) = px{
                    box = Box(proxy:proxy.uuid,skin,slots)
                }else{ __log__.warn("ADD_BOX(.PROXY): no Proxy/Skin"); return }
            }else{
                box = Box(kind,slots)
            }
            if let box = box{ self.undoableAdd(pick:Pick([box])) }
        case .CAP(let cap):
            __perform__(cap:cap)
        case .KEY(let key,_):
            if editor.eLabel != nil{ editor.perform(action,false) }
            else{
                switch key{
                case Scene2D.ADD_BOX_Key: perform(.ADD_BOX(.GRAPH))
                case Scene2D.ADD_INPUT_Key: perform(.ADD_BOX(.INPUT))
                case Scene2D.ADD_OUTPUT_Key: perform(.ADD_BOX(.OUTPUT))
                case Scene2D.ADD_ANNOT_Key: perform(.ADD_BOX(.ANNOT))
                case Scene2D.ADD_CLOCK_Key: perform(.ADD_BOX(.CLOCK))
                case Scene2D.ADD_EXPR_Key: perform(.ADD_BOX(.EXPR))
                case Scene2D.ADD_METER_Key: perform(.ADD_BOX(.METER))
                case Scene2D.ADD_SWITCH_Key: perform(.ADD_BOX(.SWITCH))
                case Scene2D.ADD_TEXT_Key: perform(.ADD_BOX(.TEXT))
                case Scene2D.ADD_IMU_Key: perform(.ADD_BOX(.IMU))
                case Scene2D.ADD_HISTO_Key: perform(.ADD_BOX(.HISTO))
                case Scene2D.BackspaceKey: perform(.CAP(.DELETE))
                case Scene2D.LeftArrowKey: break
                case Scene2D.RightArrowKey: break
                case Scene2D.SpacebarKey: perform(.COLORS)
                case Scene2D.ADD_PROXY_Key: popup = popup(proxies:__paste_position__,nil)
                case Scene2D.ADD_WIJI_Key: popup = popup(wijis:__paste_position__,nil)
                //case Scene2D.ManageDevicesKey: calloutToManageDevices?()
                default:break
                }
            }
        case .POPUP(let locator): // CONTEXT MENU
            __paste_position__ = locator(self)
            __actor__ = __actor__(at:__paste_position__)
            if let n = (__actor__ as? SKNode)?.handler(for:action),!(n is Scene2D){
                if let b = n as? Box2D,!pick.boxs.contains(b.box){ pick.boxs = [b.box] }
                n.perform(action,self)
            }else{
                __bubble__ = nil
                popup = popup(root:__paste_position__)
            }
        case .IO_TYPE(let box,let new_type):
            let old:T = (box.kind == .INPUT ? box.outputs[Dot.ANON$] : box.inputs[Dot.ANON$])!
            undoableDotType(box,old,new_type)
        case .PUBLISH(let graph,_): 
            undoablePublish(graph)
        case .META(let m):
            __log__.info(m.s$)
        }
    }
    
    // MARK: HELPERS
    
    private func __actor__(at p:CGPoint)->Actor?{
        let hs = hits(p,p).sorted(by:{$0.az > $1.az})
        for h in hs{
            if let x = h as? Actor, !(x is Scene2D){ return x }
        }
        return nil
    }
    
}
