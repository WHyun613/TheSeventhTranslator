

using UnityEngine;

public class 场景物品 : MonoBehaviour
{
    [Header("物品配置")]
    public string 物品ID;
    public int 获得数量 = 1;
    private void Start()
    {
        if (人物背包.Instance.查询(物品ID)==1)
        {
            gameObject.SetActive(false);
        }
    }
    void OnMouseDown()
    {

        人物背包.Instance.获得物品(物品ID, 获得数量);
        gameObject.SetActive(false);
        Debug.Log($"点击收集了：{物品ID} x{获得数量}");
    }
}