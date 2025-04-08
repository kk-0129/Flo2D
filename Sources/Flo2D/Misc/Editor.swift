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
import SpriteKit

// MARK: ■ Editor
class Editor:NSObject{
    
    override init(){
        __cur = Shape(rectOf:CGSize(width:5,height:30)).linewidth(2).z(-0.004).alias(false)
        __sel = Shape(rectOf:CGSize(width:5,height:30)).stroke(.clear).z(-0.005)
        super.init()
    }
    
    private typealias Cursor = (i:Int,x:CGFloat)
    private var _start, _end: Cursor?
    private let __cur: Shape
    private let __sel: Shape
    var undoer : Undoer?
    
    // MARK: ■ eLabel
    var eLabel: ELabel?{ didSet{
        if let o = oldValue{ o.editor = nil }
        __cur.removeFromParent()
        __sel.removeFromParent()
        if let el = eLabel{
            el.editor = self
            let c = el.label.fontcolor
            __cur.strokeColor = c.alpha(0.5)
            __cur.zPosition = el.label.zPosition-0.1
            __sel.fillColor = c.alpha(0.15)
            __sel.zPosition = el.label.zPosition-0.1
            #if os(macOS)
            NSCursor.iBeam.set()
            #endif
        }else{
            #if os(macOS)
            NSCursor.arrow.set()
            #endif
        }
    }}
    
    // MARK: ■ PasteboardActor
    func __can_perform__(cap:CapAction)->Bool{
        switch cap{
        case .COPY, .CUT: return _has_selection
        case .DELETE: return true//_can_backspace || _has_selection
        case .PASTE: return Scene2D.pasteboard.stringContent != nil
        case .SELECT_ALL: return true
        }
    }
    func __perform__(cap:CapAction){
        switch cap{
        case .COPY, .CUT, .DELETE:
            if cap == .DELETE && !_has_selection{ _select_one_backspace() }
            if _has_selection, let s = (cap == .COPY ? _getSel() : _delete_sel(andReplaceWith:nil)){
                if !s.isEmpty && cap != .DELETE{
                    _ = Scene2D.pasteboard.clearContents()
                    Scene2D.pasteboard.stringContent = s
                }
            }
        case .PASTE:
            if let s = Scene2D.pasteboard.stringContent{
                if _has_selection{ _ = _delete_sel(andReplaceWith:nil) }
                _insertText(s)
            }
        case .SELECT_ALL: _selectAll(true)
    }}
    
