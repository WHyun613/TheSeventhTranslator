using UnityEngine;

public class 跨场景保留 : MonoBehaviour
{
    public static 跨场景保留 Instance;

    void Awake()
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
}