CardboardDemo
==================

## Overview ##

This is a simple app that demonstrates rendering a 3D scene on an iOS device so that it can be viewed on a stereoscopic viewer such as Google Cardboard.

It has very basic head tracking - no forward/backward movement yet but full 360 degree rotation for GLKit and SceneKit demo scenes.

GLKit demo is pretty basic - just a grid of cubes at the moment<br>
SceneKit demo shows a cube of sheres all moving at different speeds

Both sampples render the scene twice and demonstrate rendering to texture techniques.

Also, have stereo image (side-by-side) support now.  Supports both parallel viewing (cardboard) and cross-eye (manual) viewing.
And allows you to capture your own 3D pictures).

## Capturing 3D pictures ##

```
To capture a 3D picture, first show the Stereo Image Viewer
  - Click the Capture button.  This will show the camera preview image in the left hand window.
  - Click the Capture button again to take the left hand picture and it then shows the preview image in the right hand window
  - Then, carefully, move your iPhone slightly to the right (approx 2-3cm) just enough to offset the image.
  - Press the Capture button again to capture the right hand picture.
```
## Screenshots ##

The Stereo Image Viewer
![Screenshot](http://andyq.github.io/CardboardDemo/images/stereopics.png)

The SceneKit demo (currently looks a little complex but looks great when viewed with Cardboard!
![Screenshot](http://andyq.github.io/CardboardDemo/images/scenekit.png)

The GLKit demo
![Screenshot](http://andyq.github.io/CardboardDemo/images/glkit.png)


## License ##

BSD-style, with the full license available in LICENCE.

## Usage ##

Download the project and run through Xcode on a device. It will run on the Simulator but the performance will be less than optimal, plus head-tracking will not work.


## Acknowledgments ##

A big thanks for the following:

The perspective projection shader and texture rendering code was based on Brad Lawson's OculusRiftSceneKit demo (https://github.com/BradLarson/OculusRiftSceneKit)

The GLProgram wrapper was taken from Jeff LaMarche's Simple OpenGLES 2.0 Example (https://github.com/jlamarche/iOS-OpenGLES-Stuff)
