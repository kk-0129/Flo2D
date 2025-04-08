// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import FloBox

public extension Scene2D{
    static let unit = UNIT
}

let UNIT = CGFloat(85) // STANDARD UNIT
let WIDTH:CGFloat = UNIT * 0.7 // COMMON WIDTH UNIT  

let TI = TimeInterval(0.02)
let TI₂ = TimeInterval(0.3)

let π = CGFloat.pi
let π_2 = π/2
let π_4 = π/4
let π_8 = π/8

// MARK: STRINGS

struct _$_{
    
    static let Box = "Box"
    static let Input = "Input"
    static let Output = "Output"
    static let Annotation = "Annotation"
    static let Clock = "Clock"
    static let Expr = "Expr"
    static let Meter = "Meter"
    static let Switch = "Switch"
    static let Text = "Text"
    //
    static let Wijis = "Widgets"
    static let NoBoxes = "No Boxes"
    static let Devices = "Devices"
    static let Publish = "Publish"
    static let Unpublish = "Unpublish"
    //
    static let Back = "↖︎"
    static let Caps = "Selection"
    static let Cut = "Cut"
    static let Copy = "Copy"
    static let Delete = "Delete"
    static let Paste = "Paste"
    static let SelectAll = "Select All"
    //
    static let Scroll = "Scroll"
    static let Zoom = "Zoom"
    //
    static let ON = "ON"
    static let OFF = "OFF"
    //
    static let PoV = "PoV"
    static let Focus = "Focus"
    static let Position = "Position"
    static let Colour = "Colour"
    static let Change = "Change"
    static let Params = "Param value"
    static let Name = "Name"
    static let Size = "Annotation Size"
    static let Meta = "Metadata"
    //
    static let ArrayOn = "✓ Array"
    static let ArrayOff = "Array"
    static let Structs = "Structs"
    static let IOType = "Input/Output Type"
    //
    static func TName(_ t:T)->String{
        switch t{
        case .UNKNOWN: return "?"
        case .BOOL: return "Bool"
        case .DATA: return "Data"
        case .FLOAT: return "Float"
        case .STRING: return "String"
        case .ARRAY(let t): return "[" + t.s$ + "]"
        case .STRUCT(let name,_): return name
        }
    }
    //
    
    static let Jan = "Jan"
    static let Feb = "Feb"
    static let Mar = "Mar"
    static let Apr = "Apr"
    static let May = "May"
    static let Jun = "Jun"
    static let Jul = "Jul"
    static let Aug = "Aug"
    static let Sep = "Sep"
    static let Oct = "Oct"
    static let Nov = "Nov"
    static let Dec = "Dec"
    
}
