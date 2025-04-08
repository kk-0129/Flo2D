// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class Expr2D : Textual2D{
    
    // MARK: INIT

    init(_ box:Box){
        super.init(box,WIDTH)
        self <-- line
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: vars
    private let line = Shape().linewidth(0.5).z(0.05)
    
    // MARK: scene notification
    
    override func notify_redraw(){
        line.strokeColor = colors.fg
        super.notify_redraw()
        for d in dots{
            d.colors = colors
            d.box_colors = colors
        }
        strokeColor = picked ? line.strokeColor : colors.avg
        shape_for_highlighting.lineWidth = picked ? 2 : 0.5
    }
    
    override func add_all_the_dots() {
        super.add_all_the_dots()
        colors = scene2d.colors
    }
    
    // MARK: RECALC PATH
    
    override func recalculatePath(){
        var r = default_label_bounds
        LEFT = CGFloat(0)
        for d in inputs{ LEFT = max(LEFT,d.textwidth + 30) }
        let h = CGFloat(max(1,box.inputs.count)) * Dot2D.DY
        let y = -h*0.47
        r = CGRect(x:r.origin.x-LEFT,y:y,width:r.width+LEFT,height:h)
        path = CGPath.make(rect:r,corner:Text2D.CORNER)
        //
        line.position = CGPoint(x:r.origin.x+LEFT-4,y:0)
        line.path = CGMutablePath()
            .move(CGPoint(x:0,y:y))
            .line(CGPoint(x:0,y:y+h))
        layout_all_the_dots()
    }
    
    var LEFT = CGFloat(0)
    
    override func layout_all_the_dots(){
        if let r = path?.boundingBox{
            var h = CGFloat(box.inputs.count) * Dot2D.DY
            var top = r.midY + h*0.5 - Dot2D.DY*0.5
            var x = r.origin.x - 2
            for i in 0..<inputs.count{
                inputs[i].position = CGPoint(x:x,y:top-CGFloat(i)*Dot2D.DY)
            }
            h = CGFloat(box.outputs.count) * Dot2D.DY
            top = r.midY + h*0.5 - Dot2D.DY*0.5
            x = r.origin.x + r.width + 2
            for i in 0..<outputs.count{
                outputs[i].position = CGPoint(x:x,y:top-CGFloat(i)*Dot2D.DY)
            }
        }
        super.layout_all_the_dots() // updates incoming/outgoing arcs
    }
    
    // MARK: ELabelValidator
    
    override func editor(changed txt:String)->Any?{
        _ = super.editor(changed: txt)
        return try? Parser.parse(expr:txt)
    }
    
    override func editor(closed txt:String,validated any:Any){
        if let expr = any as? Expr{
            let new = ParsedExpr(txt,expr)
            scene2d.undoableExpr(box,from:box.pex,to:new)
        }
    }
    
    // MARK: Observers
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        super.observed(f,slots)
        for id in slots{
            switch id{
            case .pex: observed(f,[.name,.inputs])
                //add_all_the_dots()
            default: break
            }
        }
    }
    
}
