// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import SpriteKit
import FloGraph
import FloBox
import Collections

// MARK: ABSTRACT POPUP
public class Popup{
    
    init(_ pt:CGPoint){ position = pt }
    
    public enum Item:Hashable,Equatable{
        case ACTION(String,Action)
        case SUBMENU(String,Popup)
        case DISABLED(String)
        case BREAK
        public var name:String{
            switch self{
            case .ACTION(let s,_): return s
            case .SUBMENU(let s,_): return s
            case .DISABLED(let s): return s
            case .BREAK: return "---"
            }
        }
        public func hash(into h:inout Hasher){ h.combine(name) }
        public static func ==(a:Item,b:Item)->Bool{ return a.name == b.name }
    }
    
    public let position:CGPoint
    
    func add(_ item:Item){
        items.append(item)
    }
    
    public var items = [Item]()
    public var isEmpty:Bool{ return items.isEmpty }
    
}


// MARK: SCENE EXTENSION ..
extension Scene2D{
    
    func popup(root pt:CGPoint)->Popup{
        let ROOT = Popup(pt)
        var x:OrderedDictionary<String,Box.Kind> = [ _$_.Box : .GRAPH ]
        if focus.parent != nil{
            x[_$_.Input] = .INPUT
            x[_$_.Output] = .OUTPUT
        }
        for (k,v) in x{ ROOT.add(.ACTION(k,.ADD_BOX(v,pt))) }
        ROOT.add(.SUBMENU(_$_.Wijis,popup(wijis:pt,ROOT)))
        if let __pxs__ = popup(proxies:pt,ROOT){ ROOT.add(.SUBMENU(_$_.Devices,__pxs__)) }
        if let __cap__ = popup(cap:pt,ROOT){ ROOT.add(.SUBMENU(_$_.Caps,__cap__)) }
        ROOT.add(.ACTION(_$_.Colour,.COLORS))
        return ROOT
    }
    
    func popup(wijis pt:CGPoint,_ parent:Popup?)->Popup{
        let __wijis__ = Popup(pt)
        let x:OrderedDictionary<String,Box.Kind> = [
            _$_.Annotation : .ANNOT,
            _$_.Clock : .CLOCK,
            _$_.Expr : .EXPR,
            _$_.Meter : .METER,
            _$_.Switch : .SWITCH,
            _$_.Text : .TEXT,
        ]
        if let p = parent{ __wijis__.add(.SUBMENU(_$_.Back,p)) }
        for (k,v) in x{
            __wijis__.add(.ACTION(k,.ADD_BOX(v,pt)))
        }
        return __wijis__
    }
    
    func popup(proxies pt:CGPoint,_ parent:Popup?)->Popup?{
        if !hub.proxies.isEmpty{
            let __pxs__ = Popup(pt)
            if let p = parent{ __pxs__.add(.SUBMENU(_$_.Back,p)) }
            for proxy in hub.proxies.sorted(by:{ $0.uuid < $1.uuid }){
                let __bxs__ = Popup(pt)
                let skins = proxy.published
                __bxs__.add(.SUBMENU(_$_.Back,__pxs__))
                if skins.isEmpty{
                    __bxs__.add(.DISABLED(_$_.NoBoxes))
                }else{
                    for skin in skins.sorted(by:{$0.name < $1.name}){
                        __bxs__.add(
                            .ACTION(skin.name,.ADD_BOX(.PROXY,pt,(proxy,skin)))
                        )
                    }
                }
                __pxs__.add(.SUBMENU(proxy.uuid,__bxs__))
            }
            return __pxs__
        }
        return nil
    }
    
    func popup(cap pt:CGPoint,_ parent:Popup)->Popup?{
        let ops = CapAction.all.filter{__can_perform__(cap: $0)}
        if !ops.isEmpty{
            let __caps__ = Popup(pt)
            __caps__.add(.SUBMENU(_$_.Back,parent))
            for op in ops{
                __caps__.add(.ACTION(op.name,.CAP(op)))
            }
            return __caps__
        }
        return nil
    }
    
}
