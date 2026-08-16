using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class 人物点击 : MonoBehaviour
{
    public TextAsset 此角色对话文件;
    void OnMouseDown()
    {
        if (背包管理.背包打开中) return;
        if (对话控制.Instance == null)
        {
            Debug.LogError("找不到对话控制单例！确认对话UI Canvas 上挂了对话控制脚本。");
            return;
        }
        对话控制.Instance.开始对话(此角色对话文件);
    }
}
