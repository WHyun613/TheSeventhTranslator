using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections.Generic;

public class 桌面放置管理器 : MonoBehaviour
{
    public Transform 放置位置锚点;
    public List<string> 允许放置的场景列表;
    public 物品配置表 配置表Asset;

    private GameObject 当前显示的物品对象;

    public static 桌面放置管理器 Instance;

    private void Awake()
    {
        Instance = this;
    }

    public bool 当前场景允许放置吗()
    {
        string 当前场景名 = SceneManager.GetActiveScene().name;
        return 允许放置的场景列表.Contains(当前场景名);
    }

    public void 放置物品(string 物品ID)
    {
        if (配置表Asset == null)
        {
            Debug.LogWarning("物品配置表Asset未赋值");
            return;
        }

        var 配置 = 配置表Asset.查找物品(物品ID);
        if (配置 == null || 配置.图标 == null)
        {
            Debug.LogWarning($"放置失败，物品配置未找到或无图标：{物品ID}");
            return;
        }

        if (当前显示的物品对象 != null)
        {
            Destroy(当前显示的物品对象);
        }

        GameObject 新物品 = new GameObject(物品ID);
        新物品.transform.position = 放置位置锚点.position;
        SpriteRenderer sr = 新物品.AddComponent<SpriteRenderer>();
        sr.sprite = 配置.图标;

        当前显示的物品对象 = 新物品;
        Debug.Log($"放置到桌面：{物品ID}");
    }

    private void OnDestroy()
    {
        if (当前显示的物品对象 != null)
        {
            Destroy(当前显示的物品对象);
        }
    }
}