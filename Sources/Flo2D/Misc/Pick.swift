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
import FloBox

public final class Pick:IO™{
    
    var scene:Scene2D?
    
    public var boxs:Set<Box>{ didSet{
        if let s = scene{ arcs = s.arcs(for:boxs,true) }
    }}
    public var arcs:Set<Arc>{ didSet{ scene?.__pick_changed__() }}
    
    public convenience init(){ self.init(Set<Box>(),Set<Arc>()) }
    public convenience init(_ boxs:Set<Box>){ self.init(boxs,Set<Arc>()) }
    public convenience init(_ arcs:Set<Arc>){ self.init(Set<Box>(),arcs) }
    public init(_ boxs:Set<Box>,_ arcs:Set<Arc>){
        self.boxs = boxs
        self.arcs = arcs
    }
    
    public var isEmpty:Bool{ return boxs.isEmpty && arcs.isEmpty }
    
    public var identicalCopy:Pick{ return Pick(boxs,arcs) }
    
    public var pastableCopy:Pick{
        var map = [Box.ID:Box]()
        return Pick( boxs.copy(&map), arcs.copy(&map) )
    }
    
    public func clear(){
        arcs.removeAll()
        boxs.removeAll()
    }
    
    public func ™(_ Ω:IO){
        boxs.™(Ω)
        arcs.™(Ω)
    }
    
    public static func ™(_ Ω:IO)throws->Pick{
        return Pick(try Set<Box>.™(Ω),try Set<Arc>.™(Ω))
    }
    
}
