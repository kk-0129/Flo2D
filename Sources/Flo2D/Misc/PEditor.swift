// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import SpriteKit
import FloGraph
import FloBox

class ParamEditor:Shape{
    
    static let Margin = UNIT*0.05 // margin around edge
    
    init?(_ box:Box,_ sc:Scene2D){
        var ps = [DOT]()
        for (k,v) in box.inputs{
            if v.dv != nil{ ps.append( DOT(box:box,id:k,type:v) ) }
        }
        if !ps.isEmpty{
            super.init()
            zPosition = 100000
            let c = Bubble.colors(scene: sc)
            fillColor = c.bg
            strokeColor = .clear
            for p in ps{ self <-- _Field(self,p,c.fg) }
            __draw__()
        }else{ return nil }
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    private func __draw__(){
        let cs = children
        var max_key_width = CGFloat(0)
        var max_value_width = UNIT
        var height = ParamEditor.Margin
        var _data = [(_Field,CGFloat)]()
        for f in cs.filter({ $0 is _Field }) as! [_Field]{
            let s = f.keyLabel.size
            max_key_width = max(max_key_width,s.width)
            let v = f.valueLabel.label.size
            max_value_width = max(max_value_width,v.width)
            let h = max(s.height,v.height) + ParamEditor.Margin*2
            height += h
            _data.append((f,height))
        }
        height += ParamEditor.Margin
        let size = CGSize(width:max_key_width + max_value_width + (ParamEditor.Margin * 2),height:height )
        var p = CGPoint(x:0,y:0)
        path = Bubble._top_path(size,5,&p)
        let x = ParamEditor.Margin + max_key_width - (size.width * 0.5)
        for d in _data{ d.0._layout(x,d.1,max_value_width) }
    }
    
    struct DOT{
        let box:Box
        let id:Dot.ID
        let type:T
    }

    // MARK: ■ _Field
    class _Field: Shape, ELabel.Validator{
        
        static let Height = UNIT*0.3 // margin around edge
        var keyLabel:Label{ return children[0] as! Label }
        var valueLabel:ELabel{ return children[1] as! ELabel }
        let dot:DOT
        
        fileprivate init(_ pe:ParamEditor,_ d:DOT,_ fg:Color){
            dot = d
            super.init()
            let kt = T$(d.id,A$(0.5,[],.red))
            let label = Label(kt).v(.baseline).h(.right).alpha(0.5).z(0.1)
            label.fontcolor = fg
            self <-- label
            let e$ = T$(d.type.dv!.s,A$(0.6,[],.red))
            let elabel = ELabel(
                Label(e$).v(.baseline).h(.left).pos(0,0),
                minw:100, // minimum width = will be updated on layout
                validator:self
            )
            elabel.colors(fg.contrast,fg)
            self <-- elabel
            zPosition = 0.1
            elabel.zPosition = 0.1
        }
        required init?(coder c: NSCoder){ fatalError() }
        
        // MARK: ELabel.Validator
        
        func editor(changed txt:String)->Any?{
            __redraw__()
            switch dot.type{
            case .STRING: return txt
            default: return try? Parser.parse(value:txt,type:dot.type)
            }
        }
        
        func editor(closed txt:String,validated any:Any){
            if let new = any as? any Event.Value, let sc = scene as? Scene2D{
                sc.undoableParamValue(dot.box,dot.id,to:new)
            }
            __redraw__()
        }
        
        func __redraw__(){
            DispatchQueue.main.async { [weak self] in
                (self?.parent as? ParamEditor)?.__draw__()
            }
        }
        
        func _layout(_ x:CGFloat, _ y:CGFloat,_ max_v:CGFloat){
            keyLabel.position = CGPoint(x:x,y:y-8.5)
            valueLabel.minimumTextWidth = max_v
            valueLabel.position = CGPoint(x:x + max_v*0.5 + ParamEditor.Margin,y:y-4)
        }
        
    }
    
}
