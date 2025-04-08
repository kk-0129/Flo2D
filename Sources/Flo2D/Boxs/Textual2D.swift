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
import FloGraph

class Textual2D : Named2D{
    
    static let DY = Dot2D.DY*0.8
    static let Attrs = A$(0.9,[.bold])
    
    var elabel:ELabel{ return label as! ELabel }
    
    // MARK: INIT
    
    init(_ box:Box,_ min_w:CGFloat){
        min_size = CGSize(width:min_w,height:UNIT*0.5)
        super.init(box,.center,A$(0.9,[.bold]),min_w)
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    // MARK: VARS
    
    let min_size:CGSize
    
    // MARK: scene
    
    override func notify_redraw(){
        super.notify_redraw()
        elabel.colors(.clear,colors.fg)
        fillColor = .clear
    }
    
    // MARK: HELPERS
    
    var default_label_bounds:CGRect{
        let z = CGSize(
            width:max(min_size.width,elabel.width(of:elabel.text)) + UNIT*0.4,
            height:min_size.height
        )
        return CGRect(origin:CGPoint(x:-z.width*0.5,y:-z.height*0.48),size:z)
    }
    
}
