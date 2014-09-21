OculusRiftSceneKit
==================

Forked from [OculusRiftSceneKit](http://github.com/BradLarson/OculusRiftSceneKit) by [Brad Larson](http://twitter.com/bradlarson) / [Sunset Lake Software](http://www.sunsetlakesoftware.com)

![screenshot](https://cloud.githubusercontent.com/assets/5468481/4019243/870cf41a-2a61-11e4-9eb4-f01aed5974fb.png)

Updates:

- Updated OculusRift SDK to 0.4.1. **The OculusSceneKitTest example works with the Oculus Rift DK2!**
- Fullscreen for VR screens, standard window for 2D screens.
- Mouse/keyboard input. Hold down the mouse button or the W key to move in the direction you're looking (turn the headset to turn). S to move backwards, A and D to move (not turn) left and right.
- Lights can autofollow the avatar. The demo has an omni to light up the general area, and a spotlight pointed where you're looking.
- Player interaction based on distance to object. Try walking up to the podium (it should light up) and pressing space (the text should change).

Known Issues and Planned Features:

- The distortion shader is not updated for the new SDK and is missing chromatic aberration.
- The other two examples probably need Scene.h and .m from OculusSceneKitTest, and a lot of Xcode project changes.
- Controls are missing jumping, 2D turning, and 3D movement (flying instead of walking)
- 2D mode should be rendered *without* distortion unless specifically enabled for testing or video recording.
- DAE files for 3D objects are partially supported.

Tutorial:

1. Download the [Oculus Rift SDK for Mac OS](https://developer.oculusvr.com/?action=dl) (requires free developer account) and install it at /Applications/Oculus/SDK

2. Open the Xcode project for OculusSceneKitTest.

	If LibOVR is red (files not where Xcode expects them), delete it and drag your copy from the Finder into the Xcode project, then replace libovr.a (also red) in Build Phases: Link Binary with Libraries with your copy from /Libraries/LibOVR/Lib/Mac/Debug (in the Xcode project).

	If you had to do that, you probably didn't install LibOVR where I told you to (/Applications/Oculus/SDK/LibOVR).  You'll also need to change your Library and Header search paths to the actual location.

	If you're going to be using OculusSceneKitTest as a template for multiple projects, save it with these changes so you don't have to do this again.

3. To make a new scene, subclass Scene. The scene named in Info.plist/Default scene will be loaded at startup. See HolodeckScene for an example, or the tutorial linked below.

---

Original description by Brad Larson below:

---

## Overview ##

These are a series of classes that add Oculus Rift VR headset support to Scene Kit, as well as at least one sample application to show them in action. These Objective-C classes encapsulate the stereoscopic 3-D rendering required for the Rift, as well as the head tracking it provides. This should hopefully make it pretty easy to rig up virtual reality scenes using Scene Kit's Objective-C API.

![pre-fork screenshot](https://cloud.githubusercontent.com/assets/5468481/4019269/a31d769c-2a62-11e4-96f0-b8bca32c5bc7.jpg)

## License ##

BSD-style, with the full license available with the framework in License.txt.

The Oculus Rift SDK and libraries are covered by their own license, which can be found in the LibOVR directory.

## Usage ##

To use this in a Scene Kit project, you'll need to add the OculusRiftDevice, OculusRiftSceneKitView, and GLProgram classes to your project.

Configure a window that goes fullscreen with an OculusRiftSceneKitView within it. This class will handle the rendering and head tracking for you. To set up your scene, create an SCNScene containing whatever you want to display in your environment and set that to the scene property on your OculusRiftSceneKitView instance. These classes will handle the rest. You can adjust the position of the head within the scene using the headLocation property on OculusRiftSceneKitView, and the spacing of the virtual eyes using the interpupillaryDistance property.

You'll also need to add the OVR.h and OVRVersion.h headers from LibOVR to your project, and link against the libovr.a library. Finally, I found that I needed to add the -fno-rtti compiler flag to OculusRiftDevice.mm in the Compile Sources build phase to get it to build cleanly.

Again, check out the test application in the examples/ directory to see this in action.

## Acknowledgments ##

I'd like to thank Mike Rotondo and Luke Iannini for their help in solving some of the perspective projection problems. Check out their much more elaborate Oculus Rift and Scene Kit project for more:

https://github.com/takataka/OpenWorldTest

I've also drawn a good chunk of code from Jeff LaMarche's excellent introduction to Scene Kit, which is well worth reading:

http://iphonedevelopment.blogspot.com/2012/08/an-introduction-to-scenekit.html
