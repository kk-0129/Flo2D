// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class InOut2D : Named2D{
    
    private static let MINW = UNIT
    
    // MARK: INIT
    
    init(_ box:Box){
        is_input = box.kind == .INPUT
        type_label = Label(T.BOOL().s$,A$(0.65,[]))
            .z(0.1)
            .h(is_input ? .left : .right)
            .alpha(0.7)
        super.init(box,is_input ? .right : .left,A$(1.2,[.bold]),InOut2D.MINW + UNIT*0.5)
        self <-- type_label
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    private let is_input:Bool
    private let type_label:Label
    
    // MARK: Observer
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        super.observed(f,slots)
        for id in slots{
            switch id{
            case .rgba:
                let c = Colors(Color(box.rgba))
                fillColor = c.bg
                ((label is Label) ? (label as! Label) : (label as! ELabel).label).fontcolor = c.fg
                type_label.fontcolor = c.fg
            case .inputs: _update_type_labels()
            case .outputs: _update_type_labels()
            default: break
            }
        }
    }
    
    // MARK: PATH
    
    override func recalculatePath(){
        //guard label != nil else{ return }
        var w = __label_width__
        let W = max(w,InOut2D.MINW) + UNIT*1.1
        let r = CGRect(size:CGSize(width:W,height:UNIT*0.7))
        w *= 0.5
        path = Shape.bullet(r,is_input ? .right : .left)
        label.position = CGPoint(x:is_input ? r.origin.x + r.width - 12 - w : r.origin.x + 15 + w, y:0)
        _update_type_labels(r)
        layout_all_the_dots()
    }
    
    private func _update_type_labels(_ r:CGRect){
        let x = r.origin.x
        _ = type_label.pos(is_input ? x + 10 : x + r.width - 10,0)
        _update_type_labels()
    }
    
    private func _update_type_labels(){
        let t:T = is_input ? box.outputs[Dot.ANON$]! : box.inputs[Dot.ANON$]!
        type_label.string = t.s$
        //unit_label.string = u
    }
    
    override func layout_all_the_dots(){
        if let r = path?.boundingBox{
            let x = r.origin.x
            let y = r.midY
            switch box.kind{
            case .INPUT: if !outputs.isEmpty{ outputs[0].position = CGPoint(x:x+r.width+3,y:y) }
            case .OUTPUT: if !inputs.isEmpty{ inputs[0].position = CGPoint(x:x-3,y:y) }
            default: break
            }
        }
        super.layout_all_the_dots() // updates incoming/outgoing arcs
    }
    
    private var __can_change_type__:Bool{
        if is_input{
            if !box.outgoingArcs.isEmpty{ return false }
            if let ins = box.parent.parent?.incomingArcs{
                if ins.contains(where:{$0.dst.dotID == box.name}){ return false }
            }
        }else{ // = output
            if !box.incomingArcs.isEmpty{ return false }
            if let outs = box.parent.parent?.outgoingArcs{
                if outs.contains(where:{$0.src.dotID == box.name}){ return false }
            }
        }
        return true
    }
    
    // MARK: POPUP
    override func willDisplayPopup(_ p:Popup,in sc:Scene2D){
        let old = (is_input ? box.outputs[Dot.ANON$] : box.inputs[Dot.ANON$])!
        if __can_change_type__{
            var is_array = false
            var base_type = old
            switch old{
            case .ARRAY(let t): is_array = true; base_type = t
            default: break
            }
            p.add(.ACTION(
                is_array ? _$_.ArrayOn : _$_.ArrayOff,
                .IO_TYPE(box,(is_array ? base_type : .ARRAY(base_type)))
            ))
            var ts = [T]()
            switch base_type{
            case .BOOL: ts = [.DATA,.FLOAT(),.STRING()]
            case .DATA: ts = [.BOOL(),.FLOAT(),.STRING()]
            case .FLOAT: ts = [.BOOL(),.DATA,.STRING()]
            case .STRING: ts = [.BOOL(),.DATA,.FLOAT()]
            default: ts = [.BOOL(),.DATA,.FLOAT(),.STRING()]
            }
            for t in ts{
                p.add(.ACTION(
                    _$_.TName(t),
                    .IO_TYPE(box,(is_array ? .ARRAY(t) : t))
                ))
            }
            let __structs__ = Popup(p.position)
            __structs__.add(.SUBMENU(_$_.Back,p))
            for (name,t) in Struct.types{
                __structs__.add(.ACTION(
                    name,
                    .IO_TYPE(box,(is_array ? .ARRAY(t) : t))
                ))
            }
            if !__structs__.isEmpty{
                p.add(.SUBMENU(_$_.Structs,__structs__))
            }
        }else{
            p.add(.DISABLED(_$_.TName(old)))
        }
    }
    
}

extension Shape{
    static func bullet(_ r:CGRect, _ a:Hᴬ)->CGPath{
        let o = r.origin
        let w = r.width
        let h = r.height
        let cr = min(w, h*0.5) // corner radius
        if a == .left{
            return CGMutablePath()
                .move(o + CGPoint(x:cr,y:h)) // top left
                .quad(o + CGPoint(x:0,y:h-cr), o + CGPoint(x:0,y:h))
                .line(o + CGPoint(x:0,y:cr))
                .quad(o + CGPoint(x:cr,y:0), o + CGPoint.zero)
                .line(o + CGPoint(x:w,y:0))
                .line(o + CGPoint(x:w,y:h))
                .closed
        }else{
            return CGMutablePath()
                .move(o + CGPoint(x:0,y:h)) // top left
                .line(o + CGPoint(x:w-cr,y:h))
                .quad(o + CGPoint(x:w,y:h-cr), o + CGPoint(x:w,y:h))
                .line(o + CGPoint(x:w,y:cr))
                .quad(o + CGPoint(x:w-cr,y:0), o + CGPoint(x:w,y:0))
                .line(o)
                .closed
        }
    }
}
