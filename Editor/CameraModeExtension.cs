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

        private static readonly GUIContent[] MODE_NAMES =
        {
            new GUIContent("UV0 xy"),
            new GUIContent("UV0 zw"),
            new GUIContent("UV1 xy"),
            new GUIContent("UV1 zw"),
            new GUIContent("UV2 xy"),
            new GUIContent("UV2 zw"),
            new GUIContent("UV3 xy"),
            new GUIContent("UV3 zw"),
            new GUIContent("UV4 xy"),
            new GUIContent("UV4 zw"),
            new GUIContent("UV5 xy"),
            new GUIContent("UV5 zw"),
            new GUIContent("UV6 xy"),
            new GUIContent("UV6 zw"),
            new GUIContent("UV7 xy"),
            new GUIContent("UV7 zw"),
            new GUIContent("Local Position"),
            new GUIContent("Vertex Color/RGB"),
            new GUIContent("Vertex Color/R"),
            new GUIContent("Vertex Color/G"),
            new GUIContent("Vertex Color/B"),
            new GUIContent("Vertex Color/A"),
            new GUIContent("Vector/Local Normal"),
            new GUIContent("Vector/World Normal"),
            new GUIContent("Vector/World Normal (Line)"),
            new GUIContent("Vector/Local Tangent"),
            new GUIContent("Vector/World Tangent"),
            new GUIContent("Vector/World Tangent (Line)"),
            new GUIContent("Vector/Tangent W"),
            new GUIContent("Vertex ID"),
            new GUIContent("Face Orientation")
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
