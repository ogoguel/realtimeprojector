# Realtime Hand

Unity AR package to track your hand in realtime!

As seen on "Let's All Be Wizards!" : https://apps.apple.com/app/id1609685010

## Features
* 60 FPS hand detection
* 3D Bones world detection

## Sample Videos

https://user-images.githubusercontent.com/674951/152693534-cf32f285-c99c-4f66-acd8-c1d583603b19.mov

https://user-images.githubusercontent.com/674951/152869740-b0111ce1-e24d-4a8c-8aa0-8a98320e5e25.mov 


## Requirements
* Unity 2021.3 LTS 
* ARFoundation
* iPhone with Lidar support (iPhone 12+ Pro)
* An addition phone

# Real Time Projector

# How to test it ?
You obviously need 2 phones :
* One phone to display the tracking image (from the ImageDetection SDK from Apple)
*
* One Lidar powered phone to run the sample


# How does it work ?

* Activate the ARTrackedImageManager (must be located nearby the XROriginComponent)
* Fill the ImageReferenceLibrary with the tracked image
* When an image is tracked, attach the phone prefab (in my case just an Axis to it) to automatically follow the real phone
* Activate the AROcclusionManager to render the EnvironmentDepthTexture
* Add a full screen renderer (similar to the CameraBackground renderer) to display a full screen FX using the EnvironmentDepth and the phone position

## References
* Linkedin Original Post : https://www.linkedin.com/posts/oliviergoguel_unity-arkit-arfoundation-activity-6896360209703407616-J3K7


## Revisions
* Initial Release
