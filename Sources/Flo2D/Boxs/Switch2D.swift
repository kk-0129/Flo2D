// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class Switch2D : Box2D{
    
    static let Size = CGSize(width:UNIT*0.75,height:UNIT*0.35)
    static let radius = Size.height
    static let corner = Size.height*0.5
    private static let _p = CGPath.make(size:CGSize(width:UNIT*0.8,height:UNIT*0.4),corner:corner)
    private static let _db = CGRect(size:Size*1.02)
    
    override init(_ box:Box){
        let a = A$(0.4,[.bold])
        _on_off = Label(_$_.ON+"   "+_$_.OFF,a).pos(2,0)
        _knob = Knob(box)
        super.init(box)
        self <-- [_on_off,_knob]
        path = Switch2D._p
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    
    private let _on_off:Label
    private let _knob:Knob
    
    // MARK: SCENE CHANGES
    
    override func notify_redraw(){
        _on_off.fontcolor = colors.bg
        _knob.notify_redraw()
        super.notify_redraw()
        fillColor = colors.avg
    }
    
    // MARK: OBSERVER
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        super.observed(f,slots)
        for id in slots{
            if id == .on{ _knob.__switch_on_state_changed__() }
        }
    }
    
    // MARK: DOT POSTIONS
    override func layout_all_the_dots(){
        let w = Switch2D.Size.width * 0.58
        inputs[0].position = CGPoint(x:-w,y:0)
        outputs[0].position = CGPoint(x:w,y:0)
        super.layout_all_the_dots() // updates incoming/outgoing arcs
    }
    
    // MARK: KNOB
    
    class Knob:Shape,Actor{
        
        // MARK: INIT
        init(_ box:Box){
            _switch = box
            super.init()
            path = CGPath.make(rect:CGRect(size:CGSize(width:radius,height:radius*0.9)),corner:corner*0.7)
            zPosition = 0.1
            __switch_on_state_changed__()
        }
        required init?(coder c: NSCoder){ fatalError() } // NSCoder = Foundation !
        
        // MARK: VARS
        
        var _switch:Box
        
        // MARK: OBSERVER
        
        func __switch_on_state_changed__(){
            let x = Switch2D.Size.width * 0.23
            position = CGPoint(x:_switch.on ? x : -x,y:0)
        }
        
        // MARK: SCENE CHANGES
        
        override func notify_redraw(){
            super.notify_redraw()
            strokeColor = colors.fg
            fillColor = colors.fg
        }
        
        // MARK: EVENT HANDLER
        
        func performs(_ action:Action)->Bool{
            switch action{
            case .POINT(_,_,_,let phase): return phase == .BEGIN
            default: return false
            }
        }
            
        func perform(_ action:Action,_ sc:Scene2D){
            switch action{
            case .POINT(_,_,_,let phase):
                if phase == .BEGIN, _switch.incomingArcs.isEmpty{
                    scene2d.undoableOnOff(_switch)
                }
            default: break
            }
        }
        
    }
    
}
