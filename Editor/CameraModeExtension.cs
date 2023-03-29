#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace lilSceneViewExtensions
{
    public class CameraModeExtension
    {
        private static Shader shaderAttributeViewer = Shader.Find("Hidden/_lil/AttributeViewer");
        private static readonly int propMode = Shader.PropertyToID("_AVOutputMode");

        private const string SECTION_NAME = "lil";
        private const string MODE_ATTRIBUTE = "Vertex Attribute";

        private static readonly string[] MODE_NAMES =
        {
            "UV/UV0 xy",
            "UV/UV0 zw",
            "UV/UV1 xy",
            "UV/UV1 zw",
            "UV/UV2 xy",
            "UV/UV2 zw",
            "UV/UV3 xy",
            "UV/UV3 zw",
            "UV/UV4 xy",
            "UV/UV4 zw",
            "UV/UV5 xy",
            "UV/UV5 zw",
            "UV/UV6 xy",
            "UV/UV6 zw",
            "UV/UV7 xy",
            "UV/UV7 zw",
            "Local Position",
            "Vertex Color/RGB",
            "Vertex Color/R",
            "Vertex Color/G",
            "Vertex Color/B",
            "Vertex Color/A",
            "Vector/Local Normal",
            "Vector/World Normal",
            "Vector/World Normal (Line)",
            "Vector/Local Tangent",
            "Vector/World Tangent",
            "Vector/World Tangent (Line)",
            "Vector/Tangent W",
            "Vertex ID",
            "Face Orientation"
        };

        private static int currentMode = -1;

        [InitializeOnLoadMethod]
        private static void InitializeCameraMode()
        {
            SceneView.AddCameraMode(MODE_ATTRIBUTE, SECTION_NAME);
            EditorApplication.delayCall += SetupSceneViews;

            SceneView.duringSceneGui += view =>
            {
                var mode = view.cameraMode;
                if(mode.section != SECTION_NAME) return;
                switch(mode.name)
                {
                    case MODE_ATTRIBUTE:
                        if(currentMode == -1) currentMode = Shader.GetGlobalInt(propMode);
                        Handles.BeginGUI();
                        EditorGUI.BeginChangeCheck();
                        currentMode = EditorGUI.Popup(new Rect(0,0,120,16), currentMode, MODE_NAMES);
                        if(EditorGUI.EndChangeCheck())
                        {
                            Shader.SetGlobalInt(propMode, currentMode);
                        }
                        Handles.EndGUI();
                        break;
                }
            };
        }

        private static void SetupSceneViews()
        {
            if(shaderAttributeViewer == null)
            {
                shaderAttributeViewer = Shader.Find("Hidden/_lil/AttributeViewer");
            }
            foreach(SceneView view in SceneView.sceneViews)
            {
                view.onCameraModeChanged += mode =>
                {
                    if(mode.section != SECTION_NAME)
                    {
                        view.SetSceneViewShaderReplace(null, null);
                        return;
                    }
                    switch(mode.name)
                    {
                        case MODE_ATTRIBUTE:
                            view.SetSceneViewShaderReplace(shaderAttributeViewer, null);
                            break;
                    }
                };
            }
        }
    }
}
#endif