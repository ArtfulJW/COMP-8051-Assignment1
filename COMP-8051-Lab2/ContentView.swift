//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab01: Draw red square using SceneKit
// Lab02: Make an auto-rotating cube with different colours on each side
// Lab03: Make a rotating cube with a crate texture that can be toggled
// Lab04: Make a cube that can be rotated with gestures
// Lab05: Add text that shows rotation angle of rotating cube
// Lab06: Add diffuse light
// Lab07: Add flashlight
// Lab08: Add fog
//
//====================================================================

import SwiftUI
import SceneKit
import SpriteKit

let modelScene = ModelLoadingExample()  // This scene has to be global so the button and navigation views can both access

// We separate out the Button whose text will change so that we only update the button and not the whole ContentView when
//  the text changes
struct ChangeableButton: View {

    var body: some View {
        
        withObservationTracking {   // This is what tracks the observed property of modelScene and refreshes when it changes

            Button(action: {

                modelScene.toggleAnimation()

            }, label: {

                Text(modelScene.buttonText)
                    .font(.system(size: 24))
                    .padding(.bottom, 50)

            })

        }
        onChange: {}
    }
}

struct ContentView: View {
    @State var rotationOffset = CGSize.zero
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink{
                    let scene = RedSquare()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                } label: { Text("Lab 1: Red square") }
                NavigationLink{
                    let scene = RotatingColouredCube()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                } label: { Text("Lab 2: Rotating cube") }
                NavigationLink{
                    let scene = RotatingCrate()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                } label: { Text("Lab 3: Textured cube") }
                NavigationLink{
                    let scene = ControlableRotatingCrate()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 4: Rotatable cube") }
                NavigationLink{
                    let scene = ControlableRotatingCrate()
                    ZStack {
                        SceneView(scene: scene, pointOfView: scene.cameraNode)
                            .ignoresSafeArea()
                            .onTapGesture(count: 2) {
                                scene.handleDoubleTap()
                            }
                            .gesture(
                                DragGesture()
                                    .onChanged{ gesture in
                                        scene.handleDrag(offset: gesture.translation)
                                    }
                            )
                        Text("Hello World")
                            .foregroundStyle(.white)
                    }
                } label: { Text("Lab 5: Text examples") }
                NavigationLink{
                    let scene = RotatingCrateLight()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 6: Diffuse lighting") }
                NavigationLink{
                    let scene = RotatingCrateFlashlight()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 7: Spotlight (flashlight)") }
                NavigationLink{
                    let scene = RotatingCrateFog()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 8: Fog") }
                NavigationLink{
                    VStack {
                        SceneView(scene: modelScene, pointOfView: modelScene.cameraNode)
                            .ignoresSafeArea()
                            .onTapGesture(count: 2) {
                                modelScene.handleDoubleTap()
                            }
                        ChangeableButton()
                    }
                    .background(.black)
                } label: { Text("Lab 9: Model loading") }
            }.navigationTitle("COMP8051")
            
            NavigationLink{
                // Initialize a SCNScene of 'type' Assignment1
                let scene = Assignment1()
                
                // Initialize a SceneView of the respective SCNScene w/ the respective Camera
                SceneView(scene: scene, pointOfView: scene._CameraNode)
                    .ignoresSafeArea()
                // Double Tap Event Listener
                    .onTapGesture(count: 2){
                        // Detect Double Tap Gesture, then handle event
                        scene.doubleTapHandler()
                    }
                // Attach Drag Gesture Listener
                    .gesture(
                        DragGesture(minimumDistance: 0.01).onChanged{ gesture in
                            scene.dragHandler(_Offset: gesture.translation)
                        }
                    )
                    .gesture(
                        MagnifyGesture().onChanged({ gesture in
                            scene.magnificationHandler(_Magnification: gesture.magnification)
                        }).onEnded({gesture in scene.endMagnify()})
                    )
                    .gesture(
                        DragGesture().simultaneously(with: DragGesture()).onChanged{
                            gesture in scene.twoFingerDragHandler()
                        }
                    )
                
                Button("Reset Cubes"){
                    print("Reset Position and Rotations")
                    scene.resetCubes()
                }
                Button("Toggle Diffuse Light"){
                    scene.toggleLight(_InputLight: scene._SCNDiffuseLight, _Toggler: &scene._DiffuseLightToggle, _OriginalIntensity: 1000)
                }
                Button("Toggle Flashlight Light"){
                    scene.toggleLight(_InputLight: scene._SCNFlashlight, _Toggler: &scene._FlashlightToggle, _OriginalIntensity: 10000)
                }
                Button("Toggle Ambient Light"){
                    scene.toggleLight(_InputLight: scene._SCNAmbientLight, _Toggler: &scene._AmbientLightToggle, _OriginalIntensity: 200)
                }
                
                
            } label: { Text("Assignment 1") }
            
        }
    }
}

#Preview {
    ContentView()
}
