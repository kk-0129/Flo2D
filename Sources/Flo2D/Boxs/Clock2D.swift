// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class Clock2D : Box2D{
    
    private static let X = UNIT*0.1
    
    private static let _hour_hand = CGMutablePath()
        .arc(CGPoint.zero,WIDTH*0.1,π*0.7,π*0.3,false)
        .line(CGPoint(x:0,y:X*4))
        .closed
    private static let _min_hand = CGMutablePath()
        .arc(CGPoint.zero,WIDTH*0.1,π*0.6,π*0.4,false)
        .line(CGPoint(x:0,y:X*6))
        .closed
    private static let _sec_hand = CGMutablePath()
        .arc(CGPoint.zero,WIDTH*0.1,π*0.52,π*0.48,false)
        .line(CGPoint(x:0,y:X*5))
        .closed
    
    // MARK: INIT
    
    override init(_ box:Box){
        hi = Label("1 Jan 2000",A$(0.6,[.bold])).h(.center).pos(0,Clock2D.X*9)
        hour_hand = Shape(Clock2D._hour_hand).z(0.011)
        min_hand = Shape(Clock2D._min_hand).z(0.012)
        sec_hand = Shape(Clock2D._sec_hand).z(0.013)
        face = Shape(face_path)
        super.init(box)
        path = CGPath.make(radius:WIDTH)
        self <-- [face.z(-0.1),hi,hour_hand,min_hand,sec_hand]
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    private let hi:Label
    private let hour_hand,min_hand,sec_hand,face:Shape
    
    // MARK: SCENE CHANGES
    
    override func notify_redraw(){
        hi.fontcolor = colors.fg
        hour_hand.strokeColor = colors.fg
        hour_hand.fillColor = colors.fg
        min_hand.strokeColor = colors.fg
        min_hand.fillColor = colors.fg
        sec_hand.strokeColor = colors.fg
        sec_hand.fillColor = colors.fg
        super.notify_redraw()
        face.strokeColor = .clear
        face.fillColor = colors.avg
    }
    
    // MARK: DOT POSTIONS
    override func layout_all_the_dots(){
        inputs[0].position = CGPoint(x:-WIDTH-3,y:0)
        outputs[0].position = CGPoint(x:WIDTH+3,y:0)
        super.layout_all_the_dots() // updates incoming/outgoing arcs
    }
    
    // MARK: NOTIFICATIONS
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        super.observed(f,slots)
        for id in slots{
            switch id{
            case .date:
                let d = box.datetime
                let dd = Int(d[Box.Keys.day$] as? Float32 ?? 0)
                let mm = _months[Int(d[Box.Keys.month$] as? Float32 ?? 0)]
                let yy = Int(d[Box.Keys.year$] as? Float32 ?? 0)
                hi.string = "\(dd) \(mm) \(yy)"
                let mins = __angle(d[Box.Keys.min$] as? Float32 ?? 0,60)
                hour_hand.zRotation = -( __angle(d[Box.Keys.hour$] as? Float32 ?? 0,12) + (mins/12.0))
                min_hand.zRotation = -mins
                sec_hand.zRotation = -__angle(d[Box.Keys.sec$] as? Float32 ?? 0,60)
            default: break
            }
        }
    }
    
    // MARK: HELPER
    private func __angle(_ f:Float32,_ d:CGFloat)->CGFloat{
        return 2*π*CGFloat(f)/d
    }
    
}

private let DATE = Struct.type(named:"Date")!
extension Box{
}

private let _months = [_$_.Jan,_$_.Feb,_$_.Mar, _$_.Apr,_$_.May,_$_.Jun,_$_.Jul,_$_.Aug,_$_.Sep,_$_.Oct,_$_.Nov,_$_.Dec ]

private let _spine_count = 12
private let _face_radius = WIDTH
private let face_path:CGPath = _makeFace()
private func _makeFace()->CGPath{
    let _r1 = _face_radius*0.8
    let _r2 = _face_radius*0.6
    let p = CGMutablePath().move(_pt(_r2,0))
    let step = (2 * π) / CGFloat(_spine_count)
    for i in 0..<_spine_count{
        let a = (CGFloat(i)-0.1)*step
        let c = (CGFloat(i)+0.1)*step
        let d = (CGFloat(i+1)-0.1)*step
        _ = p.line(_pt(_r1,a))
            .line(_pt(_r2,a))
            .line(_pt(_r2,c))
            .line(_pt(_r1,c))
            .arc(CGPoint(x:0,y:0),_r1,c,d,false)
    }
    p.addPath(CGPath.make(radius:_face_radius))
    return p.closed
}
private func _pt(_ r:CGFloat,_ a:CGFloat)->CGPoint{
    return CGPoint(x:r*cos(a),y:r*sin(a))
}
