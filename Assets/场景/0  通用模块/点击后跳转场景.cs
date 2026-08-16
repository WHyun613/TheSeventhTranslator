using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class 点击后跳转场景 : MonoBehaviour
{
    [Header("场景切换")]
    public string scene;
    // Start is called before the first frame update
    void OnMouseDown()
    {
        SceneManager.LoadScene(scene);
    }
}
