using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class 按钮点击测试 : MonoBehaviour, IPointerDownHandler
{
    public void OnPointerDown(PointerEventData eventData)
    {
        Debug.Log("按钮接收到 PointerDown 事件");
    }
}