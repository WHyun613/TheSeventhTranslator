using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class 进入场景触发对话 : MonoBehaviour
{
    public TextAsset 进入场景触发的对话文件;
    void Start()
    {
        if (进入场景触发的对话文件 != null && 对话控制.Instance != null)
        {
            对话控制.Instance.开始对话(进入场景触发的对话文件);
        }
    }
}
