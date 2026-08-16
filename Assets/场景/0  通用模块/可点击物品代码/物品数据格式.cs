using UnityEngine;

[System.Serializable]
public class 物品数据
{
    public string ID;
    public Sprite 图标;
    [TextArea]
    public string 描述;
    [TextArea]
    public string 悬停提示; 
}