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
import FloBox

#if os(macOS)
public typealias Color = NSColor
#else
public typealias Color = UIColor
#endif

// MARK: Colors
struct Colors{
    static var random:Colors{ return Colors(Color.random) }
    // MARK: INIT
    init(_ rgba:F4){ self.init(Color(rgba)) }
    init(_ bg:Color){ self.init(bg,bg.contrast) }
    init(_ bg:Color,_ fg:Color){ self.bg = bg; self.fg = fg }
    // MARK: VARS
    let bg:Color
    let fg:Color
    var avg:Color{
        let a = bg.rgba
        let b = fg.rgba
        return Color((a.x+a.x+b.x)/3,(a.y+a.y+b.y)/3,(a.z+a.z+b.z)/3,(a.w+a.w+b.w)/3)
    }
}

// MARK: ColorPicker
public protocol ColorPicker{
    // apps should show the picker whenever this callback is not nil
    var callback : ((Color)->())?{ get set }
}

// MARK: ColorChanger
class ColorChanger{
    var t:Timer? = nil
    let boxs:Set<Box>
    var old = [F4]()
    weak var scene:Scene2D?
    init(_ sc:Scene2D,_ bs:Set<Box>){
        scene = sc
        boxs = bs
        old = boxs.map{ $0.rgba }
    }
    func __perform__(_ c:Color){
        if let sc = scene{
            let c = c.rgba
            t?.invalidate()
            let boxs = [Box](boxs)
            let old = boxs.isEmpty ? [sc.focus.rgba] : old
            // trigger undoable change after 0.2s of inactivity ..
            t = Timer.scheduledTimer(withTimeInterval:0.2,repeats:false){ [weak self] _ in
                self?.__undoable__(boxs,old,c)
            }
            // immediate change
            if boxs.isEmpty{ sc.focus.rgba = c }
            else{ for b in boxs{ b.rgba = c } }
        }
    }
    func __undoable__(_ boxs:[Box],_ old:[F4],_ new:F4){
        if let sc = scene{
            let new = [F4](repeating:new,count:old.count)
            sc.undoableRGBA(boxs,from:old,to:new)
            self.old = new
        }
    }
}

// MARK: Color
public extension Color{
    
    typealias Picker = ColorPicker
    static var picker : ColorPicker?
    
    convenience init(_ c:F4){ self.init(c.x,c.y,c.z,c.w) }
    
    convenience init(_ r:Float32,_ g:Float32,_ b:Float32,_ a:Float32){ 
        self.init(red:CGFloat(r),green:CGFloat(g),blue:CGFloat(b),alpha:CGFloat(a))
    }
    
    func alpha(_ a:Float32)->Color{
        let c = rgba
        return Color(c.x,c.y,c.z,a)
    }
    
    var bright:Bool{
        let c = rgba
        return (c.x + (c.y*2) + (c.z*0.7)) > 2
    }
    
    var contrast:Color{ return bright ? Color(0,0,0,1) : Color(1,1,1,1) }
    
    static var random:Color{
        let c = F4.random
        return Color(F4(c.x,c.y,c.z,1))
    }
    
    var lighter:Color{ return scale(1.2) }
    var darker:Color{ return scale(0.8) }
    
    func scale(_ f:Float32)->Color{
        let c = rgba
        return Color(max(0.1,c.x)*f,max(0.1,c.y)*f,max(0.1,c.z)*f,c.w)
    }
    
    var rgba:F4{ // (Float32,Float32,Float32,Float32){
        #if os(macOS)
        switch self.colorSpace{
        case .deviceRGB,.sRGB,.extendedSRGB,.genericRGB,.displayP3:
            return F4(Float32(redComponent),Float32(greenComponent),Float32(blueComponent),Float32(alphaComponent))
        case .deviceGray,.genericGray,.genericGamma22Gray:
            let  w = Float32(self.whiteComponent)
            return F4(w,w,w,Float32(alphaComponent))
        case .deviceCMYK:
            __log__.err("TODO - convert CMYK to RGB")
            fallthrough
        default:
            __log__.err("unsupported color space: \(colorSpace) -> using random color")
            return Color.random.rgba
        }
        #else
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        if getRed(&r,green:&g,blue:&b,alpha:&a){
            return F4(Float32(r),Float32(g),Float32(b),Float32(a))
        }else{ fatalError() }
        #endif
    }
    
}
