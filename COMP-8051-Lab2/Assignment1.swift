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
 [x][1 marks] Modify the app so when the cube is not rotating the user can rotate the cube about two axes using the touch interface (single finger drag).
 [x][5 marks] Modify the app so when the cube is not rotating a “pinch” (two fingers moving closer or farther away from each other) zooms in and out of the cube.
 [][5 marks] Modify the app so when the cube is not rotating dragging with two fingers moves the cube around.
 [x][5 marks] Add to the app a button that, when pressed, resets the cube to a default position of (0,0,0) with a default orientation.
 [x][2 marks] Add to the app a label that continuously reports the position (x,y,z) and rotation (3 angles) of the cube.
 [x][20 marks] Add a second cube with a separate texture applied to each side, spaced far enough from the first one so the two are fully visible and close enough that both are in the camera's view. This second cube should continuously rotate, even when the first one is not auto-rotating.
 [x][10 marks] Add a flashlight, ambient and diffuse light, and include toggle buttons to turn each one on and off. The effects of each of the three lights should be clearly visible.
 =======================================================================
 The code must be written using only Objective-C or Swift and C++, and all files required to build and deploy the app must be provided. Submit all your project files and any documentation to the D2L Dropbox folder as a single ZIP file with the filename A00XYZ_Asst1.zip, where XYZ is your A00 number. All required documentation (README file, code comments, etc.) must be included.
 */

import SceneKit

class Assignment1: SCNScene{
    
    var _DeltaTime = 0
    
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
    
    // Magnification amount to translate
    var _StartMagnificationAmt = CGFloat.zero
    
    // Boolean Toggle for Rotating
    var isRotating = true
    
    // Boolean indicator for whether _RotAngle is up-to-date after drag event
    var isDragRotUpdated = true
    
    // Indicates if User is Magnifying at the moment
    var isMagnifying = false
    
    // Text Label for displaying SCNObject properties
    var SCNTextLabel = SCNText(string: "default", extrusionDepth: 0)
    
    // SCNNode to be parent node for SCNTextLabel
    var _TextNode = SCNNode()
    
