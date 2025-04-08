// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class Text2D : Textual2D{
    
    static let CORNER = CGFloat(10)
    private var quotesL,quotesR:Label
    
    // MARK: INIT
    
    init(_ box:Box){
        quotesL = Label("❝",A$(0.5,[.bold]))
        quotesR = Label("❞",A$(0.5,[.bold]))
        super.init(box,WIDTH)
        self <-- [quotesL,quotesR]
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: SCENE CHANGES
    
    override func notify_redraw(){
        super.notify_redraw()
        quotesL.fontcolor = colors.fg.alpha(0.5)
        quotesR.fontcolor = colors.fg.alpha(0.5)
        fillColor = .clear
        strokeColor = colors.fg
    }
    
    // MARK: TEXT CHANGE
    
    override func recalculatePath(){
        let r = default_label_bounds
        path = CGPath.make(rect:r,corner:Text2D.CORNER)
        var x = r.origin.x
        quotesL.position = CGPoint(x:x+9,y:min_size.height*0.35)
        x += r.width
        quotesR.position = CGPoint(x:x-12,y:min_size.height*0.35)
        layout_all_the_dots()
    }
    
    override func layout_all_the_dots(){
        if inputs.isEmpty || outputs.isEmpty{ return } // not yet inited
        if let r = path?.boundingBox{
            var x = r.origin.x
            inputs[0].position = CGPoint(x:x-2,y:0)
            x += r.width
            outputs[0].position = CGPoint(x:x+2,y:0)
        }
        super.layout_all_the_dots()
    }
    
}
