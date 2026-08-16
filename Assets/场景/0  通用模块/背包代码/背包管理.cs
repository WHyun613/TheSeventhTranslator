using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;
public class 背包管理 : MonoBehaviour
{
    public static bool 背包打开中 = false;
    public static 背包管理 Instance;
    [Header("UI 引用")]
    public Transform 格子容器;          
    public GameObject 背包格子Prefab;   
    public GameObject 悬停提示框;       
    public TMP_Text 悬停提示文字;
    private bool 是否打开 = false;
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

    private void OnDestroy()
    {
        人物背包.On获得物品-=刷新背包;
    }

    private void Start()
    {
        gameObject.SetActive(false);
        悬停提示框.SetActive(false);
    }
    public void 切换背包()
    {
        是否打开=!是否打开;
        gameObject.SetActive(是否打开);
        背包打开中 = 是否打开;
        if (是否打开)
        {
            刷新背包();
        }
        else
        {
            隐藏悬停提示();
        }
    }

    void 刷新背包(string 物品ID = null, int 数量 = 0)
    {
        foreach (Transform child in 格子容器)
        {
            Destroy(child.gameObject);
        }
        foreach (var kvp in 人物背包.Instance.背包)
        {
            string id=kvp.Key;
            int num = kvp.Value;
            物品数据 数据 = 人物背包.Instance.配置表.查找物品(id);
            if (数据==null) continue;
            GameObject 格子=Instantiate(背包格子Prefab, 格子容器);
            Image 图标 = 格子.transform.Find("图标")?.GetComponent<Image>();
            if (图标 != null) 图标.sprite=数据.图标;
            TMP_Text 数量文字 = 格子.transform.Find("数量文字")?.GetComponent<TMP_Text>();
            if (数量文字 != null)数量文字.text=num>1?"x"+num:"";
            背包格子悬停 悬停脚本 = 格子.GetComponent<背包格子悬停>();

            if (悬停脚本 != null)
            {
                悬停脚本.设置提示(数据.悬停提示);
                悬停脚本.设置描述(数据.描述);
                悬停脚本.设置ID(id);
            }
        }

    }
    public void 显示悬停提示(string 文字)
    {
        悬停提示框.SetActive(true);
        悬停提示文字.text = 文字;
    }
    public void 隐藏悬停提示()
    {
        悬停提示框.SetActive(false);
    }
}
