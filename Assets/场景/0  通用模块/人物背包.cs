using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
public class 人物背包 : MonoBehaviour
{
    public static 人物背包 Instance;
    public 物品配置表 配置表;
    public GameObject 背包图标;
    public Dictionary<string, int> 背包 = new Dictionary<string, int>();
    public static event Action<string, int> On获得物品;
    private void Awake()
    {
        if (Instance==null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
        背包图标.SetActive(false);
    }
    public void 获得物品(string ID,int 数量=1)
    {
        if (背包图标.activeSelf == false) 背包图标.SetActive(true);
        if (背包.ContainsKey(ID))
        {
            背包[ID]+=数量;
        }
        else
        {
            背包.Add(ID,数量);
        }
        Debug.Log($"获得物品：{ID} x{数量}，当前总数：{背包[ID]}");
        On获得物品?.Invoke(ID, 数量);
    }
    public int 查询(string ID)
    {
        if (背包.ContainsKey(ID))
        {
            return 1;
        }
        return 0;
    }
    public int 是否拥有(string 物品ID)
    {
        if (背包.ContainsKey(物品ID))
            return 1;
        return 0;
    }
    public void 清除()
    {
        背包.Clear();
    }
}