    // MARK: Actor
    func perform(_ action:Action,_ first:Bool){
        if let EL = eLabel{
            switch action{
            case .POINT(let locator,let delta,_,let phase):
                switch phase{
                case .BEGIN:
                    var c = Int(delta.x) // number of clicks
                    if first{ c -= 1 } // handle dblk event to open the editor
                    switch c{
                    case 2: _selectWord()
                    case 3: _selectAll(false)
                    default:
                        _start = _findCurPos(locator(EL).x)
                        _end = nil
                    }
                    _updateCursorAndSelection()
                case .DELTA:
                    if _start != nil {
                        _end = _findCurPos(locator(EL).x)
                        _updateCursorAndSelection()
                    }
                case .END: break
                }
            case .KEY(let key,let modifiers):
                let t = EL.text
                if _start != nil{
                    var L = false
                    switch key{
                    case Scene2D.NewLineKey,Scene2D.ReturnKey: eLabel = nil
                    case Scene2D.BackspaceKey: _backspace()
                    case Scene2D.LeftArrowKey: L = true; fallthrough
                    case Scene2D.RightArrowKey:
                        // LEFT & RIGHT ARROWS
                        let si = t.startIndex
                        if _end != nil{
                            if modifiers.contains(.SHIFT){
                                if (L && _end!.i > 0) || (!L && _end!.i < t.count){
                                    let i = _end!.i + (L ? -1 : 1)
                                    let j = t.index(si,offsetBy:i)
                                    _end = i==0 ? (0,0) : (i,EL.width(of:String(t[..<j])))
                                }
                            }else{
                                _start = (L && _end!.x < _start!.x)
                                    || (!L && _end!.x > _start!.x) ? _end : _start
                                _end = nil
                            }
                        }else if (L && _start!.i > 0) || (!L && _start!.i < t.count){
                            let i = _start!.i + (L ? -1 : 1)
                            let j = t.index(si,offsetBy:i)
                            if modifiers.contains(.SHIFT){
                                _end = i==0 ? (0,0) : (i,EL.width(of:String(t[..<j])))
                            }else{
                                _start = (i,EL.width(of:String(t[..<j])))
                                _end = nil
                            }
                        }
                        _updateCursorAndSelection()
                    default:
                        if modifiers.contains(.OPTION),let z = optional_characters[key]{
                            _ = _delete_sel(andReplaceWith:String(z))
                            return
                        }
                        // valid if UTF8
                        let s = "\(key)"
                        if s.data(using:.utf8) != nil{
                            _ = _delete_sel(andReplaceWith:s) // inserts if no selection
                        }
                    }
                }
            default: break
            }
        }
    }
    // MARK: ■ _selectWord
    private func _selectWord(){
        if let EL = eLabel{
            let TEXT = EL.text
            if TEXT.isEmpty{ return }
            var pos = _start!.i
            var ac = [Character]()
            for c in TEXT{ ac.append(c) }
            let last = ac.count-1
            pos = pos > last ? pos-1 : pos
            var LEFT = pos, RIGHT = pos
            var ltext = "", rtext = ""
            if ac[pos]==" " {
                while LEFT > 0 && ac[LEFT-1]==" " { LEFT -= 1}
                while RIGHT < last && ac[RIGHT+1]==" " { RIGHT += 1}
                if LEFT > 0 { ltext = String(ac[0...LEFT-1])} else { ltext = "" }
                rtext = String(ac[0...RIGHT])
            }else{
                if !ac[pos].alphanum{
                    if pos==0 { ltext = ""; rtext = String(ac[0])
                    } else { ltext = String(ac[0...pos-1]); rtext = String(ac[0...pos]) }
                }else {
                    while LEFT > 0 && ac[LEFT-1].alphanum{ LEFT -= 1 }
                    while RIGHT < last && ac[RIGHT+1].alphanum{ RIGHT += 1 }
                    if LEFT > 0 { ltext = String(ac[0...LEFT-1]) } else { ltext = "" }
                    rtext = String(ac[0...RIGHT])
                }
            }
            _start = (ltext.count, ltext.isEmpty ? 0 : EL.width(of:ltext))
            _end = (rtext.count, rtext.isEmpty ? 0 : EL.width(of:rtext))
        }
    }
    // MARK: ■ _selectAll
    private func _selectAll(_ b:Bool){
        _start = (0,0)
        if let EL = eLabel{
            _end = (EL.text.count, EL.textBounds.width)
            if b{ _updateCursorAndSelection() }
        }
    }
    var _has_selection:Bool{ return _start != nil && _end != nil && _start!.i != _end!.i }
    private func _findCurPos(_ x:CGFloat)->Cursor?{
        if let EL = eLabel{
            var s = ""
            let x0:CGFloat = EL.textBounds.origin.x
            if  x < x0 {return (0,0)}
            var x1:CGFloat = x0, x2 = x0
            for c in EL.text{
                s.append(c)
                x2 = EL.width(of:s) + x0
                if x < x2 {
                    if x-x1 < x2-x { return (s.count-1, x1-x0) }
                    else  { return (s.count, x2-x0) }
                }
                x1 = x2
            }
            return (s.count, x2-x0)
        }
        return nil
    }
    // MARK: ■ _updateCursorAndSelection
    func _updateCursorAndSelection(){
        __sel.removeFromParent()
        __cur.removeFromParent()
        if let EL = eLabel{
            let TB = EL.textBounds
            let x0 = TB.origin.x
            let corx = CGFloat(0.07)// * TB.height * _C.Width
            if _has_selection{
                let x1 = min(_start!.x, _end!.x)
                let x2 = max(_start!.x, _end!.x)
                let o1 = x1 == 0 ? 0 : x1 >= TB.width ? TB.width : x1 - corx
                let o2 = x2 == 0 ? 0 : x2 >= TB.width ? TB.width : x2 - corx
                let r = CGRect(x:x0+o1,y:TB.origin.y,width:o2-o1,height:TB.height)
                __sel.path = CGPath.make(rect:r,corner:2)
                EL <-- __sel
            }else{
                if let X = _start{
                    __cur.path = [
                        CGPoint(x:0, y: TB.minY),
                        CGPoint(x: 0, y: TB.minY + TB.height)
                    ].path
                    let o =  X.i == 0 ? 0 : (X.i == EL.text.count ? TB.width : X.x - corx)
                    __cur.position.x = x0 + o
                    EL <-- __cur
                }
            }
        }
    }
    // MARK: ■ _getSel
    private func _getSel()->String?{
        if let EL = eLabel{
            var sel = ""
            if _has_selection, let s = _start, let e = _end{
                let r = s.i < e.i ? (s,e) : (e,s)
                var i = 0
                for c in EL.text{
                    if i >= r.0.i && i < r.1.i { sel.append(c) }
                    i += 1
                }
            }
            return sel
        }
        return nil
    }
    // MARK: ■ _backspace
    fileprivate var _can_backspace:Bool{
        return eLabel != nil && _start!.i > 0
    }
    fileprivate func _select_one_backspace(){
        if let EL = eLabel{
            let t = EL.text
            if _end == nil, _start!.i > 0{
                let i = _start!.i - 1
                let j = t.index(t.startIndex, offsetBy: i)
                _end = (i,EL.width(of:String(t[..<j])))
            }
            //if _end != nil { _ = _delete_sel(andReplaceWith:nil) }
        }
    }
    fileprivate func _backspace(){
        if let EL = eLabel{
            let t = EL.text
            if _end == nil, _start!.i > 0{
                let i = _start!.i - 1
                let j = t.index(t.startIndex, offsetBy: i)
                _end = (i,EL.width(of:String(t[..<j])))
            }
            if _end != nil { _ = _delete_sel(andReplaceWith:nil) }
        }
    }
    // MARK: ■ _deleteSel
    fileprivate func _delete_sel(andReplaceWith mid:String?)->String?{
        //TODO: crashes if mid = nil & string is empty !!!
        if let EL = eLabel{
            var deleted = ""
            if !_has_selection{
                if let m = mid, !m.isEmpty{ _insertText(m) }
            }else if let s = _start, let e = _end{
                if s.i > e.i { _start = _end }
                _end = nil
                let r = s.i < e.i ? (s,e) : (e,s)
                var new = ""
                var i = 0
                for c in EL.text{
                    if i < r.0.i{ new.append(c) }
                    else if i == r.0.i, let mid = mid, !mid.isEmpty{
                        for x in mid{ new.append(x) }
                        _start = (r.0.i + mid.count, r.0.x + EL.width(of:mid))
                    }else if i >= r.1.i { new.append(c) }
                    else{ deleted.append(c) }
                    i += 1
                }
                EL.text = new
                
            }
            return deleted
        }
        return nil
    }
    // MARK: ■ _insertText
    fileprivate func _insertText(_ t:String){
        if let EL = eLabel{
            let old = EL.text
            if _start != nil {
                let a = EL.label.attrs
                if let max = ELabel.MAX_LENGTH, (old + t).count > max{ return }
                var new = ""
                if _start!.i == 0{ new = _append(t, to:"",a) + old }
                else{
                    for c in old{
                        new.append(c)
                        if new.count == _start!.i{ new = _append(t,to:new,a) }
                    }
                }
                EL.text = new
            }
        }
    }
    private func _append(_ s:String,to:String,_ a:A$)->String{
        var x = to
        x += s
        _start = (x.count,T$(x,a).size.width)
        _end = nil
        return x
    }
}

typealias C = Character
let optional_characters:[C:C] = [
    "0" : C.subs[0],
    "1" : C.subs[1],
    "2" : C.subs[2],
    "3" : C.subs[3],
    "4" : C.subs[4],
    "5" : C.subs[5],
    "6" : C.subs[6],
    "7" : C.subs[7],
    "8" : C.subs[8],
    "9" : C.subs[9],
    "T" : C.True,
    "F" : C.False // boolean true & false
]
extension C{
    static let True = C("⊤")
    static let False = C("⊥")
    static let subs:[C] = ["₀","₁","₂","₃","₄","₅","₆","₇","₈","₉"]
}
extension C{
    static let digits:[C] = ["0","1","2","3","4","5","6","7","8","9"]
    var digit:Bool{ return C.digits.contains(self) }
    var alpha:Bool{ return self == "_" || AtoZ || atoz }
    var alphanum:Bool{ return alpha || digit || sub }
    var AtoZ: Bool{ return "A" <= self && self <= "Z" }
    var atoz: Bool{ return "a" <= self && self <= "z" }
    var _atoz: Bool{ return atoz || "_" == self }
    //
    static let PI = C("π")
    var sub:Bool{ return C.subs.contains(self) }
}