    // Initialize an array of Colors.
    let _Colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.magenta]
    
    // Textures to apply to second cube
    var _Textures: [UIImage?] = [UIImage(named: "amogus.jpg"),UIImage(named: "bird.jpg"),UIImage(named: "anya.png"),UIImage(named: "Stitch.jpeg"),UIImage(named: "pokemon-1.jpg"), UIImage(named: "galaxy.jpeg")]
    
    var _SCNAmbientLight = SCNNode()
    var _SCNFlashlight = SCNNode()
    var _SCNDiffuseLight = SCNNode()
    var diffuseLightPos = SCNVector4(0, 0, 0, Double.pi/2)
    var flashlightPos = 3.0
    var flashlightAngle = 10.0
    
    var _AmbientLightToggle = true
    var _DiffuseLightToggle = true
    var _FlashlightToggle = true
    
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
        
        // Initialize Text Label
        initTextLabel()
        
        // Spawn a cube
        spawnCube(_SpawnPos: SCNVector3(0,0,0), _Name: "Cube")
        
        spawnCube(_SpawnPos: SCNVector3(0,-5,0), _Name: "CubeTwo",_InputTextures: _Textures)
        
        _SCNAmbientLight = spawnLight(_Position: SCNVector3(0,0,0), _LightType: SCNLight.LightType.ambient, _Name: "AmbientLight", _Color: UIColor.white, _Intensity: 200)
        
        _SCNFlashlight = spawnLight(_Position: SCNVector3(0, 5, flashlightPos), _LightType: SCNLight.LightType.spot, _Name: "DirectionalLight", _Color: UIColor.blue, _Intensity: 10000)
        _SCNFlashlight.rotation = SCNVector4(1, 0, 0, -Double.pi/3)
        _SCNFlashlight.light?.spotInnerAngle = 0
        _SCNFlashlight.light?.spotOuterAngle = flashlightAngle
        _SCNFlashlight.light?.shadowColor = UIColor.black
        
        _SCNDiffuseLight = spawnLight(_Position: SCNVector3(0,-4.2,0), _LightType: SCNLight.LightType.omni, _Name: "Diffuse", _Color: UIColor.green, _Intensity: 1000)
        
        
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
    func spawnCube(_SpawnPos: SCNVector3, _Name: String) -> SCNNode{
        // Initialize an ObjectNode: of type Square, with length, width, and height set to 1.
        let _Cube = SCNNode(geometry: SCNBox(width: 1, height: 1,length: 1,chamferRadius: 0))
        
        // Colorize each face
        colorizeCubeFaces(_SCNObject: _Cube, _Colors: _Colors)
        
        // Give the Object a name.
        _Cube.name = _Name
        
        // Set the Cube Color to Blue
        //_Cube.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        // Set Cube Position
        _Cube.position = _SpawnPos
        
        // Attach ObjectNode to rootNode
        rootNode.addChildNode(_Cube)
        
        return _Cube
    }
    
    /*
     Overloaded spawnCube function that accepts an array of UIImages to apply to each face of the cube:
     Spawns a cube at a given position
     _SpawnPos: SCNVector3
     The position that the cube will spawn at.
     */
    func spawnCube(_SpawnPos: SCNVector3, _Name: String, _InputTextures: [UIImage?]) -> SCNNode{
        // Initialize an ObjectNode: of type Square, with length, width, and height set to 1.
        let _Cube = SCNNode(geometry: SCNBox(width: 1, height: 1,length: 1,chamferRadius: 0))
        
        // Colorize each face
        colorizeCubeFaces(_SCNObject: _Cube, _Colors: _InputTextures)
        
        // Give the Object a name.
        _Cube.name = _Name
        
        // Set the Cube Color to Blue
        //_Cube.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        // Set Cube Position
        _Cube.position = _SpawnPos
        
        // Attach ObjectNode to rootNode
        rootNode.addChildNode(_Cube)
        
        return _Cube
    }
    
    /*
     Helper Function to apply Colors to each face of cube
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
    
    /*
     Overloaded Helper Function that accepts a array of length 6 and applies them to each face of the cube
     */
    func colorizeCubeFaces(_SCNObject: SCNNode, _Colors: [UIImage?]){
        
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
        
        rotateObject(_Name: "Cube", _Radians: 0.005)
        
        rotateObject(_Name: "CubeTwo", _Radians: 0.008)
        
        //updateTextLabel()
        
        _DeltaTime += 1
        
        // Sleeps Update Function for given Interval in Nanoseconds
        Task{
            try! await Task.sleep(nanoseconds: _UpdateInterval)
            Update(_UpdateInterval: _UpdateInterval)
        }
        
    }
    
    // Find SCNNode by Name (String), then rotates a given object by given the given amount, in radians.
    func rotateObject(_Name: String, _Radians: Double){
        
        // Find SCNNode with respective Name
        let _SCNObject = rootNode.childNode(withName: _Name, recursively: true)
        
        if (_SCNObject?.name == "CubeTwo" || (_SCNObject?.name == "Cube" && isRotating)){
            
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
        
        //var _Str = "Position: \(_SCNObject?.position)"
        
        if (_SCNObject?.name == "Cube"){
            let posX = _SCNObject?.position.x
            let posY = _SCNObject?.position.y
            let posZ = _SCNObject?.position.z
            
            let rotX = String(format: "%.2f", (_SCNObject?.rotation.x)!)
            let rotY = String(format: "%.2f", (_SCNObject?.rotation.y)!)
            let rotZ = String(format: "%.2f", (_SCNObject?.rotation.z)!)
            
            let SCNObjectPosition = "\(posX!),\(posY!),\(posZ!)"
            let SCNObjectRotation = "\(rotX),\(rotY),\(rotZ)"
            
            updateTextLabel(_InputString: "Position: \(SCNObjectPosition)\nRotation: \(SCNObjectRotation)\n\(_DeltaTime/1000)")
        }
            
    }
    
    /*
     Double Tap Handler
     Toggles isRotating and indicatest to the scene whether to rotate "Cube"
     */
    @MainActor
    func doubleTapHandler(){
        
        _RotAngle = _DragAngle
        
        // Flip the Boolean. Toggle it
        isRotating = !isRotating
        
        // Update Text
        //updateTextLabel()
        
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
    
    /*
     Magnification Gesture Handler
     */
    @MainActor
    func magnificationHandler(_Magnification: CGFloat){
        
        if (isMagnifying == false){
            
            _StartMagnificationAmt = _Magnification
            isMagnifying = true
            
        } else {
            
            if (_StartMagnificationAmt < _Magnification){
                _CameraNode.localTranslate(by: SCNVector3(0,0,-(_Magnification - _StartMagnificationAmt)/3))
                
                // Center (once) _TextNode. Find the center of Local X and transform by that amount.
                centerTextLabel(_TextNode: _TextNode)
                
            } else {
                _CameraNode.localTranslate(by: SCNVector3(0,0,(_StartMagnificationAmt-_Magnification)))
                
                // Center (once) _TextNode. Find the center of Local X and transform by that amount.
                centerTextLabel(_TextNode: _TextNode)
                
            }
        
        }
        
    }
    
    func endMagnify(){
        isMagnifying = false
    }
    
    @MainActor
    func twoFingerDragHandler(){
        print("FUCK")
    }
    
    /*
     Initialize the Text Label
     */
    func initTextLabel(){
        
        // Init _TextNode to SCNTextLabel Values
        _TextNode = SCNNode(geometry: SCNTextLabel)
        
        // Center (once) _TextNode. Find the center of Local X and transform by that amount.
        centerTextLabel(_TextNode: _TextNode)
        
//        print(_TextNode.scale)
//        _TextNode.scale = SCNVector3(0.1, 0.1, 0.1)
//        print(_TextNode.scale)
        
        //_TextNode.position = SCNVector3(0,0,0)
        rootNode.addChildNode(_TextNode)
    }
    
    /*
     Updates Text Label and displays position, pitch, yaw, and roll
     */
    func updateTextLabel(_InputString: String){
        
        // Find SCNNode with respective Name
        let _SCNObject = rootNode.childNode(withName: "Cube", recursively: true)
        
        // Directly set the contained SCNText.string (which is inside my SCNNode)
        SCNTextLabel.string = "\(String(describing: _InputString))"
        
    }
    
    /*
     Helper Function to center Text
     */
    func centerTextLabel(_TextNode: SCNNode){
        
        // Set the Text to be relative to CameraNode, and rotated in the same direction as it.
        _TextNode.position = _CameraNode.position
        _TextNode.rotation = _CameraNode.rotation
        
        print(_TextNode.position)
        _TextNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        var _centerX = (SCNTextLabel.boundingBox.max.x - SCNTextLabel.boundingBox.min.x)/2
        var _centerY = (SCNTextLabel.boundingBox.max.y - SCNTextLabel.boundingBox.min.y)/2
        
        _centerX -= SCNTextLabel.boundingBox.min.x
        _centerY -= SCNTextLabel.boundingBox.min.y
        
        _TextNode.localTranslate(by: SCNVector3(-0.7, -0.5, -3))
        
    }
    
    /*
     Helper Function: Resetting the Cubes. Typically will be called from outside the Scene by a Button.
     Zero out all Position and Rotation value back to default
     */
    func resetCubes(){
        // Current Rotation Angle
        _RotAngle = CGSize.zero
        
        // Drag Gesture Translation Offset
        _DragAngle = CGSize.zero
    
        // Manually find the cubes and edit them directly. Find SCNNode with respective Name
        let _SCNCube = rootNode.childNode(withName: "Cube", recursively: true)
        let _SCNCubeTwo = rootNode.childNode(withName: "CubeTwo", recursively: true)
        
        _SCNCube?.position = SCNVector3(0,0,0)
        _SCNCubeTwo?.position = SCNVector3(0,-5,0)
        
    }
    
    /*
     Helper function to create lights with specified parameters:
     _Position : SCNVector3 - Position at which to spawn the Light
     _LightType : String - Type of light to create
     _Name : String - Name of SCNLight
     _Color : UIColor - Color of Light
        Defualt = UIColor.red
     _Intensity : Integer - Intensity of this light source
        Default = 100
     
     Returns: The created Light
     */
    func spawnLight(_Position : SCNVector3, _LightType : SCNLight.LightType, _Name : String = "def", _Color : UIColor = UIColor.red, _Intensity : CGFloat = 100) -> SCNNode{
        
        let _CreatedLight = SCNNode()
        _CreatedLight.light = SCNLight()
        
        _CreatedLight.position = _Position
        _CreatedLight.light?.type = _LightType
        _CreatedLight.name = _Name
        _CreatedLight.light?.color = _Color
        _CreatedLight.light?.intensity = _Intensity
        _CreatedLight.rotation = diffuseLightPos
        rootNode.addChildNode(_CreatedLight)
        
        return _CreatedLight
    }
    
    func toggleLight(_InputLight: SCNNode, _Toggler: inout Bool, _OriginalIntensity: CGFloat){
        
//        var _Toggler : Bool
        
//        if (_LightType == SCNLight.LightType.ambient){
//            _Toggler = _AmbientLightToggle
//            _AmbientLightToggle = !_AmbientLightToggle
//        } else if (_LightType == SCNLight.LightType.spot){
//            _Toggler = _FlashlightToggle
//            _FlashlightToggle = !_FlashlightToggle
//        } else {
//            _Toggler = _DiffuseLightToggle
//            _DiffuseLightToggle = !_DiffuseLightToggle
//        }
        
        print(_Toggler)
        
        if (_Toggler){
            _InputLight.light?.intensity = 0
        } else {
            _InputLight.light?.intensity = _OriginalIntensity
        }
        print(_InputLight.light?.intensity)
        
        _Toggler = !_Toggler
        
    }
    
}
