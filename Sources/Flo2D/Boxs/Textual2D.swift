// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import SpriteKit
import FloGraph

class Textual2D : Named2D{
    
    static let DY = Dot2D.DY*0.8
    static let Attrs = A$(0.9,[.bold])
    
    var elabel:ELabel{ return label as! ELabel }
    
    // MARK: INIT
    
    init(_ box:Box,_ min_w:CGFloat){
        min_size = CGSize(width:min_w,height:UNIT*0.5)
        super.init(box,.center,A$(0.9,[.bold]),min_w)
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    
    let min_size:CGSize
    
    // MARK: scene
    
    override func notify_redraw(){
        super.notify_redraw()
        elabel.colors(.clear,colors.fg)
        fillColor = .clear
    }
    
    // MARK: HELPERS
    
    var default_label_bounds:CGRect{
        let z = CGSize(
            width:max(min_size.width,elabel.width(of:elabel.text)) + UNIT*0.4,
            height:min_size.height
        )
        return CGRect(origin:CGPoint(x:-z.width*0.5,y:-z.height*0.48),size:z)
    }
    
}
