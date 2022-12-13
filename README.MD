
# Real Time Projector

  

## Requirements

* Unity 2021.3 LTS

* ARFoundation

* iPhone with Lidar support (iPhone 12+ Pro)

* An addition phone

  

# How to test it ?

You obviously need 2 phones :

* One phone to display the tracking image (from the ImageDetection SDK from Apple)

* One Lidar powered phone to run the sample

  

# How does it work ?

  

* Activate the ARTrackedImageManager (must be located nearby the XROriginComponent)

* Fill the ImageReferenceLibrary with the tracked image

* When an image is tracked, attach the phone prefab (in my case just an Axis to it) to automatically follow the real phone

* Activate the AROcclusionManager to render the EnvironmentDepthTexture

* Add a full screen renderer (similar to the CameraBackground renderer) to display a full screen FX using the EnvironmentDepth and the phone position

  

## References

* Linkedin Original Post : https://www.linkedin.com/oliviergoguel

  

## Revisions

* Initial Release