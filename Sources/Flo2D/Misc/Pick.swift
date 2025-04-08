// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import FloGraph
import FloBox

public final class Pick:IO™{
    
    var scene:Scene2D?
    
    public var boxs:Set<Box>{ didSet{
        if let s = scene{ arcs = s.arcs(for:boxs,true) }
    }}
    public var arcs:Set<Arc>{ didSet{ scene?.__pick_changed__() }}
    
    public convenience init(){ self.init(Set<Box>(),Set<Arc>()) }
    public convenience init(_ boxs:Set<Box>){ self.init(boxs,Set<Arc>()) }
    public convenience init(_ arcs:Set<Arc>){ self.init(Set<Box>(),arcs) }
    public init(_ boxs:Set<Box>,_ arcs:Set<Arc>){
        self.boxs = boxs
        self.arcs = arcs
    }
    
    public var isEmpty:Bool{ return boxs.isEmpty && arcs.isEmpty }
    
    public var identicalCopy:Pick{ return Pick(boxs,arcs) }
    
    public var pastableCopy:Pick{
        var map = [Box.ID:Box]()
        return Pick( boxs.copy(&map), arcs.copy(&map) )
    }
    
    public func clear(){
        arcs.removeAll()
        boxs.removeAll()
    }
    
    public func ™(_ Ω:IO){
        boxs.™(Ω)
        arcs.™(Ω)
    }
    
    public static func ™(_ Ω:IO)throws->Pick{
        return Pick(try Set<Box>.™(Ω),try Set<Arc>.™(Ω))
    }
    
}
