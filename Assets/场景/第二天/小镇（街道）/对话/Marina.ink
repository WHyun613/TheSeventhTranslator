EXTERNAL give_item(item_id)
EXTERNAL load(key)
EXTERNAL save(key,number)
EXTERNAL changesence(name)
EXTERNAL search(ID)
VAR first=0
VAR second=0
VAR titi=0
-> start

== start ==
~ first=load("第二天是否与Marina有初次对话")
~ second=search("旧地图")
{first ==0:
    Marina【着急的表情】：昨天你的译文审核是关于一位老人吗？他身材比较瘦削，皮肤黝黑，身材不高。这是他的照片。
    【marina掏出老人的照片】
    Marina：这位公公是我母亲的教父，我也一直将他当祖父看待，我知道他并没有非法越境。我希望我能够帮到他。我是这里的本地人你想要了解什么都可以来问我。
    玩家：你知道从哪里查找Santa Lucia的边境吗？
    marina：档案室应该有更详细的地图，记录了SantaLucia边境变化的全过程。
    玩家：边境变化？
    Marina：我也只是小时候听母亲说的，关于这个我也不太清楚
    ~ save("第二天是否与Marina有初次对话",1)
    Marina：当心！【扑过来】那小孩在摸你的钱包！
    神秘的小男孩：【迅速跑开】
    Marina：街道的治安不太好，你得把钱包放在能看到的位置。
    【你的钱包和一个破布袋子都躺在地上，袋子里的一张纸掉在外边】
    【你捡起那张纸，是一幅画】
    Marina:这孩子......得把包还给他，你先去档案室，我马上就到。
    ->leave
-else:
    {second==1&&titi==0:
        Marina【仓促的，面部有汗】：我来了，那个孩子跑的太快了。
        玩家：我已经从档案室回来了。
        Marina：你找到地图了吗？是不是真的和母亲说的一样呢…
        玩家：我得去和现在的边界对比一下看看。
        ~save("第二天是否与Marina有初次对话",10086)
        ->leave
    -else:
        {second==1&&first>=10086:
            玩家：话说起来，你是本地人吗？
            Marina：算半个，但是我十来岁就去总督府上学了。除了会说这里的话，能认识一些字，其他的方面和外来人没什么区别。
            玩家：你认识字？我其实怀疑官方词典对你们文字的解读有些偏差，一些地方的解释方式怪怪的。
            Marina：什么地方？或许你可以给我看看，也许有些文字我认识。
            玩家：…
            玩家：下次吧，有机会我再来问你，现在我有点事。
            Marina:好吧，我接下来的每天都会在这里等你，我很乐意为你…为爷爷做些什么。
            ->leave
        - else:
            Marina：我们之后再谈吧
            ->leave
        }
    }
}
== leave ==
~save("第二天是否与Marina有初次对话",0)
-> END
