EXTERNAL give_item(item_id)
EXTERNAL load(key)
EXTERNAL save(key,number)
EXTERNAL changesence(name)

VAR chat_count = 0
VAR boom = 0
VAR tutorial_done = 0
-> start
== start ==
~ chat_count = load("第二天Tomas对话")
~ boom = load("第二天是否盖章")
~ tutorial_done = load("第二天是否发出质疑")
{chat_count == 0:
    Tomas：对了，我昨天忘记和你说，对于这些原住民的案件，我们的审核周期是五天，一到四天确认证据，第五天正式审判。在这五天里你基本只需要处理案件相关的译文。
    Tomas：这份工作应该还算轻松？前提是你不要给自己找麻烦。也别管那群野蛮人说了什么。这是上边给的关于昨天那份案子的补充说明
    -> last
- else:
    {boom == 0:
        Tomas：去完成你的工作
        -> last
    - else:
        {tutorial_done == 0:
            Tomas：ok（打哈欠），非常好，你的工作就是这么简单。
            ~ changesence("第三天译者房间")
            -> last
        - else:
            Tomas：接过证据查看并皱眉
            Tomas：边界变化是镇子发展的正常模式，不是你该操心的事情。这文字…好吧，确实又存在一些疑问，我会按照流程上报你的修改和证据。
            ~ changesence("第三天译者房间")
            -> last
        }
    }
    
}


== last ==
~ save("第二天Tomas对话",1)
~ save("是否盖章",0)
~ save("是否发出质疑",0)

-> END