EXTERNAL give_item(item_id)
EXTERNAL load(key)
EXTERNAL save(key,number)
EXTERNAL changesence(name)


VAR chat_count = 0
VAR has_dict = 0
VAR boom = 0
VAR tutorial_done = 0
-> start
== start ==
~ chat_count = load("第一天Tomas对话")
~ has_dict = load("是否有词典")
~ boom = load("是否盖章")
~ tutorial_done = load("是否发出质疑")

{chat_count == 0:
    Tomas：尊敬的————您好，由于您出色的灰碑文（注：圣卢西亚原住民语言）语言能力和沟通能力，恭喜您成为圣卢西亚的第七位译者。
    Tomas：您的职责是核对这些野蛮的原住民文字和审判理由的对应度，具体翻译请参考这本《灰碑文标准辞典》。
    ~ give_item("官方词典")
    ~ has_dict = 1
    Tomas：今天这份很简单，是边界案。记住我说的话，译文审核遵照词典就好，别给自己添加工作量。
    ~ give_item("案卷：卖盐老人")
    -> last
- else:
    {boom == 0:
        Tomas：去完成你的工作。
        -> last
    - else:
        {tutorial_done == 0:
            Tomas：ok（打哈欠），非常好，你的工作就是这么简单。
            ~ changesence("第二天译者房间")
            -> last
        - else:
            Tomas：才刚来一天就开始找麻烦了？（接过证据查看并皱眉）
            Tomas：好吧，今天你标记存疑的部分确实有点问题，我会按照流程上报你的修改和证据。
            ~ changesence("第二天译者房间")
            -> last
        }
    }
}
== last ==
~ save("第一天Tomas对话",1)
~ save("是否有词典",0)
~ save("是否盖章",0)
~ save("是否发出质疑",0)

-> END