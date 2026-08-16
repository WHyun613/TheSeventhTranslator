using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "新物品配置表", menuName = "物品/物品配置表")]
public class 物品配置表 : ScriptableObject
{
    public List<物品数据> 物品列表 = new List<物品数据>();
    public 物品数据 查找物品(string ID)
    {
        foreach (var 物品 in 物品列表)
        {
            if (物品.ID == ID)
            {
                return 物品;
            }
        }
        return null;
    }
}