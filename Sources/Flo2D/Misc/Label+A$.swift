// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import SpriteKit

// MARK: ■ SKLabelNode
public typealias Label = SKLabelNode
public typealias Hᴬ = SKLabelHorizontalAlignmentMode
public typealias Vᴬ = SKLabelVerticalAlignmentMode
public extension Label{
    convenience init(_ t:String){ self.init(t,1) }
    convenience init(_ t:String,_ s:CGFloat){ self.init(t,A$(s,[],Color.random)) }
    convenience init(_ t:String,_ a:A$){ self.init(T$(t,a)) }
    convenience init(_ t:T$){
        self.init(attributedText:t.nsa)
        verticalAlignmentMode = .center
        self.userData = [0:t]
    }
    //func scale(_ s:G)->Label{ xScale = s; yScale = s; return self }
    func pos(_ x:CGFloat,_ y:CGFloat)->Label{ position = CGPoint(x:x,y:y); return self }
    func z(_ z:CGFloat)->Label{ zPosition = z; return self }
    func h(_ h:Hᴬ)->Label{ horizontalAlignmentMode = h; return self }
    func v(_ v:Vᴬ)->Label{ verticalAlignmentMode = v; return self }
    //func color(_ c:Color)->Label{ fontcolor = c; return self }
    private var _text:T${
        get{ return userData![0] as! T$ }
        set(t){
            self.attributedText = t.nsa
            self.userData = [0:t]
        }
    }
    func alpha(_ f:CGFloat)->Label{ alpha = f; return self }
    var string:String{
        get{ return _text.string == T$.EMPTY_STRING ? "" : _text.string }
        set(s){ if s != string{ _text = T$(s.isEmpty ? T$.EMPTY_STRING : s,attrs) } }
    }
    var attrs:A${ return _text.attrs }
    var fontcolor:Color{
        get{ return attrs.color }
        set(c){ _text = T$(string,A$(attrs.size,attrs.styles,c)) }
    }
    var fontsize:CGFloat{
        get{ return _text.attrs.size }
        set(fs){ _text = T$(string,A$(fs,attrs.styles,attrs.color)) }
    }
    var size:CGSize{ return _text.size }
}

#if os(macOS)
import AppKit
public typealias Font = NSFont
#else
import UIKit
//public typealias AttrString = AttributedString
//public typealias MutableAttrString = AttributedString
public typealias Font = UIFont
#endif
public typealias AttrString = NSAttributedString
public typealias MutableAttrString = NSMutableAttributedString

public struct T${
    
    static let EMPTY_STRING = "?"
    
    public init(_ s:String,_ a:A$){
        let s = s.isEmpty ? T$.EMPTY_STRING : s
        string = s
        attrs = a
        var z = CGSize(width:1,height:1)
        var _nsa = MutableAttrString()
        if !s.isEmpty{
            if s == T$.EMPTY_STRING{
                let c = a.color.alpha(0.5)
                _nsa = MutableAttrString(string:s,attributes:A$(a.size,a.styles,c).impl)
            }else{
                _nsa = MutableAttrString(string:s,attributes:attrs.impl)
            }
        }
        nsa = _nsa
        z = nsa.size()
        size = CGSize(width:max(z.width,1),height:max(z.height,1))
    }
    
    let string:String
    let attrs:A$
    let size:CGSize
    let nsa:AttrString
    
}

//private let font_name = "Courier"
public func BOLD_FONT(size:CGFloat)->Font{
    return Font.boldSystemFont(ofSize:size)
}
public func NORMAL_FONT(size:CGFloat)->Font{
    return Font.systemFont(ofSize:size)
}

// MARK: ■ Font Attributes
public struct A${
    
    public enum Style{
        case bold
        case italic
    }
    
    let size:CGFloat
    let color:Color
    let styles:[Style]
    
    public init(_ s:CGFloat,_ ss:[Style],_ c:Color?=nil){
        size = s
        color = c ?? Color.random
        styles = ss
        let s = s * 30
        var fnt:Font = ss.contains(.bold) ? BOLD_FONT(size:s) : NORMAL_FONT(size:s)
        #if os(macOS)
        if ss.contains(.italic){
            let descriptor = fnt.fontDescriptor.withSymbolicTraits(.italic)
            if let f = Font(descriptor:descriptor,size:s){ fnt = f }
        }
        #endif
        impl = [
            .font:fnt,
            .foregroundColor:color
        ]
    }
    
    public let impl:[AttrString.Key:Any]
    
}

