using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
public class 进入游戏 : MonoBehaviour
{
    public string scene= "小镇外（路牌处）";
    public void Startgame()
    {
        SceneManager.LoadScene(scene);
    }
}
