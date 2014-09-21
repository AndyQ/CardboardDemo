CardboardDemo
==================

## Overview ##

This is a simple app that demonstrates rendering a 3D scene on an iOS device so that it can be viewed on a stereoscopic viewer such as Google Cardboard.

It has very basic head tracking (no movement yet).

![Screenshot](http://andyq.github.io/CardboardDemo/images/cardboard.png)

## License ##

BSD-style, with the full license available in LICENCE.

## Usage ##

Download the project and run through Xcode on a device. It will run on the Simulator but the performance will be less than optimal, plus head-tracking
will not work.


## Acknowledgments ##

A big thanks for the following:

The perspective projection shader and texture rendering code was based on Brad Lawson's OculusRiftSceneKit demo (https://github.com/BradLarson/OculusRiftSceneKit)

The GLProgram wrapper was taken from Jeff LaMarche's Simple OpenGLES 2.0 Example (https://github.com/jlamarche/iOS-OpenGLES-Stuff)
