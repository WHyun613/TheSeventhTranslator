using UnityEngine;

[RequireComponent(typeof(Canvas))]
public class 切换场景重新绑定摄像头 : MonoBehaviour
{
    public Canvas 画布;
    private Camera 当前绑定的相机;

    void Awake()
    {
        Debug.Log("获取到画布");
    }

    void Update()
    {
        if (画布.worldCamera == null)
        {
            Camera cam = FindObjectOfType<Camera>();
            if (cam != null && cam.gameObject.activeInHierarchy && cam.enabled)
            {
                画布.worldCamera = cam;
                Debug.Log($"[{name}] 已绑定相机：{cam.name}");
            }
        }

    }

}