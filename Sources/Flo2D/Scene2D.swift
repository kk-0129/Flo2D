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

extension SKView{
    #if os(macOS)
    override public var inLiveResize:Bool{ return false }
    #endif
}

let  blur = CIFilter(name:"CIGaussianBlur",parameters:["inputRadius":5.0])

open class Scene2D: SKScene, Box.Observer{
    
    public var PICK_CHANGE = 0
    
    //public var calloutToManageDevices:(()->())?
    //public var calloutToManageStructs:(()->())?
    
    // MARK: STATICS
    public static var pasteboard:Pasteboard = __DefaultPasteboard__()
    
    // MARK: INIT
    public init(hub:Hub){
        self.root = Graph()
        root.hub = hub
        self.focus = root
        self.cam = Camera()
        let p = CGMutablePath()
            .move(CGPoint(x:-10,y:0))
            .line(CGPoint(x:10,y:0))
            .move(CGPoint(x:0,y:-10))
            .line(CGPoint(x:0,y:10))
        crosshairs = Shape(p)
        ROOT = SKEffectNode()
        super.init(size:CGSize(width: 1000,height: 1000))
        pick.scene = self
        anchorPoint = CGPoint(x:0.5,y:0.5)
        scaleMode = .resizeFill
        
        camera = cam
        self <-- [cam,ROOT]
        ROOT <-- [__dragged_curve__.alpha(0),crosshairs.alpha(0.5)]
        
        ROOT.filter = blur
        ROOT.shouldRasterize = true
        ROOT.shouldEnableEffects = false
        
        let n = SKNode()
        n.run(.repeatForever(.rotate(byAngle:1,duration:1)))
        ROOT <-- n
        
        __focus_changed__(from:nil,to:focus)
    }
    required public init?(coder c:NSCoder){ fatalError() }
    
    deinit{ __log__.debug("scene de-inited :D") }
    
    open override func willMove(from v:SKView){
        super.willMove(from:v)
        root.observers.rem(self)
        pick.scene = nil
        color_changer = nil
        root.hub = nil
    }
    
    open override func didMove(to v:SKView){
        super.didMove(to:v)
        hub.running = true
    }
    
    // MARK: Colors
    var color_changer : ColorChanger?{ didSet{
        Color.picker?.callback = (color_changer != nil) ? { c in
            self.color_changer!.__perform__(c)
        } : nil
    }}
    
    // MARK: serialise
    public func serialise()->Data{
        return CIO.cached{ Ω in
            root.™(Ω)
            focus.id.™(Ω)
            return Data(Ω.bytes)
        }
    }
    public func deserialise(from data:Data)throws{
        let hub = hub
        let (r,f) = try CIO.cached_{ Ω in
            Ω.write([UInt8](data))
            return (try Graph.™(Ω),try Frame.ID.™(Ω))
        }
        root = r
        root.hub = hub
        focus = root.locate(graph:f) ?? root
    }
    
    //MARK: KEY VARS
    public var hub:Hub{ return root.hub! }
    let ROOT:SKEffectNode
    let cam:Camera
    let editor = Editor()
    var box2Ds:Set<Box2D>{ return Set<Box2D>(ROOT.children.filter({$0 is Box2D}) as! [Box2D]) }
    var arc2Ds:[Arc2D]{ return ROOT.children.filter({$0 is Arc2D}) as! [Arc2D] }
    public var undoer:Undoer = __EMPTY_UNDOER__()
    let crosshairs:Shape
    
    //MARK: HELPER VARS
    var __initial_pov__:F3?
    var __paste_position__ = CGPoint.zero{ didSet{ crosshairs.position = __paste_position__ }}
    var __actor__: Actor?
    var __bubble__:Shape?{ didSet{
        if let b = oldValue{ b.removeFromParent() }
        if let b = __bubble__{ ROOT <-- b }
    }}
    var __selected_boxes_at_start_of_dragband__:Set<Box>?
    let __dragged_curve__ = Curve2D(true)
    
