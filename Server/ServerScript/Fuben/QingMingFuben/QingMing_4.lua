Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1605

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {8100, 8400}  
tbFubenSetting.tbTempRevivePoint = {8100, 8400}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {8830, 8650}, nDir = 0},              -- 使用道具者
    {tbPos = {8245, 9160}, nDir = 19},             -- 协助者
}

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
   
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2257, nLevel = -1, nSeries = 0},  --纪念石碑
    [2] = {nTemplate = 2243, nLevel = -1, nSeries = 0},  --卓非凡
    [3] = {nTemplate = 2253, nLevel = -1, nSeries = 0},  --紫轩
    [4] = {nTemplate = 2276, nLevel = -1, nSeries = 0},  --纪念石碑（展示）
}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            --纪念石碑 
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_4_ShiBei", false, 39},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_4_Npc1", false, 0, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 8, "心魔幻境 剑气峰"},
            {"SetKickoutPlayerDealyTime", 20},
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
        },
    },
    [2] = {nTime = 3, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "不远处有一块碑石，这是……剑气峰？我怎麽会到了这里？"},
            {"PlayerBubbleTalk", "紫轩姑娘，这是怎麽回事？你怎会在这里？"}
        },
    },
    [3] = {nTime = 3, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "前方的石碑上似乎有些文字，不妨去看看上面写了什麽"},   
            {"SetFubenProgress", -1, "查看石碑"}, 
        },
    },
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            --祭拜开始时解锁，刷出Npc纳兰潜凛
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_4_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path4", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 0}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "此处……是剑气峰？我不是已经…怎地又回来了？莫非是上天要再给我一次机会称霸武林？", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "唉，我在此伫立，你却视而不见，卓大哥，在你的心中，果真便只有名声与武功麽？", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "是你！紫轩！哼，你为了杨影枫那恶贼背叛我，竟然还有脸来见我？", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "卓大哥，你与杨大哥本是称兄道弟，手足情深，若是联手，武林早就是你的了。", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "闭嘴！你懂什麽？杨影枫非池中之物，武功极高，连你都被他迷了心窍，我岂能不除？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "唉，卓大哥，天下英才如此之多，你又岂能尽数除去？难道你便没有後悔过吗？", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "後悔？哈哈哈，笑话！成王败寇，本应如此！我只不过输在运气上！没有学得武道德经！", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "卓大哥，想不到最终你仍是痴迷不悟，本想这清明佳节，能好好祭拜你……", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "你、你说什麽？祭拜？不！不可能！我明明活得好好的！我还要称霸武林！", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "此处乃心魔幻境，是能够实现人心底最深处的梦想的地方，我一心希望你能改过自新，可惜……", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "你、你放屁！你、你胡说！这不可能是一个幻境，这一定是上天觉得我有此才干，让我重出江湖！", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "罢了，话不投机半句多，道不同不相为谋，卓大哥，今日一别，无缘再会，愿你能够安息，下辈子，莫要再害人。", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "哈哈哈，你在说些什麽疯言疯语，我是天下第一，哈哈哈哈，我是藏剑山庄庄主卓非凡！哈哈哈！", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "你我就此别过。珍重。", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 8930, 9400, 39}, 

            --纳兰真 
            {"AddSimpleNpc", 2253, 8380, 8760, 8}, 
        },
    },
    [100] = {nTime = 600, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"SetShowTime", 100},
            --{"SetFubenProgress", -1, "即将离开"}, 
        },
        tbUnLockEvent = 
        {
            {"GameLost"},
        },
    },
}