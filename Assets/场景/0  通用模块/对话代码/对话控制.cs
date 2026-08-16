using Ink.Runtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class 对话控制 : MonoBehaviour
{
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
    public static 对话控制 Instance;
    [Header("Ink 资源")]
    public TextAsset 默认对话文件;
    [Header("UI 引用")]
    public GameObject 对话面板;
    public GameObject 背景;
    public TMP_Text 对话文本显示位置;
    public Transform 选项位置;
    public GameObject 按钮;

    private Ink.Runtime.Story 故事;
    private bool 允许鼠标点击 = false;
    // Start is called before the first frame update
    void Start()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        if (对话面板 != null)对话面板.SetActive(false);
        if (背景 != null) 背景.SetActive(false);
    }
    void 清除旧选项()
    {
        for (int i = 选项位置.childCount - 1; i >= 0; i--)
        {
            Destroy(选项位置.GetChild(i).gameObject);
        }
    }
    
    public void 选择选项(int index)
    {
        故事.ChooseChoiceIndex(index);
        清除旧选项();
        允许鼠标点击 = true;
        Debug.Log("你选择了选项" + index);
        进入下一段对话();

    }
    void 显示选项()
    {
        清除旧选项();
        for(int i = 0; i < 故事.currentChoices.Count; i++)
        {
            Ink.Runtime.Choice choice = 故事.currentChoices[i];
            GameObject buttonObj = Instantiate(按钮, 选项位置);
            TMP_Text btnText = buttonObj.GetComponentInChildren<TMP_Text>();
            if (btnText != null)
            {
                btnText.text = choice.text;
            }
            Button btn = buttonObj.GetComponent<Button>();
            int choiceIndex = i;
            btn.onClick.RemoveAllListeners();
            btn.onClick.AddListener(() => 选择选项(choiceIndex));
        }
    }
    public void 进入下一段对话()
    {
        if (!允许鼠标点击) return;
        if (故事.currentChoices.Count > 0)
        {
            Debug.Log("你需要选择后才能进行对话");
            return;
        }
        if (故事.canContinue)
        {
            string line = 故事.Continue();
            对话文本显示位置.text = line;
            if (故事.currentChoices.Count > 0)
            {
                显示选项();
                允许鼠标点击 = false;
            }
            else
            {
                允许鼠标点击 = true;
            }


        }
        else if (故事.currentChoices.Count == 0)
        {
            对话面板.SetActive(false);
            背景.SetActive(false);
            清除旧选项();
            故事 = null;
            允许鼠标点击 = false;
            Debug.Log("对话结束。");
        }
    }
    public void 开始对话(TextAsset 这个NPC专属的对话文件)
    {
        TextAsset 要用的对话文件 = 这个NPC专属的对话文件 != null ? 这个NPC专属的对话文件 : 默认对话文件;

        if (要用的对话文件 == null)
        {
            Debug.LogError("对话文件为空！请检查该NPC的人物点击脚本里，有没有拖自己的Ink JSON文件。");
            return;
        }
        对话面板.SetActive(true);
        背景.SetActive(true);
        故事 = new Ink.Runtime.Story(要用的对话文件.text);
        对话管理库.Instance.绑定Ink函数(故事);
        Debug.Log("✅ 1. Ink 外部函数已绑定");
        清除旧选项();
        允许鼠标点击 = true;
        进入下一段对话();
    }
    // Update is called once per frame
    void Update()
    {
        
    }
}
