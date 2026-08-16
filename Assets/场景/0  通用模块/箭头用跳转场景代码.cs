using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using UnityEngine.EventSystems;

public class 箭头用跳转场景代码 : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [Header("场景切换")]
    public string scene;

    [Header("悬停渐变")]
    public Image 箭头图片;
    public float 渐变速度 = 3f;

    [Header("点击")]
    public Button 箭头按钮组件;

    void Start()
    {
        Color c = 箭头图片.color;
        c.a = 0f;
        箭头图片.color = c;
        if (箭头按钮组件 != null)
        {
            箭头按钮组件.transition = Selectable.Transition.None;
        }
    }
    public void OnPointerEnter(PointerEventData eventData)
    {
        StopAllCoroutines();
        StartCoroutine(渐变透明度(1f));
    }
    public void OnPointerExit(PointerEventData eventData)
    {
        StopAllCoroutines();
        StartCoroutine(渐变透明度(0f));
    }
    IEnumerator 渐变透明度(float 目标透明度)
    {
        while (!Mathf.Approximately(箭头图片.color.a, 目标透明度))
        {
            Color c = 箭头图片.color;
            c.a = Mathf.MoveTowards(c.a, 目标透明度, 渐变速度 * Time.deltaTime);
            箭头图片.color = c;
            yield return null;
        }
    }
    public void Startgame()
    {
        SceneManager.LoadScene(scene);
    }
}