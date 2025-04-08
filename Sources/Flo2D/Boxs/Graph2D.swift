/*
 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄
 MIT License

 Copyright (c) 2025 kk-0129

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
import Foundation
import CoreGraphics
import FloGraph
import FloBox

class Graph2D : Named2D{
    
    // MARK: STATICS
    
    static let MinWidth = UNIT * 2
    static let Header = UNIT * 0.7
    
    // MARK: INIT
    
    convenience init(_ box:Box){ self.init(box,Graph2D.MinWidth*0.95) }
    
    init(_ box:Box,_ minw:CGFloat?){
        super.init(box,.center,A$(1.2,[.bold]),minw)
        self <-- line
        if !box.on{ alpha = 0.4 } // otherwise there's a fade-out animation
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    private let line = Shape().z(0.1)//.linewidth(0.5)
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        super.observed(f,slots)
        for id in slots{
            switch id{
            case .on: enabled = box.on
            case .rgba:
                let c = Colors(Color(box.rgba))
                fillColor = c.bg
                line.strokeColor = c.fg
                ((label is Label) ? (label as! Label) : (label as! ELabel).label).fontcolor = c.fg
            default: break
            }
        }
    }
    
    // MARK: recalculatePath
    
    override func recalculatePath(){
        guard label != nil else{ return }
        let (w,h) = __box_size__
        label.position = CGPoint(x:0,y:(h + Graph2D.Header)*0.5)
        if let l = label as? Label{ l.position = CGPoint(x:0,y:l.position.y - l.size.height*0.25) }
        let r0 = CGRect(size:CGSize(width:w,height:h))
        // node shape ..
        let r1 = CGRect(x:r0.origin.x,y:r0.origin.y,width:w,height:h + Graph2D.Header)
        path = CGPath.make(rect:r1,corner:5)
        //
        let r2 = CGRect(x:r1.origin.x,y:h*0.5,width:w,height:1)
        line.path = CGMutablePath()
            .move(CGPoint(x:-w*0.48,y:0))
            .line(CGPoint(x:w*0.48,y:0))
        line.position = CGPoint(x:0,y:r2.minY+r2.height*1.03)
        //
        layout_all_the_dots()
    }
    
    private var __box_size__:(CGFloat,CGFloat){
        var w = max(__label_width__ + UNIT, Graph2D.MinWidth) // the minimum
        let ins = inputs.filter({$0.dot_name != Box.on$})
        let n = max(ins.count,outputs.count)
        for i in 0..<n{
            let vi = i < ins.count ? ins[i].textwidth : 0
            let vo = i < outputs.count ? outputs[i].textwidth : 0
            w = max( w, vi + (Dot2D.DX * 4) + vo )
        }
        let h = max( UNIT*0.2, (CGFloat(n)+0.2) * Dot2D.DY )
        return (w,h)
    }
    
    // MARK: DOT POSITIONS
    override func layout_all_the_dots(){
        let b = path!.boundingBox
        var x = b.origin.x - 3
        var i = 0
        for w in inputs{
            var y = __y__(i)
            if w.dot_name == Box.on${ y = line.position.y + Graph2D.Header*0.5 }
            else{ i += 1 }
            w.position = CGPoint(x:x,y:y)
        }
        x = b.origin.x + b.width + 3
        for i in 0..<outputs.count{
            outputs[i].position = CGPoint(x:x,y:__y__(i))
        }
        super.layout_all_the_dots() // updates incoming/outgoing arcs
    }
    private func __y__(_ i:Int)->CGFloat{
        return line.position.y - ( ( CGFloat(i) + 0.65 ) * Dot2D.DY )
    }
    
    // MARK: POPUP
    override func willDisplayPopup(_ p:Popup,in sc:Scene2D){
        if let g = box.child{
            let x = g.published
            p.add(.ACTION(x ? _$_.Unpublish : _$_.Publish,.PUBLISH(g,!x)))
        }
    }
    
}
