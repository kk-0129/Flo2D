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

// MARK: Pasteboard
public protocol Pasteboard{
    func write(_ p:Pick)
    func read()->Pick?
    var canPaste:Bool{ get }
    var stringContent:String?{ get set }
    func clearContents()->Int
}

struct __DefaultPasteboard__:Pasteboard{ /* does nothing */
    func write(_ p:Pick){}
    func read()->Pick?{ return nil }
    let canPaste = false
    var stringContent:String? = nil
    func clearContents()->Int{ return 0  }
}

// CAP = "Copy and Paste"
public enum CapAction{
    case COPY, CUT, PASTE, DELETE, SELECT_ALL
    static let all:[CapAction] = [.COPY,.CUT,.PASTE,.DELETE,.SELECT_ALL]
    var name:String{
        switch self{
        case .COPY: return _$_.Copy
        case .CUT: return _$_.Cut
        case .PASTE: return _$_.Paste
        case .DELETE: return _$_.Delete
        case .SELECT_ALL: return _$_.SelectAll
        }
    }
}

extension Scene2D{
    
    // MARK: PASTEBOARD
    
    func __can_perform__(cap:CapAction)->Bool{
        if editor.eLabel != nil{ return editor.__can_perform__(cap:cap) }
        switch cap{
        case .COPY, .CUT, .DELETE:
            // TODO: don't delete published boxes !!
            //for b in pick.boxs{
                //if let p = self[t.root,.pub] as? Bool, p{ return false }
            //} 
            return !pick.isEmpty
        case .PASTE: return Scene2D.pasteboard.canPaste
        case .SELECT_ALL:
            return focus.boxs.count > pick.boxs.count
        }
    }
    
    func __perform__(cap:CapAction){
        if editor.eLabel != nil{ editor.__perform__(cap:cap) }
        else{
            guard __can_perform__(cap:cap) else{ return }
            //if cap != .PASTE{ cap_delegate?.willPerform(op,with:selection) }
            switch cap{
            case .PASTE:
                if let p = Scene2D.pasteboard.read(){
                    //cap_delegate?.willPerform(.PASTE,with:s)
                    Scene2D.pasteboard.write(p)
                    _PASTE("Paste",p,false)
                }
            case .COPY,.CUT:
                Scene2D.pasteboard.write(pick)
                if cap == .CUT{ fallthrough }
            case .DELETE:
                let p = pick.identicalCopy
                pick.clear()
                p.arcs.formUnion( arcs(for:p.boxs,false) ) // add the arcs
                undoableRemove(pick:p)
            case .SELECT_ALL:
                pick.boxs = Set<Box>(box2Ds.map({$0.box}))
            }
        }
    }
     
    private func _PASTE(_ s:String,_ pick:Pick,_ select_on_undo:Bool){
        if !pick.isEmpty{
            // if select_on_undo{ selection.copy(from:sel) }
            let copy = pick.pastableCopy
            for box in copy.boxs{
                let pt = box.xy
                box.xy = F2(pt.x+OFFSET,pt.y-OFFSET)
            }
            Scene2D.pasteboard.write(copy)
            undoableAdd(pick:copy)
        }
    }
    
}

private let OFFSET = Float32(UNIT*0.2)