    // MARK: POPUPS
    private var _old_pov_ = (CGPoint.zero,CGFloat(0))
    var popup:Popup?{ didSet{
        __popup__ = popup != nil ? MyPopup(popup!) : nil
    }}
    private var __popup__:MyPopup?{ didSet{
        //ROOT.shouldEnableEffects = __popup__ != nil
        oldValue?.removeFromParent()
        if let b = __popup__{
            b.colors = colors
            let p = b.position
            __paste_position__ = p
            b.position = self.convert(p,to:cam)
            cam <-- b
        }
    }}
            
    
    // MARK: FOCUS
    var root:Graph
    var focus:Graph{ didSet{ __focus_changed__(from:oldValue,to:focus) }}
    private func __focus_changed__(from old:Graph?,to new:Graph){
        if let old = old{ old.observers.rem(self) }
        observed(new,[.pov,.rgba,.boxs,.arcs])
        new.observers.add(self)  
    }
    
    // MARK: colors
    var colors = Colors(F4.random){ didSet{
        backgroundColor = colors.bg
        for c in ROOT.children.filter({$0 is Shape}){
            (c as! Shape).colors = colors
        }
    }}
    
    // MARK: frame observer ...
    public func observed(_ f:Frame,_ slots:[Slot.ID]){
        var arcs_changed = false
        for id in slots{
            switch id{
            case .pov: cam.pov = focus.pov
            case .rgba: colors = Colors(focus.rgba)
            case .boxs:
                let old = Set<Box>(box2Ds.map({$0.box}))
                let new = focus.boxs
                for b in old.subtracting(new){
                    box2Ds.first(where:{$0.box==b})?.removeFromParent()
                }
                var added = Set<Box2D>()
                for b in new.subtracting(old){
                    let x = b.box2d
                    added.insert(x)
                    ROOT <-- x
                }
                __bring_to_front__(added)
            case .arcs: arcs_changed = true
            default: break
            }
        }
        if arcs_changed{
            let old = Set<Arc>(arc2Ds.map({$0.arc}))
            let new = focus.arcs
            for a in old.subtracting(new){
                if let x = arc2Ds.first(where:{$0.arc==a}), x.parent != nil{
                    x.removeFromParent()
                }
            }
            for a in new.subtracting(old){
                ROOT <-- Arc2D(a,self)
            }
        }
    }
    
    // MARK: PICK
    
    var pick = Pick()
    func __pick_changed__(){
        let new_boxs = pick.boxs
        for b in box2Ds{ b.picked = new_boxs.contains(b.box) }
        let new_arcs = pick.arcs
        for a in arc2Ds{ a.picked = new_arcs.contains(a.arc) }
        __bring_to_front__(box2Ds.filter{$0.picked})
        PICK_CHANGE += 1
    }
    func arcs(for bs:Set<Box>,_ strict:Bool)->Set<Arc>{
        var _arcs = Set<Arc>()
        for a in focus.arcs{
            let src = bs.contains(where:{ $0.id == a.src.boxID })
            let dst = bs.contains(where:{ $0.id == a.dst.boxID })
            if strict{ if src && dst{ _arcs.insert(a) } }
            else{ if src || dst{ _arcs.insert(a) } }
        }
        return _arcs
    }
    
    func __bring_to_front__(_ front:Set<Box2D>){
        let backs = Set<Box2D>(box2Ds).subtracting(front).sorted(by:{$0.zPosition < $1.zPosition})
        for i in 0..<backs.count{ backs[i].zPosition = CGFloat(i) }
        let fronts = front.sorted(by:{$0.zPosition < $1.zPosition})
        for i in 0..<fronts.count{ fronts[i].zPosition = CGFloat(backs.count + i) }
    }
    
    // MARK: dragged curve
    
    func draggedCurve(pts:((CGPoint,Dot2D.Dir),(CGPoint,Dot2D.Dir))?){
        __dragged_curve__.endpoints = pts
        __dragged_curve__.alpha = pts != nil ? 1 : 0
        //changes.arcs = true
    }
    
}

struct __EMPTY_UNDOER__:Undoer{
    func add(undo n:String,_ cb:@escaping ()->()){
        // DO NOTHING
    }
}
