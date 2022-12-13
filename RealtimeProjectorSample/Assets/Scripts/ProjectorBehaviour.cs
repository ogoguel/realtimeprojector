using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using static UnityEngine.SpatialTracking.TrackedPoseDriver;

public class ProjectorBehaviour : MonoBehaviour
{
    [SerializeField]
    protected GameObject phonePrefab;
    [SerializeField]
    protected Material spotMaterial;

    ARTrackedImageManager trackedImageManager;
    AROcclusionManager occlusionManager;
    ARTrackedImage trackedImage;
    ARCameraManager cameraManager;

    GameObject trackedPhone;
    TrackableId trackedPhoneId;
    Matrix4x4 _UnityDisplayTransform = Matrix4x4.identity;

    LineRenderer lineRenderer;

    public void Start()
    {
        // To track the image store in the imageReferenceLibrary
        trackedImageManager = Camera.main.transform.parent.GetComponent<ARTrackedImageManager>();
        trackedImageManager.trackedImagesChanged += ArTrackedImageManager_trackedImagesChanged;

        // To retrieve the UnityDisplayTranssformation Matrix to apply to the Environment depth UVs
        cameraManager = Camera.main.transform.GetComponent<ARCameraManager>();
        cameraManager.frameReceived += Native_FrameReceived;

        // To retrieve the EnvironmentDepth texture to calculate the world position of the Camera pixels => LiDAR magic!
        occlusionManager = Camera.main.transform.GetComponent<AROcclusionManager>();

        lineRenderer = GetComponent<LineRenderer>();
    }

    // to retreive the AR Camera matrix
    private void Native_FrameReceived(ARCameraFrameEventArgs _arg)
    {
        if (_arg != null)
        {
            if (_arg.displayMatrix.HasValue)
            {
                _UnityDisplayTransform = _arg.displayMatrix.Value;
            }
        }
    }

    // when an image detected
    private void ArTrackedImageManager_trackedImagesChanged(ARTrackedImagesChangedEventArgs _arg)
    {
        foreach (var added in _arg.added)
        {
            // only support one phone!
            if (trackedPhone == null)
            {
                Debug.Log($"Adding {added.name}");
                trackedPhone = GameObject.Instantiate(phonePrefab);
                trackedPhone.transform.SetParent(added.transform, false);
                trackedPhoneId = added.trackableId;
            }
        }
        foreach (var removed in _arg.removed)
        {
            if (trackedPhone != null && removed.trackableId == trackedPhoneId)
            {
                Debug.Log($"Removing {removed.name}");
                GameObject.Destroy(trackedPhone);
                trackedPhone = null;
            }
        }
    }

    private void Update()
    {
        // Reference both variables to be used for our shader
        spotMaterial.SetTexture("_EnvironmentDepth", occlusionManager.environmentDepthTexture);
        spotMaterial.SetMatrix("_UnityDisplayTransform", _UnityDisplayTransform);

        if (trackedPhone != null)
        {
            // the direction of the beam is slightly below the forward of the plane (for esthetic purpose only=)
            var lightGO = trackedPhone.transform.GetChild(0);
            spotMaterial.SetVector("_Direction", lightGO.forward);
            spotMaterial.SetVector("_Center", trackedPhone.transform.position);

            lineRenderer.SetPosition(0, trackedPhone.transform.position+ trackedPhone.transform.forward/2);

            // raycast between the phone position and the playspace (might need a few secons do be captured)
            Ray ray = new Ray(trackedPhone.transform.position, lightGO.forward);
            if (Physics.Raycast(ray, out RaycastHit hit, 10.0f))
            {
                spotMaterial.SetVector("_Target", hit.point);
                lineRenderer.SetPosition(1, hit.point);
            }       
        }
    }
}

