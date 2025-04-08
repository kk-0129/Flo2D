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
