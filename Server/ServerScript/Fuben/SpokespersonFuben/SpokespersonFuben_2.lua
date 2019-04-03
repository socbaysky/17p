Require("ServerScript/Fuben/SpokespersonFuben/ActivityFubenBase.lua")
local tbFubenSetting = Fuben.ActivityFuben:GetFubenSetting("SpokespersonFuben_2")
local nMapTemplateId = 1619

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/SpokespersonFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/SpokespersonFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {6500, 11200}  
tbFubenSetting.tbTempRevivePoint = {6500, 11200}  

tbFubenSetting.tbNeedSpecialPointFaction = {[2] = true, [3] = true, [6] = true, [8] = true, [10] = true, [12] = true} --需要特殊坐标的门派
tbFubenSetting.tbSpecialPoint = {7100, 4800, 56} --坐标，朝向
tbFubenSetting.tbSkillState = {1087, 600} --buff，持续时间（秒）
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
    [1] = {nTemplate = 2312, nLevel = -1, nSeries = 0},  --小怪1
    [2] = {nTemplate = 2313, nLevel = -1, nSeries = 0},  --小怪2
    [3] = {nTemplate = 2314, nLevel = -1, nSeries = 0},  --神秘剑客  
}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 5, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            {"SetKickoutPlayerDealyTime", 15},            

            {"SetFubenProgress", -1, "快去前方救她"}, 
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            

           {"SetTargetPos", 6577, 8379},

        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "冰石战场"},

            {"OpenWindowAutoClose", "StoryBlackBg", "你们两人本打算分头行事前去寻找线索，不料此事竟牵涉到两国之争，而你的她…刺客竟落入金军之手…你心急如焚，火速赶到了战场", nil, 2, 5, 1},

            {"StartTimeCycle", "cycle_1", 10, 2, {"PlayerBubbleTalk", "可恶！想不到方才来到此地就遭遇埋伏！"}},

            {"StartTimeCycle", "cycle_1", 10, 2, {"BlackMsg", "此处危险重重，不知道他怎麽样了？但愿平安无事！"}},    

            {"TrapUnlock", "TrapLock1", 2},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [3] = {nTime = 0, nNum = 10,
        tbPrelock = {2},
        tbStartEvent = 
        {
             {"SetFubenProgress", -1, "击败伏兵"}, 

            --刷怪
            {"AddNpc", 1, 6, 3, "guaiwu1", "Fuben_2_guaiwu_1", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 4, 3, "guaiwu2", "Fuben_2_guaiwu_1", 1, 0, 1, 0, 0},


            {"BlackMsg", "竟然有这麽多金兵埋伏！收拾他们！"},               
        },
        tbUnLockEvent = 
        {   
            {"BlackMsg", "就在不远处！马上就能相见了！"}, 
            
            {"SetFubenProgress", -1, "继续前进"}, 
            
            {"SetTargetPos", 6563, 5825},
        },
    },
   [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock2", 4},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [5] = {nTime = 0, nNum = 10,
        tbPrelock = {4},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击败伏兵"}, 

            --刷怪
            {"AddNpc", 1, 5, 5, "guaiwu3", "Fuben_2_guaiwu_2", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 4, 5, "guaiwu4", "Fuben_2_guaiwu_2", 1, 0, 0, 0, 0},
            {"AddNpc", 3, 1, 5, "guaiwu5", "Fuben_2_guaiwu_2", 1, 0, 0, 0, 0},

            {"BlackMsg", "我定要闯出这金军军营"},    

            --赵丽颖           
            {"NpcBubbleTalk", "guaiwu5", "哼！胆大包天的小子！受死！", 4, 0.5, 1},
        },
        tbUnLockEvent = 
        {   

            --{"NpcBubbleTalk", "Npc", "多谢你们救了我！", 4, 0.5, 1},

        },
    }, 
    [6] = {nTime = 5, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

            {"RemovePlayerSkillState", 1087},

            {"PlayerBubbleTalk", "我差点便以为要与你天人永隔了……"},

        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "离开军营"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
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