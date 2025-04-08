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
import SpriteKit

protocol ELabelValidator{
    func editor(changed txt:String)->Any?
    func editor(closed txt:String,validated any:Any)
}

// MARK: ■ ƒELabel
class ELabel: Shape, Actor{
    
    typealias Validator = ELabelValidator
    
    public let label: Label
    var minimumTextWidth = CGFloat(0){ didSet{ if minimumTextWidth != oldValue{ _update() }}}
    var minimumLabelWidth:CGFloat{ return minimumTextWidth - (ELabel.Margin.x*3) }
    
    private let validator: Validator
    
    public init(
        _ label: Label,
        minw: CGFloat, // minimum width of the background
        validator:Validator
        ){
        self.validator = validator
        self.label = label.z(0.1)
        //----------------------------------------------------
        super.init()
        //----------------------------------------------------
        self.H = T$("À√g",label.attrs).size.height
        self.H_2 = H * 0.5
        minimumTextWidth = minw
        self <-- label
        _update()
        strokeColor = .clear
    }
    required init?(coder c: NSCoder){ fatalError() }
    // MARK: ■ editor
    func width(of s:String)->CGFloat{ return T$(s,label.attrs).size.width+1 }
    
    //func scale(_ s:G)->ELabel{ _ = label.scale(s); return self }
    
    var text_on_opening_editor:String?
    var editor:Editor?{ didSet{
        if editor == nil{
            if let v = __validation__{ validator.editor(closed:label.string,validated:v) }
            else{ text = text_on_opening_editor ?? "?" }
            __validation__ = nil
            strokeColor = .clear
        }else{
            text_on_opening_editor = text
        }
        _update()
    }}
    
    func colors(_ fill:Color,_ txt:Color){
        fillColor = fill
        label.fontcolor = txt
    }
    
    // MARK: ■ state
    var __validation__:Any?{ didSet{
        removeAllActions()
        if __validation__ == nil && editor != nil{
            let d = TimeInterval(0.05)
            let g = CGFloat(3)
            let original_x = position.x
            run(.repeatForever(.sequence([
                .moveBy(x:g,y:0,duration:d),
                .moveBy(x:-2*g,y:0,duration:d),
                .moveBy(x:2*g,y:0,duration:d),
                .moveBy(x:-2*g,y:0,duration:d),
                .moveTo(x:original_x,duration:d),
                .wait(forDuration:1)
            ])))
        }
    }}
    
    
    // MARK: ■ handle events
    var can_edit:()->(Bool) = { return true }
    var editable = true
    let wantsLeftButton = true
    let wantsRightButton = false
    
    func performs(_ action:Action)->Bool{
        switch action{
        case .POINT: return true
        default: return false
        }
    }
    func perform(_ action:Action,_ sc:Scene2D){
        switch action{
        case .POINT(_,_,_,let phase):
            switch phase{
            case .BEGIN:
                if let ed = editor{ ed.perform(action,false) }
                else{
                    if editable && can_edit(){
                        sc.editor.eLabel = self
                        sc.editor.perform(action,true)
                    }
                }
            case .DELTA: editor?.perform(action,false)
            default: break
            }
        case .KEY: editor?.perform(action,false)
        default: break
        }
    }
    
    var textBounds = CGRect(x:0,y:0,width:0,height:0)
    static var MAX_LENGTH:UInt32?
    public var text:String{
        get{ return label.string }
        set(new){
            if new != label.string{
                label.string = new
                __validation__ = validator.editor(changed: new)
                _update()
            }
        }
    }
    private var _new_path:CGPath?
    private func _update(){
        let (tb,r,p) = _calculate_bounds()
        textBounds = tb
        path = CGPath.make(rect:r,corner:5)
        label.position = p
        editor?._updateCursorAndSelection()
    }
    // MARK: ■ bounds
    private var _editor_bg:Shape?
    private var H, H_2: CGFloat!
    static let Margin = CGPoint(x:UNIT * 0.05,y:UNIT * 0.03)
    private var _last_calculated_bounds:(CGRect,CGRect,CGPoint) = (
        CGRect(x:1,y:1,width:1,height:1),
        CGRect(x:1,y:1,width:1,height:1),
        CGPoint(x:1,y:1)
    )
    var width:CGFloat{ return _last_calculated_bounds.1.width }
    private func _calculate_bounds()->(CGRect,CGRect,CGPoint){
        let txt_w = label.size.width // includes ls_w & ts_w
        let bg_w = max( minimumLabelWidth, txt_w )
        let m = ELabel.Margin
        var x = -bg_w*0.5
        let y = -H_2
        let r = CGRect(x:x-m.x,y:y-m.y,width:bg_w+m.x+m.x,height:H+m.y+m.y)
        var label_x = CGFloat(0)
        //let ls = label.leading
        //let ls_w:G = ls != nil ? ls!.size.width - 1 : 0
        //let ts = label.trailing
        //let ts_w:G = ts != nil ? ts!.size.width - 1 : 0
        switch label.horizontalAlignmentMode{
        case .left:
            x = r.origin.x + m.x
            label_x = x// + ls_w
        case .right:
            let right = r.origin.x + r.width - m.x
            x = right - txt_w
            label_x = right// - ts_w
        case .center:
            x = -txt_w*0.5
            label_x = 0//(ls_w - ts_w)*0.5
        default: break
        }
        var Y = CGFloat(0)
        switch label.verticalAlignmentMode{
        case .top: Y = H_2
        case .baseline: Y = -H_2 * 0.5
        case .bottom: Y = -H_2
        default: break
        }
        _last_calculated_bounds = (CGRect(x:x,y:y,width:txt_w,height:H),r,CGPoint(x:label_x,y:Y))
        return _last_calculated_bounds
    }
    
}
