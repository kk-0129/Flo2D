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
import SpriteKit
import CoreGraphics
import FloGraph
import FloBox

class Named2D : Box2D, ELabel.Validator{
    
    // MARK: INIT
    
    init(_ box:Box,_ h:Hᴬ,_ a:A$,_ minw:CGFloat?){
        super.init(box)
        let n = box.name
        let l = Label(n == "" ? " " : n,a).h(h).v(.baseline)
        self.label = minw != nil ? ELabel(l,minw:minw!,validator:self).z(0.1) : l
        self <-- self.label
    }
    required init?(coder c:NSCoder){ fatalError() }
    override func enscened(){
        super.enscened()
        recalculatePath()
    }
    
    // MARK: VARS
    
    var label:SKNode!
    
    // MARK: ELabel.Validator
    
    func editor(changed txt:String)->Any?{
        recalculatePath()
        return txt
    }
    
    func editor(closed txt:String,validated any:Any){
        if let s = any as? String{
            scene2d.undoableName(box,from:box.name,to:s)
        }
    }
    
    // MARK: Observers
    
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        super.observed(f,slots)
        for id in slots{
            switch id{
            case .name:
                if let l = label as? ELabel{
                    l.text = box.name
                    recalculatePath()
                }
            default: break
            }
        }
    }
    
    // MARK: PATH
    func recalculatePath(){ /* override me */ }
    
    var __label_width__:CGFloat{
        if let l = label as? ELabel{ return max(l.minimumTextWidth,l.label.size.width) }
        else if let l = label as? Label{ return l.size.width }
        return 0
    }
    
}
