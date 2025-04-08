// 𝗙𝗟𝗢 : 𝗗𝗶𝘀𝘁𝗿𝗶𝗯𝘂𝘁𝗲𝗱 𝗛𝗶𝗲𝗿𝗮𝗿𝗰𝗵𝗶𝗰𝗮𝗹 𝗗𝗮𝘁𝗮𝗳𝗹𝗼𝘄 © 𝖪𝖾𝗏𝖾𝗇 𝖪𝖾𝖺𝗋𝗇𝖾𝗒 𝟮𝟬𝟮𝟯
import Foundation
import CoreGraphics
import FloGraph
import FloBox

import SpriteKit
import SceneKit

/*
 https://developer.apple.com/documentation/spritekit/sk3dnode/displaying_3d_content_in_a_spritekit_scene
 */

private let pi_4 = CGFloat.pi*0.5

class IMU3D : Box2D{
    
    // MARK: INIT
    
    let axes:SCNNode
    let scene3d:SCNScene

    override init(_ box:Box){
        axes = SCNNode()
        axes.simdEulerAngles = F3(0,0,0)
        for n in [
            __arrow3d__(0,0,0,0,.red), // X axis
            __arrow3d__(0,0,-1,pi_4,Color(0,0.75,0,1)),  // Y axis
            __arrow3d__(1,0,0,pi_4,Color(0.3,0.3,0.75,1))    // Z axis
        ]{ axes.addChildNode(n) }
        
        scene3d = SCNScene()
        let root = scene3d.rootNode
        root.addChildNode(axes)
        super.init(box)
        let z = CGSize(width:WIDTH*2,height:WIDTH*2)
        path = CGPath(ellipseIn:CGRect(size:z),transform:nil)
        let n = SK3DNode(viewportSize:z)
        n.scnScene = scene3d
        n.autoenablesDefaultLighting = false
        
        let m = SCNMaterial()
        m.diffuse.contents = Color(0.5,0.5,0.5,0.3)
        let g = SCNCylinder(radius:1.2,height:0.01)
        g.materials = [m]
        let s = SCNNode(geometry:g)
        axes.addChildNode(s)
        
        let pov = SCNNode()
        pov.camera = SCNCamera()
        pov.constraints = [ SCNLookAtConstraint(target:scene3d.rootNode) ]
        root.addChildNode(pov)
        pov.position = SCNVector3(0,0,2.5)
        self <-- n
    }
    required init?(coder c:NSCoder){ fatalError() }
    
    
    // MARK: OBSERVER
    override func observed(_ f:Frame,_ slots:[Slot.ID]){
        for id in slots{
            switch id{
            case .f3a:
                DispatchQueue.main.async {
                    self.axes.simdEulerAngles = self.box.euler
                }
            default: break
            }
        }
        super.observed(f,slots)
    }
    
    override func notify_redraw(){
        super.notify_redraw()
        if !picked{ strokeColor = colors.avg }
        shape_for_highlighting.lineWidth = picked ? 2 : 0.5
    }
    
    // MARK: DOT POSTIONS
    override func layout_all_the_dots(){
        inputs[0].position = CGPoint(x:-WIDTH-1,y:0)
        outputs[0].position = CGPoint(x:WIDTH+1,y:0)
        super.layout_all_the_dots() // updates incoming/outgoing arcs
    }
    
}

private func __arrow3d__(_ x:CGFloat,_ y:CGFloat,_ z:CGFloat,_ a:CGFloat,_ color:Color)->SCNNode{
    let m = SCNMaterial()
    m.diffuse.contents = color
    // stick
    let h = CGFloat(2)   // height
    let r = CGFloat(0.03) // radius
    let g1 = SCNCylinder(radius:r,height:h)
    g1.materials = [m]
    let n1 = SCNNode(geometry:g1)
    n1.rotation = SCNVector4(x,y,z,a)
    // pointer
    let g2 = SCNCone(topRadius:0,bottomRadius:r*3,height:h*0.2)
    g2.materials = [m]
    let n2 = SCNNode(geometry:g2)
    n2.position = SCNVector3(0,h*0.5,0)
    n1.addChildNode(n2)
    return n1
}
