//
//  PersonalPlayground.swift
//  COMP-8051-Lab2
//
//  Created by Jay Wang on 2024-01-24.
//

/*
 All work should be done individually.

 [x][1 marks] Create an app that runs on an iOS device (you can assume at least iOS 14.0) with a single cube shown in perspective projection. Each side of the cube should have a separate colour, as shown in class.
 [x][1 marks] Modify the app so a double-tap toggles whether the cube continuously rotates about the y-axis.
 [][1 marks] Modify the app so when the cube is not rotating the user can rotate the cube about two axes using the touch interface (single finger drag).
 [][5 marks] Modify the app so when the cube is not rotating a “pinch” (two fingers moving closer or farther away from each other) zooms in and out of the cube.
 [][5 marks] Modify the app so when the cube is not rotating dragging with two fingers moves the cube around.
 [][5 marks] Add to the app a button that, when pressed, resets the cube to a default position of (0,0,0) with a default orientation.
 [][2 marks] Add to the app a label that continuously reports the position (x,y,z) and rotation (3 angles) of the cube.
 [][20 marks] Add a second cube with a separate texture applied to each side, spaced far enough from the first one so the two are fully visible and close enough that both are in the camera's view. This second cube should continuously rotate, even when the first one is not auto-rotating.
 [][10 marks] Add a flashlight, ambient and diffuse light, and include toggle buttons to turn each one on and off. The effects of each of the three lights should be clearly visible.
 =======================================================================
 The code must be written using only Objective-C or Swift and C++, and all files required to build and deploy the app must be provided. Submit all your project files and any documentation to the D2L Dropbox folder as a single ZIP file with the filename A00XYZ_Asst1.zip, where XYZ is your A00 number. All required documentation (README file, code comments, etc.) must be included.
 */

import SceneKit

class Assignment1: SCNScene{
    
    // Member Variables
    /*
     Initialize Camera.
     Tentatively initialize a Node then later on, Assign a SCNCamera() to this Node. Which means, it gives this Node Camera Attributes.
     */
    var _CameraNode = SCNNode()
    
    // Nanosecond Intervals between each Update Call
    var _UpdateInterval = 10000
    
    // Current Rotation Angle
    var _RotAngle = CGSize.zero
    
    // Drag Gesture Translation Offset
    var _DragAngle = CGSize.zero
    
    // Boolean Toggle for Rotating
    var isRotating = true
    
    // Boolean indicator for whether _RotAngle is up-to-date after drag event
    var isDragRotUpdated = true
    
    // Catch if init() fails
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     OnAwake or Scene Initializer. Runs this function immediately on startup.
     */
    override init(){
        super.init()
        
        // Set the Background to black
        background.contents = UIColor.black
        
        // Call Relevant Functions after this point for additonal content in the Scene.
        
        // Initialize Camera
        initCamera()
        
        // Spawn a cube
        spawnCube(_SpawnPos: SCNVector3(0,0,0))
        
        Task(priority: .userInitiated){
            await FirstUpdate()
        }
        
    }
    /*
     Initialize a Node with Camera Properties, and attach it to the rootNode
     */
    func initCamera(){
        
        // Create a Camera
        let _Camera = SCNCamera()
        
        // Assign new Camera to _CameraNode
        _CameraNode.camera = _Camera
        
        // Set Camera Position
        _CameraNode.position = SCNVector3(5,5,5)
        
        // Set Pitch, Yaw, Roll to 0.
        _CameraNode.eulerAngles = SCNVector3(-Float.pi/4,Float.pi/4,0)
        
        // Add camera node to Root Node
        rootNode.addChildNode(_CameraNode)
        
    }
    
    /*
     Spawns a cube at a given position
     _SpawnPos: SCNVector3
     The position that the cube will spawn at.
     */
    func spawnCube(_SpawnPos: SCNVector3){
        // Initialize an ObjectNode: of type Square, with length, width, and height set to 1.
        let _Cube = SCNNode(geometry: SCNBox(width: 1, height: 1,length: 1,chamferRadius: 0))
        
        // Initialize an array of Colors.
        let _Colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.magenta]
        
        // Colorize each face
        colorizeCubeFaces(_SCNObject: _Cube, _Colors: _Colors)
        
        // Give the Object a name.
        _Cube.name = "Cube"
        
        // Set the Cube Color to Blue
        //_Cube.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        // Set Cube Position
        _Cube.position = _SpawnPos
        
        // Attach ObjectNode to rootNode
        rootNode.addChildNode(_Cube)
    }
    
    /*
     
     */
    func colorizeCubeFaces(_SCNObject: SCNNode, _Colors: [UIColor]){
        
        var count = 0
        
        // Heavily Assumes there's only 6 faces to assign materials
        for _Color in _Colors{
            
            // Initialize a temporary Material assign a color and colorize
            let tempMaterial = SCNMaterial()
            tempMaterial.diffuse.contents = _Color
            
            // Actually assign material to the cube face
            _SCNObject.geometry?.insertMaterial(tempMaterial, at: count)
            
            count += 1
            
        }
        
    }
    
    // @MainActor essentially means to put this function on the main thread. Highly Prioritised
    /*
     Called on the very first graphical frame,
     */
    @MainActor
    func FirstUpdate(){
        
        // If you want, you can call any functions here, before the first update call.
        //...
        
        // Actually call the Update function here
        Update(_UpdateInterval: 10000)
        
        // Likewise here, you can call any functions after here.
        // ...
    }
    
    /*
     Recursive Function that that you may use to do calculations, every frame.
     
     */
    @MainActor
    func Update(_UpdateInterval: UInt64){
        
        rotateObject(_Name: "Cube", _Radians: 0.0001)
        
        // Sleeps Update Function for given Interval in Nanoseconds
        Task{
            try! await Task.sleep(nanoseconds: _UpdateInterval)
            Update(_UpdateInterval: _UpdateInterval)
        }
        
    }
    
    // Find SCNNode by Name (String), then rotates a given object by given the given amount, in radians.
    func rotateObject(_Name: String, _Radians: Double){
        
        // Find SCNNode with respective Name
        let _SCNObject = rootNode.childNode(withName: "Cube", recursively: true)
        
        if (isRotating){
            
            // Updates _RotAngle if it is behind _DragAngle, once.
            //updateRotAngle()
            
            // Rotation is Toggle, keep rotating
            _RotAngle.width += _Radians
            
            // Manipulate SCNObject
            _SCNObject?.eulerAngles = SCNVector3(Double(_RotAngle.height), Double(_RotAngle.width), 0)
            
            
        } else {
            
            // Manipulate SCNObject
            _SCNObject?.eulerAngles = SCNVector3(Double(_DragAngle.height/50), Double(_DragAngle.width/50), 0)
            
        }
                    
    }
    
    /*
     Double Tap Handler
     Toggles isRotating and indicatest to the scene whether to rotate "Cube"
     */
    @MainActor
    func doubleTapHandler(){
        
        // Flip the Boolean. Toggle it
        isRotating = !isRotating
        
    }
    
    /*
     Drag Gesture Handler
     Rotates the SCNObject by an offset, given by gesture.translation
     */
    @MainActor
    func dragHandler(_Offset: CGSize){
        
        // _RotAngle is now behind _DragAngle, so flip the boolean
        isDragRotUpdated = false
        
        _DragAngle = _Offset
        
    }
    
    /*
     Helper Function to detect and bring _RotAngle up to speed with _DragAngle
     */
    func updateRotAngle(){
        if (isDragRotUpdated == false){
            _DragAngle = _RotAngle
        }
        isDragRotUpdated = true
    }
    
}
