using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class 退出游戏 : MonoBehaviour
{
    public void quit()
    {
        Debug.Log("退出游戏");
        Application.Quit();
    }
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Debug.Log("鼠标左键按下了！Update检测正常，EventSystem也应该正常。");
        }
    }

}
