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
import FloGraph
import CoreGraphics

// MARK: CGPoint
public extension CGPoint{
    //init(_ x:G,_ y:G){ self.init(x:x,y:y) }
    init(_ f2:F2){ self.init(x:CGFloat(f2.x),y:CGFloat(f2.y)) }
    var f2:F2{ return F2(Float32(x),Float32(y)) }
    static func -(a:CGPoint,b:CGPoint)->CGPoint{ return CGPoint(x:a.x-b.x,y:a.y-b.y) }
    static func +(a:CGPoint,b:CGPoint)->CGPoint{ return CGPoint(x:a.x+b.x,y:a.y+b.y) }
}
public extension Array where Element == CGPoint{
    var path:CGMutablePath{ return CGMutablePath._make(self) }
}

// MARK: CGSize
public extension CGSize{
    static func *(a:CGSize,b:CGFloat)->CGSize{
        return CGSize(width:a.width*b,height:a.height*b)
    }
}

// MARK: CGRect
public extension CGRect{
    init(size s:CGSize){
        self.init(origin:CGPoint(x:-s.width*0.5,y:-s.height*0.5),size:s)
    }
}

// MARK: CGPath
public extension CGPath{
    static func make(radius r:CGFloat)->CGPath{
        return CGPath(ellipseIn:CGRect(size:CGSize(width:r*2,height:r*2)),transform:nil)
    }
    static func make(size z:CGSize)->CGPath{ return make(rect:CGRect(size:z)) }
    static func make(size z:CGSize,corner c:CGFloat)->CGPath{
        return make(rect: CGRect(size:z),corner: c)
    }
    static func make(rect r:CGRect)->CGPath{ return CGPath(rect:r,transform:nil) }
    static func make(rect r:CGRect,corner c:CGFloat)->CGPath{
        return CGPath(roundedRect:r,cornerWidth:c,cornerHeight:c,transform:nil)
    }
}

// MARK: CGMutablePath
public extension CGMutablePath{
    static func _make(_ ps:[CGPoint])->CGMutablePath{
        let p = CGMutablePath()
        if !ps.isEmpty{
            p.move(to:ps[0])
            for i in 1..<ps.count{ p.addLine(to:ps[i]) }
        }
        return p
    }
    func move(_ p:CGPoint)->CGMutablePath{ move(to:p); return self }
    func line(_ p:CGPoint)->CGMutablePath{ addLine(to:p); return self }
    func arc(_ p:CGPoint,_ r:CGFloat,_ s:CGFloat,_ e:CGFloat,_ c:Bool)->CGMutablePath{
        addArc(center:p,radius:r,startAngle:s,endAngle:e,clockwise:c)
        return self
    }
    func quad(_ p:CGPoint,_ c:CGPoint)->CGMutablePath{ addQuadCurve(to:p,control:c); return self }
    var closed:CGMutablePath{ closeSubpath(); return self }
}
