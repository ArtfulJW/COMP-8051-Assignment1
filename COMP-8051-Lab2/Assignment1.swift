//
//  PersonalPlayground.swift
//  COMP-8051-Lab2
//
//  Created by Jay Wang on 2024-01-24.
//

/*
 All work should be done individually.

 [][1 marks] Create an app that runs on an iOS device (you can assume at least iOS 14.0) with a single cube shown in perspective projection. Each side of the cube should have a separate colour, as shown in class.
 [][1 marks] Modify the app so a double-tap toggles whether the cube continuously rotates about the y-axis.
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
    
    // Initialize Camera
    /*
     Tentatively initialize a Node then later on, Assign a SCNCamera() to this Node. Which means, it gives this Node Camera Attributes.
     */
    var cameraNode = SCNNode()
    
    
    
}
