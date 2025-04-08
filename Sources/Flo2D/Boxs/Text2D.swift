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

class Text2D : Textual2D{
    
    static let CORNER = CGFloat(10)
    private var quotesL,quotesR:Label
    
    // MARK: INIT
    
    init(_ box:Box){
        quotesL = Label("❝",A$(0.5,[.bold]))
        quotesR = Label("❞",A$(0.5,[.bold]))
        super.init(box,WIDTH)
        self <-- [quotesL,quotesR]
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: SCENE CHANGES
    
    override func notify_redraw(){
        super.notify_redraw()
        quotesL.fontcolor = colors.fg.alpha(0.5)
        quotesR.fontcolor = colors.fg.alpha(0.5)
        fillColor = .clear
        strokeColor = colors.fg
    }
    
    // MARK: TEXT CHANGE
    
    override func recalculatePath(){
        let r = default_label_bounds
        path = CGPath.make(rect:r,corner:Text2D.CORNER)
        var x = r.origin.x
        quotesL.position = CGPoint(x:x+9,y:min_size.height*0.35)
        x += r.width
        quotesR.position = CGPoint(x:x-12,y:min_size.height*0.35)
        layout_all_the_dots()
    }
    
    override func layout_all_the_dots(){
        if inputs.isEmpty || outputs.isEmpty{ return } // not yet inited
        if let r = path?.boundingBox{
            var x = r.origin.x
            inputs[0].position = CGPoint(x:x-2,y:0)
            x += r.width
            outputs[0].position = CGPoint(x:x+2,y:0)
        }
        super.layout_all_the_dots()
    }
    
}
