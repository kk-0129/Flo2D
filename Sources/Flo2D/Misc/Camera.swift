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

// MARK: ■ Camera
class Camera:SKCameraNode{
    
    override init(){
        super.init()
        zPosition = 100000000
        position = CGPoint(x:0,y:0)
        setScale(1) // = zoom
    }
    required init?(coder c: NSCoder){ fatalError() }
    
    var pov:F3{
        get{
            return F3(Float32(position.x),Float32(position.y),Float32(xScale))
        }
        set(p){
            position = CGPoint(x:CGFloat(p.x),y:CGFloat(p.y))
            setScale(CGFloat(p.z))
        }
    }
    
    private var _band = Shape().stroke(.black).linewidth(0.5)
    private var _start,_end:CGPoint?
    private var _scene:Scene2D{ return scene as! Scene2D }
    
    func dragband(_ p:CGPoint?)->Bool{
        if let p = p{
            if _start == nil{ _start = p; return true }
            else{ _end = p }
        }else{
            _start = nil
            _end = nil
            _ = updateBand()
        }
        return false
    }
    
    func updateBand()->CGRect?{
        if let s = _start, let e = _end{
            let r1 = CGRect(x:min(s.x,e.x),y:min(s.y,e.y),width:abs(s.x-e.x),height:abs(s.y-e.y))
            let r2 = _local(rect:r1)
            let c = min(r2.width*0.5,min(r2.height*0.5,4))
            _band.path = CGPath(roundedRect:r2,cornerWidth:c,cornerHeight:c,transform:nil)
            if _band.parent == nil{ self <-- _band }
            let bg = scene!.backgroundColor
            _ = _band.stroke(bg.contrast.alpha(0.5))
            return r1
        }else{
            _band.removeFromParent()
            return nil
        }
    }
    
    private func _local(rect r:CGRect)->CGRect{
        if let p = parent{
            let o1 = r.origin
            let o2 = p.convert(o1,to:self)
            let o3 = CGPoint(x:o1.x+r.width,y:o1.y+r.height)
            let o4 = p.convert(o3,to:self)
            let w = abs(o4.x-o2.x)
            let h = abs(o4.y-o2.y)
            return CGRect(origin:o2,size:CGSize(width:w,height:h))
        }
        return r
    }
    
}
