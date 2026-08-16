using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class 对话管理库 : MonoBehaviour
{
    [Header("Day1")]
    public int 第一天马车夫对话 = 0;
    public int 第一天Tomas对话 = 0;
    public int 是否有词典=0;
    public int 是否发出质疑=0;
    public int 是否盖章=0;
    [Header("Day2")]
    public int 第二天Tomas对话 = 0;
    public int 第二天是否发出质疑 = 0;
    public int 第二天是否盖章 = 0;
    public int 第二天是否与Marina有初次对话 = 0;
    public Dictionary<string, int> 变量池 = new Dictionary<string, int>();
    
    public static 对话管理库 Instance;
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
        变量池["第一天马车夫对话"] = 第一天马车夫对话;
        变量池["第一天Tomas对话"] = 第一天Tomas对话;
        变量池["是否有词典"] = 是否有词典;
        变量池["是否发出质疑"] = 是否发出质疑;
        变量池["是否盖章"] = 是否盖章;



        变量池["第二天Tomas对话"] = 第一天Tomas对话;
        变量池["第二天是否发出质疑"] = 是否发出质疑;
        变量池["第二天是否盖章"] = 是否盖章;
        变量池["第二天是否与Marina有初次对话"] = 第二天是否与Marina有初次对话;
    }
    public int 读(string key)
    {
        Debug.Log(变量池[key]);
        return 变量池[key];
    }
    public void 写(string key,int number)
    {
        变量池[key] += number;
        Debug.Log(变量池[key]);
    }
    public void 绑定Ink函数(Ink.Runtime.Story 故事)
    {
        故事.BindExternalFunction("load", (string key) =>
        {
            return 读(key);
        });

        故事.BindExternalFunction("save", (string key,int number) =>
        {
            写(key,number);
        });

        故事.BindExternalFunction("give_item", (string item_id) =>
        {
            if (人物背包.Instance != null)
            {
                人物背包.Instance.获得物品(item_id);
                Debug.Log($"Ink 触发给物品：{item_id}");
            }
            else
            {
                Debug.LogWarning($"[give_item] 人物背包实例不存在，物品 {item_id} 未获得");
            }
        });
        故事.BindExternalFunction("changesence", (string name) =>
        {
            对话控制.Instance.StartCoroutine(延迟切场景(name));
            Debug.Log($"准备切换场景：{name}");
        });
        故事.BindExternalFunction("search", (string name) =>
        {
            if (人物背包.Instance != null)
                return 人物背包.Instance.是否拥有(name);
            return 0;
        });
    }
    System.Collections.IEnumerator 延迟切场景(string scene_name)
    {
        人物背包.Instance.清除();
        yield return new WaitForSeconds(0.5f);
        UnityEngine.SceneManagement.SceneManager.LoadScene(scene_name);
    }

}
