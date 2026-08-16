using UnityEngine;
using UnityEngine.EventSystems;

public class 背包格子悬停 : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
{
    private string 提示文字 = "";
    private string 描述文字 = "";
    private string 物品ID = "";
    public void 设置描述(string 文字)
    {
        描述文字 = 文字;
    }
    public void 设置提示(string 文字)
    {
        提示文字 = 文字;
    }
    public void 设置ID(string ID)
    {
        物品ID = ID;
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (!string.IsNullOrEmpty(提示文字))
        {
            背包管理.Instance.显示悬停提示(提示文字);
        }
    }


    public void OnPointerExit(PointerEventData eventData)
    {
        背包管理.Instance.隐藏悬停提示();
    }
    public void OnPointerClick(PointerEventData eventData)
    {
        Debug.Log($"点击了！描述文字={描述文字}");
        if (FindObjectOfType<桌面放置管理器>() != null
        && 桌面放置管理器.Instance.当前场景允许放置吗())
        {
            FindObjectOfType<桌面放置管理器>().放置物品(物品ID);
            return; 
        }
        if (弹出文本框控制.Instance != null && !string.IsNullOrEmpty(描述文字))
        {
            弹出文本框控制.Instance.显示("物品描述", 描述文字);
        }
        else
        {
            if (弹出文本框控制.Instance == null) Debug.Log("弹出文本框控制.Instance 是 null");
            if (string.IsNullOrEmpty(描述文字)) Debug.Log("描述文字是空的");
        }
    }
}