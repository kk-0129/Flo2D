// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class Proxy2D : Graph2D{
    
    // MARK: INIT
    
    init(_ box:Box){
        uuid_label = Label(box.uri,A$(0.5,[]))
        super.init(box,nil)
        self <-- uuid_label
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: vars
    
    private var uuid_label:Label
    
    // MARK: recalculatePath
    
    override func recalculatePath(){
        super.recalculatePath()
        uuid_label.position = label.position + CGPoint(x:0,y:Graph2D.Header*0.9)
    }
    
    // MARK: Scene notifications
    
    override func notify_redraw(){
        uuid_label.fontcolor = colors.fg
        super.notify_redraw()
    }
    
}
