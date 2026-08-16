using UnityEngine;
using TMPro;

public class 弹出文本框控制 : MonoBehaviour
{
    public static 弹出文本框控制 Instance;

    [Header("UI 引用")]
    public TMP_Text 标题;
    public TMP_Text 内容;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
    private void Start()
    {
        gameObject.SetActive(false);
    }

    /// <summary>
    /// 显示弹出框
    /// </summary>
    public void 显示(string 标题文字, string 内容文字)
    {
        gameObject.SetActive(true);
        标题.text = 标题文字;
        内容.text = 内容文字;
    }

    /// <summary>
    /// 关闭弹出框
    /// </summary>
    public void 关闭()
    {
        gameObject.SetActive(false);
    }
}