EXTERNAL load(key)
EXTERNAL save(key,number)
VAR chat_count = 0
-> start
== start ==
~ chat_count = load("第一天马车夫对话")
车夫坐在一辆旧马车上，缰绳在手中缠绕。
{chat_count == 0:
    * 这里以前是玉米地？
        车夫：现在也是。
        但是我没有看见玉米。
        车夫：玉米在检查站下面，档案馆下面，整个镇子的下面都是玉米地。
        但我在地图上并没有看到它们。
        车夫：因为玉米不会说它们在这里，但它们就在这里等待。
        ->one
    * 离开
        （你转身离开。）
        ->one
- else:
   车夫：......
   （你转身离开。）
   ->one
}
== one ==
~ save("第一天马车夫对话",1)
-> END