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

let BAR_W = WIDTH*0.1
class Histogram2D : Box2D{
    
    // MARK: INIT
    
    override init(_ box:Box){
        super.init(box)
        let z = CGSize(width:WIDTH*2,height:WIDTH*2)
        path = CGPath(ellipseIn:CGRect(size:z),transform:nil)
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: OBSERVER
    
    override func notify_redraw(){
        super.notify_redraw()
        if !picked{ strokeColor = colors.avg }
        shape_for_highlighting.lineWidth = picked ? 2 : 0.5
    }
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        for id in slots{
            switch id{
            case .histo: displayValues(box.histo)
            default: break
            }
        }
        super.observed(f,slots)
    }
    
    var bars = [Shape]()
    func displayValues(_ fs:[Float32]){
        let left = recalculatePath()
        self.removeChildren(in: bars)
        for i in 0..<fs.count{
            let f = CGFloat(fs[i])
            let x = left + CGFloat(i) * BAR_W
            let y = f < 0 ? f : 0
            let r = CGRect(origin:CGPoint(x:x,y:y),size:CGSize(width:BAR_W,height:f*10))
            let p = CGPath(rect:r,transform:nil)
            let s = Shape(p)
            s.fillColor = colors.avg
            bars.append(s)
            self <-- s
        }
    }
    
    // MARK: RECALC PATH
    
    func recalculatePath()->CGFloat{ // returns x-origin
        let values = box.histo
        let z = CGSize(
            width:BAR_W*max(1,CGFloat(values.count)),
            height:WIDTH
        )
        let x = -z.width*0.5
        let r = CGRect(origin:CGPoint(x:x,y:-z.height*0.48),size:z)
        path = CGPath.make(rect:r,corner:0)
        layout_all_the_dots()
        return x
    }
    
    // MARK: DOT POSTIONS
    override func layout_all_the_dots(){
        if !(inputs.isEmpty || outputs.isEmpty){
            let b = path!.boundingBoxOfPath
            inputs[0].position = CGPoint(x:b.minX - BAR_W,y:0)
            outputs[0].position = CGPoint(x:b.minX + b.width + BAR_W,y:0)
            super.layout_all_the_dots() // updates incoming/outgoing arcs
        }
    }
    
}

