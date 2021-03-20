/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0.0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
    }
    
    func angleBetween(_ v1:SCNVector3, _ v2:SCNVector3)->Float{
        let cosinus = dotProduct(left: v1, right: v2) / v1.length / v2.length

        let angle = acos(cosinus)
        return angle
    }

    // Dot product of two vectors
    func dotProduct(left: SCNVector3, right: SCNVector3) -> Float {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            
            
            
            
//            print("x: \(abs(headTransform.columns.1.x)), y: \(abs(headTransform.columns.1.y)), z: \(abs(headTransform.columns.1.z))")
//
//            print(bodyAnchor.skeleton.modelTransform(for: .head))
            
            let arSkeleton = bodyAnchor.skeleton
            
            let shoulder = arSkeleton.modelTransform(for: .leftShoulder)
            let hand = arSkeleton.modelTransform(for: .leftHand)
//            let matrix1 = SCNMatrix4(upLeg!)
//            let matrix2 = SCNMatrix4(spine7!)
//            let matrix3 = SCNMatrix4(leg!)
            let shoulderPOS:SCNVector3 = SCNVector3Make(shoulder!.columns.3.x, shoulder!.columns.3.y, shoulder!.columns.3.z)
            let handPOS = SCNVector3Make(hand!.columns.3.x, hand!.columns.3.y, hand!.columns.3.z)
            
//            print(leg)
            //Compute the angle made by leg joint and spine7 joint
            //from the hip_joint (root node of the skeleton)
            let angle = angleBetween(shoulderPOS, handPOS)
            
//            print("angle : ", angle * 180.0 / Float.pi)
            print(shoulder!.columns.3.y - (hand?.columns.3.y)!)
            print(arSkeleton.definition.jointNames)
            
            
            
//            print("x: \(abs(headTransform.columns.0.x)), y: \(abs(headTransform.columns.0.y)), z: \(abs(headTransform.columns.0.z))")
            
            
//            let matrix = simd_float4x4([[0.96619135, -0.2569147, -0.021659307, 0.0], [0.25668123, 0.95059294, 0.17460762, 0.0], [-0.02427008, -0.17426391, 0.98439986, 0.0], [0.04634987, 0.0005390548, 3.246308e-05, 1.0]])
//
//            print(matrix.columns.0.x)
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
                
            }
        }
    }
}


extension SCNVector3 {
    
    // Vector Length is Zero
    func isZero() -> Bool {
        if self.x == 0 && self.y == 0 && self.z == 0 {
            return true
        }
        
        return false
    }
    
    /**
        Inverts vector
    */
    mutating func invert() -> SCNVector3 {
        self * -1
        return self
    }
    
    /**
        Calculates vector length based on Pythagoras theorem
    */
    var length:Float {
        get {
            return sqrtf(x*x + y*y + z*z)
        }
        set {
            self = self.unit * newValue
        }
    }
    
    /**
        Calculate Length Squared of Vector
        - Used to determine Longest/Shortest Vector. Faster than using v.length
    */
    var lengthSquared:Float {
        get {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }
    }
    
    /**
        Returns unit vector (aka Normalized Vector)
        - v.length = 1.0
    */
    var unit:SCNVector3 {
        get {
            return self / self.length
        }
    }
    
    /**
        Normalizes vector
        - v.Length = 1.0
    */
    mutating func normalize() {
        self = self.unit
    }
    
    /**
        Calculates distance to vector
    */
    func distance(toVector: SCNVector3) -> Float {
        return (self - toVector).length
    }
    
    
    /**
        Calculates dot product to vector
    */
    func dot(toVector: SCNVector3) -> Float {
        return x * toVector.x + y * toVector.y + z * toVector.z
    }
    
    /**
        Calculates cross product to vector
    */
    func cross(toVector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * toVector.z - z * toVector.y, z * toVector.x - x * toVector.z, x * toVector.y - y * toVector.x)
    }
    
    /**
    Returns lerp from Vector to Vector
    */
    func lerp(toVector: SCNVector3, t: Float) -> SCNVector3 {
        return SCNVector3Make(
            self.x + ((toVector.x - self.x) * t),
            self.y + ((toVector.y - self.y) * t),
            self.z + ((toVector.z - self.z) * t))
    }
    
    /**
        Project onto Vector
    */
    func project(ontoVector: SCNVector3) -> SCNVector3 {
        let scale: Float = dotBetweenVectors(v1: ontoVector, v2: self) / dotBetweenVectors(v1: ontoVector, v2: ontoVector)
        let v: SCNVector3 = ontoVector * scale
        return v
    }
    
    /// Get/Set Angle of Vector
    mutating func rotate(angle:Float) {
        let length = self.length
        self.x = cos(angle) * length
        self.y = sin(angle) * length
    }
    
    
    func toCGVector() -> CGVector {
        return CGVector(dx: CGFloat(self.x), dy: CGFloat(self.y))
    }

}

/**
    v1 = v2 + v3
*/
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
    v1 += v2
*/
func +=( left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

/**
    v1 = v2 - v3
*/
func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
    v1 -= v2
*/
func -=( left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

/**
    v1 = v2 * v3
*/
func *(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
    v1 *= v2
*/
func *=( left: inout SCNVector3, right: SCNVector3) {
    left = left * right
}

/**
    v1 = v2 * x
*/
func *(left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

/**
    v *= x
*/
func *=( left: inout SCNVector3, right: Float) {
    left = SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

/**
    v1 = v2 / v3
*/
func /(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
    v1 /= v2
*/
func /=( left: inout SCNVector3, right: SCNVector3) {
    left = SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
    v1 = v2 / x
*/
func /(left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

/**
    v /= x
*/
func /=( left: inout SCNVector3, right: Float) {
    left = SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

/**
    v = -v
*/
prefix func -(v: SCNVector3) -> SCNVector3 {
    return v * -1
}

/**
    Returns distance between two vectors
*/
func distanceBetweenVectors(v1: SCNVector3, v2: SCNVector3) -> Float {
    return (v2 - v1).length
}

/**
    Returns dot product between two vectors
*/
func dotBetweenVectors(v1: SCNVector3, v2: SCNVector3) -> Float {
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
}

/**
    Returns cross product between two vectors
*/
func crossBetweenVectors(v1: SCNVector3, v2: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z, v1.x * v2.y - v1.y * v2.x)
}

/**
    Generate a Random Vector
*/
func randomSCNVector3(rangeX:Float, rangeY:Float, rangeZ:Float) -> SCNVector3 {
    
    return SCNVector3(
        x: Float(arc4random()%UInt32(rangeX)),
        y: Float(arc4random()%UInt32(rangeY)),
        z: Float(arc4random()%UInt32(rangeZ)))
}


