// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import SpriteKit

// MARK: POPUP MENU ..
private let MG = CGSize(width:UNIT*0.1,height:UNIT*0.05) // margin around edge
private let DY = MG.height // margin around edge

class MyPopup:Shape{
    
    init(_ popup:Popup){
        super.init()
        for i in popup.items.reversed(){ self <-- Item(i) }
        zPosition = 100000
        lineWidth = 2
        __draw__()
        position = popup.position
    }
    required init?(coder c: NSCoder){ fatalError() }
    
    override func notify_redraw(){
        let f = colors.bg.bright ? colors.bg.scale(0.7) : colors.bg.scale(1.3)
        //let f = c.bg.contrast
        fillColor = f.alpha(0.9)
        strokeColor = f//.clear
        for i in [Item](children.filter({$0 is Item}).map({$0 as! Item})){
            i.colors(fillColor)
        }
    }
    
    private func __draw__(){
        let cs = children
        var max_width = UNIT
        var _data = [(Item,CGFloat)]()
        var total_item_height = CGFloat(0)
        
        let items = cs.filter({ $0 is Item }) as! [Item]
        for item in items{
            let s = item.size
            max_width = max(max_width,s.width + MG.width)
            let h = s.height + MG.height*0.5
            _data.append((item,h))
            total_item_height += h
        }
        let size = CGSize(
            width:max_width + (MG.width * 2),
            height:total_item_height + (MG.height * 2) + (DY * CGFloat(items.count))
        )
        var p = CGPoint.zero
        path = Bubble._no_arrows(size,5,&p)
        p = CGPoint(x:p.x,y:MG.height+p.y-size.height*0.5)
        for i in 0..<_data.count{
            let (item,height) = _data[i]
            let r = CGRect(
                x:(MG.width*0.5)-(size.width*0.5),
                y:p.y+2,
                width:max_width+MG.width,
                height:height)
            item.label.position = CGPoint(x:p.x,y:r.origin.y+r.height*0.5)
            item.path = CGPath.make(rect:r,corner:0)
            p = CGPoint(x:p.x,y:p.y+height+DY)
        }
    }
    
    // MARK: POPUP MENU ITEM ..
    class Item:Shape,Actor{
        
        let item:Popup.Item!
        var label:Label
        var icon:Shape?
        
        init(_ item:Popup.Item){
            self.item = item
            let a$ = A$(0.7,[])
            let txt = item.name
            label = Label(T$(txt,a$)).h(.center)
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            super.init()
            self <-- label
            strokeColor = .clear
            path = CGPath(rect:CGRect(x:0,y:0,width:0,height:0),transform:nil)
        }
        required init?(coder c:NSCoder){ fatalError() }
        
        var size:CGSize{ return label.size }
        
        func position(_ p:CGPoint){
            label.position = p
        }
        
        func colors(_ bg:Color){
            var fg = bg.contrast
            fillColor = .clear // bg
            switch self.item{
            case .BREAK: break
            //case .SUBMENU: fg = fg.alpha(0.8)
            case .DISABLED: fg = fg.alpha(0.5)
            default: break
            }
            label.fontcolor = fg
        }
        
        func performs(_ a:Action)->Bool{
            if case .POINT = a{ return true }
            return false
        }
        
        func perform(_ a:Action, _ sc:Scene2D){
            if case .POINT(_,_,_,let phase) = a{
                switch phase{
                case .BEGIN: fillColor = sc.colors.bg.alpha(0.3)
                case .DELTA: break
                case .END:
                    switch item{
                    case .ACTION(_,let a):
                        sc.popup = nil
                        sc.perform(a)
                    case .SUBMENU(_,let p):
                        sc.popup = p
                    default: break
                    }
                }
            }
        }
        
    }
    
}
