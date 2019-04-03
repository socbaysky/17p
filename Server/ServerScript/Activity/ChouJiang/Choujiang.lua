local tbAct = Activity:GetClass("ChouJiang")
tbAct.szMainKey = "ChouJiang"

tbAct.tbTimerTrigger = 
{ 
    [1] = {szType = "Day", Time = ChouJiang.szDayTime , Trigger = "LotteryDay"},                -- 每日抽奖时间点
    [2] = {szType = "Day", Time = ChouJiang.szBigDayTime , Trigger = "LotteryBig"  },           -- 大奖时间点
    -- [3] = {szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify"},           
    -- [4] = {szType = "Day", Time = "13:00" , Trigger = "SendWorldNotify"},          
    -- [5] = {szType = "Day", Time = "20:00" , Trigger = "SendWorldNotify"},           
}
-- , {"StartTimerTrigger", 3}, {"StartTimerTrigger", 4}, {"StartTimerTrigger", 5}
tbAct.tbTrigger = { 
					Init = {},
                    Start = {{"StartTimerTrigger", 1}, {"StartTimerTrigger", 2}},
                    LotteryDay = {},
                    LotteryBig = {},
                    End = {},
                    SendWorldNotify = { {"WorldMsg", "开心七月，幸运抽奖活动强力来袭，活跃度达[FFFE0D]60[-]以後去找[FFFE0D]襄阳纳兰真[-]领取奖券参加活动吧！", 1} },
                  }

tbAct.TYPE =
{
	BIG = 1, 							-- 大奖	
	DAY = 2, 							-- 每日抽奖
}

tbAct.nMaxVer = 10000 					-- 最大版本号

tbAct.tbTypeData = 
{
	[tbAct.TYPE.BIG] = {
		nMaxSaveCount = 3000; 			-- 每个table最多存的数据数量
		szBaseKey = "ChouJiangBig";		-- 存储Key
		nLimitCount = 1; 				-- 参加抽奖需要的次数,不配默认不限制(使用几次奖券才能参与抽奖)
		tbAward = ChouJiang.tbBigAward;
		nNewInfomationValidTime = 24*60*60*3;                                                                     -- 最新消息过期时间
		szNewInfomationTitle = "元宵大抽奖结果";                                        -- 最新消息标题
        -- 大奖抽奖的天数(以活动开始时间做校准的天数，活动开始那一天算第一天)
        nLotteryDay = ChouJiang.nBigExecuteDay;                                                      
        -- szWorldNotifyHit = "“迎国庆幸运抽奖”大奖活动结果已产生，请前往“最新消息”相关页面查看中奖名单。";        -- 开奖世界消息
        nDefaultShowIdx = 3;                                                                                    -- 最新消息中默认显示的奖励索引
        szAvMailText = "恭喜你参加「七月大抽奖」活动，获得[FFFE0D]幸运奖[-]，请查收！";                   -- 纪念奖邮件内容
        szRankMailText = "恭喜你参加「七月大抽奖」活动，获得[FFFE0D]%s[-]，附件为奖励，请查收！";       -- 排名奖励邮件内容,%s为奖励排名
        szMailTitle = "七月大抽奖";                                                                                   -- 邮件标题
        bOpen = true;                                                                                           -- 是否开放(不开放的话数据也是不存的)
        tbAVAward = ChouJiang.tbBigAVAward;
        tbShowRank = {[1] = true,[2] = true,[3] = true,[4] = true};
	},
	[tbAct.TYPE.DAY] = {
		nMaxSaveCount = 3000; 		   
		szBaseKey = "ChouJiangDay";	
		tbAward = ChouJiang.tbDayAward;
		nNewInfomationValidTime = 24*60*60*3;
		szNewInfomationTitle = "七月抽奖结果";
        --szWorldNotifyHit = "今日“迎国庆幸运抽奖”活动结果已产生，请前往“最新消息”相关页面查看中奖名单。";              
        nDefaultShowIdx = 3;
        szAvMailText = "恭喜你参加「七月抽奖」活动，获得[FFFE0D]幸运奖[-]，请查收！不要忘记在[FFFE0D]7月31日[-]还有七月大奖等你，奖励更丰厚，要记得来哦！";
        szRankMailText = "恭喜你参加「七月抽奖」活动，获得[FFFE0D]%s[-]，附件为奖励，请查收！不要忘记在[FFFE0D]7月31日[-]还有七月大奖等你，奖励更丰厚，要记得来哦！";
        szMailTitle = "七月抽奖";
        tbExecuteDay = ChouJiang.tbExecuteDay;                                                                            -- 活动期间第几天抽奖
        bOpen = true;                                                                                          -- 是否开放
        tbAVAward = ChouJiang.tbDayAVAward;
        tbShowRank = {[1] = true,[2] = true,[3] = true};
	},
}

--[[
-- 基础信息存库
    local tbBaseData = {}
    tbBaseData.nActVer = nStartTime                         -- 活动版本号(活动表里配的开始时间,因此重开活动记得把之前活动的数据从Activity.tab中删掉)
    tbBaseData.nBigVer = 1                                  -- 大奖数据当前存储版本号
    tbBaseData.nDayVer = 1                                  -- 每日抽奖数据当前存储版本号

--存库（每日抽奖和大奖一样的数据结构）
    local tbData = {}
    tbData.tbPlayer[pPlayer.dwID] = {}                      -- 玩家对应的使用数量
    tbData.tbPlayer[pPlayer.dwID].nCount = 0                -- 周卡过期时间
    tbData.tbPlayer[pPlayer.dwID].nWeekCardEndTime = 0
    tbData.nCount = tbData.nCount + 1                       -- 当前版本已有的数据条数
    tbData.nVer = nVersion                                  -- 当前存库数据的版本号

-- 缓存
    tbAct._tbActData = 
{
    tbBigData = {
        tbPlayer[pPlayer.dwID] = {}
        tbPlayer[pPlayer.dwID].nVer = tbData.nVer                 -- 存库的版本
        tbPlayer[pPlayer.dwID].nCount = 0                         -- 使用数量    
        tbPlayer[pPlayer.dwID].nWeekCardEndTime = 0               -- 周卡过期时间
        nCount = 0                                                -- 全部票数

    };
    tbDayData = {
        tbPlayer[pPlayer.dwID] = {}
        tbPlayer[pPlayer.dwID].nVer = tbData.nVer                 -- 存库的版本
        tbPlayer[pPlayer.dwID].nCount = 0                         -- 使用数量   
        tbPlayer[pPlayer.dwID].nWeekCardEndTime = 0               -- 周卡过期时间 
        nCount = 0                                                -- 全部票数   
    };
}
----------
]]

function tbAct:GetCacheData(nType)
	if nType == tbAct.TYPE.BIG then
		return self._tbActData.tbBigData
	elseif nType == tbAct.TYPE.DAY then
		return self._tbActData.tbDayData
	end
end

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:OnInit()
	elseif szTrigger == "Start" then
        self:InitCacheData()
		self:InitBaseData()
        --Activity:RegisterNpcDialog(self, 90, {Text = "领取迎国庆幸运奖券", Callback = self.GetChouJiang, Param = {self}})
        --Activity:RegisterPlayerEvent(self, "Act_UpdateChouJiangData", "UpdateChouJiangData")
        Activity:RegisterPlayerEvent(self, "Act_OnUseNewYearJiangQuan", "OnUseNewYearJiangQuan")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        Activity:RegisterPlayerEvent(self, "Act_BuyDaysCard", "OnBuyDaysCard")
        Activity:RegisterPlayerEvent(self, "Act_ClientCall", "OnClientCall")
        -- Test
        --Activity:RegisterGlobalEvent(self, "Act_TestLotery", "TestLotery")
        self:OnActStart()
        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        Log("[ChouJiang] Start ================", os.date("%c",nStartTime), os.date("%c", nEndTime))
    elseif szTrigger == "End" then
    	 Log("[ChouJiang] End =================")
    elseif szTrigger == "LotteryDay" then
        self:LotteryDay()
    elseif szTrigger == "LotteryBig" then
        self:LotteryBig()
    end
    Log("[ChouJiang] OnTrigger:", szTrigger)
end

function tbAct:OnClientCall(pPlayer, szFunc, ...)
    if not self[szFunc] then
        return
    end
    self[szFunc](self, pPlayer, ...)
end

function tbAct:OnInit()
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nEndTime = Activity:GetActEndTime(self.szKeyName)
    if not ChouJiang.bNotSendOpenNewInfo then
        local tbChouJiangData = {nStartTime = nStartTime, nEndTime = nEndTime}
        NewInformation:AddInfomation(ChouJiang.szOpenNewInfomationKey,nEndTime, tbChouJiangData)
    end
    
    Log("[ChouJiang] OnInit =================", os.date("%c",nStartTime), os.date("%c", nEndTime))
end

function tbAct:OnPlayerLogin()
    self:SynActData(me)
end

function tbAct:OnActStart()
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        self:SynActData(pPlayer)
    end
end

function tbAct:SynActData(pPlayer)
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nEndTime = Activity:GetActEndTime(self.szKeyName)
    pPlayer.CallClientScript("ChouJiang:OnSynActTime", nStartTime, nEndTime)
end

function tbAct:CheckData(pPlayer)
    local tbItem = Item:GetClass("JiangQuan")
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nNewYearStartTime = pPlayer.GetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_START_TIME);
    if nStartTime ~= nNewYearStartTime then
       pPlayer.SetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_USE_DAY, 0)
       pPlayer.SetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_START_TIME, nStartTime)
    end
    pPlayer.CallClientScript("ChouJiang:OnCheckData")
end

function tbAct:OnUseNewYearJiangQuan(pPlayer)
    local tbNewYearItem = Item:GetClass("NewYearJiangQuan")
    local nHave = pPlayer.GetItemCountInAllPos(tbNewYearItem.nNewYearJianQuanItemId); 
    if nHave < 1 then
        pPlayer.CenterMsg("没有奖券",true)
        return
    end
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nLastExeDay = ChouJiang:GetLastExeDay(nStartTime)
    local szLotteryDate = ChouJiang.tbDayLotteryDate[nLastExeDay]           -- nLastExeDay 有可能为0, 最后一个抽奖时间点过后的当天
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    -- 所有抽奖抽完
    if not szLotteryDate or nPassDay > nLastExeDay then
        pPlayer.CenterMsg("已经没有抽奖活动",true)
        return
    end

    local tbItem = Item:GetClass("JiangQuan")
    self:CheckData(pPlayer)
    local nNewYearUseDay = pPlayer.GetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_USE_DAY);
    -- and nLastExeDay > nNewYearUseDay 每个阶段的抽奖只能使用一张奖券
    if nNewYearUseDay ~= nLastExeDay then
        local nConsume = pPlayer.ConsumeItemInAllPos(tbNewYearItem.nNewYearJianQuanItemId,1, Env.LogWay_ChouJiangDay);
        if nConsume < 1 then
           pPlayer.CenterMsg("扣除道具失败", true)
           Log("[ChouJiang] OnUseNewYearJiangQuan fail ", pPlayer.szName,pPlayer.dwID, nNewYearUseDay, nLastExeDay, nPassDay, nStartTime)
           return
        end
        pPlayer.SetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_USE_DAY,nLastExeDay)
        self:UpdateChouJiangData(pPlayer, 1)
        local szTip = "开奖时间" .. string.format("[FFFE0D]" ..szLotteryDate .."[-]") .."，别忘记[FFFE0D]7月31日[-]还有七月大奖等着你哦！"
        pPlayer.CenterMsg(szTip)
        pPlayer.Msg(szTip)
        pPlayer.CallClientScript("ChouJiang:OnUseNewYearJiangQuan")
        Log("[ChouJiang] OnUseNewYearJiangQuan ok ", pPlayer.szName, pPlayer.dwID, nNewYearUseDay, nLastExeDay, nPassDay, nStartTime)
    else
       pPlayer.CenterMsg("已经有抽奖资格", true)
    end
end

function tbAct:GetChouJiang()

	local bRet,szMsg = Item:GetClass("JiangQuan"):CheckCanGet(me)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end

	local szTimeOut = self:CalcValidDate()	
	local pItem = me.AddItem(Item:GetClass("JiangQuan").nTemplateId, 1, szTimeOut, Env.LogWay_JiangQuan)
    if not pItem then
        Log(debug.traceback())
        return
    end

    me.SetUserValue(Item:GetClass("JiangQuan").SAVE_GROUP, Item:GetClass("JiangQuan").KEY_GET_TIME,GetTime())
    me.CenterMsg(string.format("领取%s成功",pItem.szName))
    Log("[ChouJiang] GetChouJiang ",me.szName,me.dwID,szTimeOut)
end

function tbAct:CalcValidDate()

    local nNow = GetTime()
    local tbDate = os.date("*t", nNow)
    local nYear,nMonth,nDay,nHour,nMin,nSec
    nHour = tbDate.hour
    nMin = tbDate.min
    nSec = tbDate.sec

    local nOverdueTime = Item:GetClass("JiangQuan").nOverdueTime
    local nTimeOut = os.time{year=tbDate.year, month=tbDate.month, day=tbDate.day, hour=0, sec=0} + nOverdueTime
    
    if (nHour * 60 * 60 + nMin * 60 + nSec) > nOverdueTime then
        nTimeOut = nTimeOut + 24*60*60
    end


    local tbDate = os.date("*t", nTimeOut)
    nYear = tbDate.year
    nMonth = tbDate.month
    nDay = tbDate.day
    nHour = tbDate.hour
    nMin = tbDate.min
    nSec = tbDate.sec
    
    return string.format("%d-%02d-%02d-%02d-%02d-%02d", nYear, nMonth,nDay,nHour,nMin,nSec)
end

function tbAct:GetSavaData(nVersion,nType)
    if not nVersion or nVersion <= 0 or nVersion >= self.nMaxVer then
        Log("[ChouJiang] Error GetSavaData", nVersion);
        return;
    end
    local szKey = self.tbTypeData[nType].szBaseKey ..nVersion;
    ScriptData:AddDef(szKey);
    local tbData = ScriptData:GetValue(szKey);
    if tbData.nCount then
        return tbData;
    end
    tbData.nCount = 0;
    tbData.nVer   = nVersion;
    tbData.tbPlayer = {};
    Log("[ChouJiang] GetSavaData New",nVersion,nType)
    return tbData;
end

function tbAct:GetCanUseData(nType)
	if not nType or not self.tbTypeData[nType] then	
        Log("[ChouJiang] GetCanUseData no nType",nType)
		return
	end
	local nMaxSaveCount = self.tbTypeData[nType].nMaxSaveCount
    local tbBaseData = self:GetBaseData();
    local nCurVer,szVer = self:GetTypeVer(nType)
    if not nCurVer or not szVer then
        Log("[ChouJiang] GetCanUseData no ver",nType,nCurVer,szVer)
        return
    end
    for nV = nCurVer, self.nMaxVer - 1 do
        local tbChouJiangData = self:GetSavaData(nV,nType);
        if not tbChouJiangData then
            Log("[ChouJiang] GetCanUseData GetSavaData fail ",nType,nV)
            return;
        end

        if tbChouJiangData.nCount < nMaxSaveCount then
            tbBaseData[szVer] = nV;
            return tbChouJiangData;
        end    
    end
end

function tbAct:GetBaseData()
	return ScriptData:GetValue("ChouJiangBase")
end

function tbAct:InitCacheData()
    --缓存数据结构
    tbAct._tbActData = 
    {
        tbBigData = {};
        tbDayData = {};
    }
----
end

function tbAct:InitBaseData()
	local nStartTime = Activity:GetActBeginTime(self.szKeyName)
	if nStartTime == 0 then
		Log("[ChouJiang] InitBaseData fail")
		return
	end
	local tbBaseData = self:GetBaseData()
	if not tbBaseData.nActVer or tbBaseData.nActVer ~= nStartTime then
		tbBaseData.nActVer = nStartTime 						-- 活动版本号
		tbBaseData.nBigVer = 1 									-- 大奖数据存储版本号
		tbBaseData.nDayVer = 1 									-- 每日抽奖数据存储版本号
	    tbBaseData.tbHitPlayer = {}                             -- 中过每日奖的玩家
        tbBaseData.tbHitBigPlayer = {}                          -- 中过大奖的玩家
        tbBaseData.tbNoRankPlayer = {}                          -- 不能参加每日排名抽奖的玩家
        tbBaseData.tbNoBigRankPlayer = {}                       -- 不能参加大奖排名抽奖的玩家
        ScriptData:AddModifyFlag("ChouJiangBase")
    	self:ClearData() 										-- 清空数据(存库和缓存)
		Log("[ChouJiang] InitBaseData reset ok!" , nStartTime)
	end

    -- 将存库数据整理写进缓存
	for _,nType in pairs(tbAct.TYPE) do
        if not self:IsForbid(nType) then
        	local tbCacheData = self:GetCacheData(nType)
        	if tbCacheData then
        		for nV = 1, self.nMaxVer - 1 do
        	        local tbData = self:GetSavaData(nV,nType);
        	      	if not tbData or tbData.nCount == 0 then
        	            break;
        	        end
        	        if tbData.tbPlayer then
        	        	for dwID, tbInfo in pairs(tbData.tbPlayer) do
                            local nCount = tbInfo.nCount
                            local nWeekCardEndTime = tbInfo.nWeekCardEndTime
        	        		tbCacheData.tbPlayer = tbCacheData.tbPlayer or {}
                            -- 不同的切页不可能有同一玩家的数据
        	        		tbCacheData.tbPlayer[dwID] = {}
        	        		tbCacheData.tbPlayer[dwID].nVer = nV
        	        		tbCacheData.tbPlayer[dwID].nCount = nCount
                            tbCacheData.tbPlayer[dwID].nWeekCardEndTime = nWeekCardEndTime
        	        	end
        	        	Log("[ChouJiang] InitBaseData combine data",nType,nV)
        	        end
        	    end
    	    else
    	   	   Log("[ChouJiang] InitBaseData no tbCacheData",nType)
    	    end
        end
	end
end

function tbAct:IsForbid(nType)
    local bOpen = false
    local tbTypeData = self.tbTypeData[nType]
    if tbTypeData and tbTypeData.bOpen then
        bOpen = true
    end
    return not bOpen
end

function tbAct:GetData(nType, dwID)
    local tbData
    local tbCacheData = self:GetCacheData(nType)
    tbCacheData.tbPlayer = tbCacheData.tbPlayer or {}
    if not tbCacheData.tbPlayer[dwID] then
        -- 新数据才申请ScritData
        tbData = self:GetCanUseData(nType)
    else
        -- 已存在的数据拿版本数据
        tbData = self:GetSavaData(tbCacheData.tbPlayer[dwID].nVer, nType)
    end
    return tbData
end

function tbAct:UpdateChouJiangData(pPlayer, nCount)
	-- 多个数据表不可能有同一个玩家的数据
    -- 缓存中记录玩家存库版本就是为了防止这种冗余情况
	for _,nType in pairs(tbAct.TYPE) do
        if not self:IsForbid(nType) then            -- 大奖屏蔽
    		local tbCacheData = self:GetCacheData(nType)
    		tbCacheData.tbPlayer = tbCacheData.tbPlayer or {}
    		local tbData = self:GetData(nType, pPlayer.dwID)
            if not tbData then
                Log("[ChouJiang] fnUpdateChouJiangData GetCanUseData nil", pPlayer.dwID, pPlayer.szName, nCount or -1)
                return
            end
            local tbBuyInfo = Recharge.tbSettingGroup.DaysCard[1]
            local nWeekCardEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
            local bFirst = not tbCacheData.tbPlayer[pPlayer.dwID]
    		if not tbCacheData.tbPlayer[pPlayer.dwID] then
    			tbCacheData.tbPlayer[pPlayer.dwID] = {}
        		tbCacheData.tbPlayer[pPlayer.dwID].nVer = tbData.nVer                 -- 存库的版本
        		tbCacheData.tbPlayer[pPlayer.dwID].nCount = 0                     
            end
    		if not tbData.tbPlayer[pPlayer.dwID] then
    			tbData.tbPlayer[pPlayer.dwID] = {}                         -- 玩家存库使用数量
                tbData.tbPlayer[pPlayer.dwID].nCount = 0
    			tbData.nCount = tbData.nCount + 1                         -- 当前版本已有的数据条数
    		end
            if nCount then
                tbData.tbPlayer[pPlayer.dwID].nCount = tbData.tbPlayer[pPlayer.dwID].nCount + nCount
                tbCacheData.tbPlayer[pPlayer.dwID].nCount = tbCacheData.tbPlayer[pPlayer.dwID].nCount + nCount    -- 玩家缓存使用数量
                tbCacheData.nCount = (tbCacheData.nCount or 0) + nCount                                           -- 所有玩家缓存使用数量 
            else
                -- 不传数量无论使用多少次强制数量为 1
                tbData.tbPlayer[pPlayer.dwID].nCount = 1
                tbCacheData.tbPlayer[pPlayer.dwID].nCount = 1
                if bFirst then
                    tbCacheData.nCount = (tbCacheData.nCount or 0) + 1                                           -- 所有玩家缓存使用数量 
                end
            end
            tbCacheData.tbPlayer[pPlayer.dwID].nWeekCardEndTime = nWeekCardEndTime                            -- 周卡过期时间
            tbData.tbPlayer[pPlayer.dwID].nWeekCardEndTime = nWeekCardEndTime
            ScriptData:AddModifyFlag(self.tbTypeData[nType].szBaseKey ..tbData.nVer)
            self:UpdateNoRankPlayer(nType, pPlayer)
    		Log("[ChouJiang] fnUpdateChouJiangData ", nType, pPlayer.dwID, pPlayer.szName, nCount, tbCacheData.tbPlayer[pPlayer.dwID].nVer, bRank and 1 or 0)
        end
	end
end

function tbAct:UpdateNoRankPlayer(nType, pPlayer)
    local tbBaseData = self:GetBaseData()
    local tbNoRankPlayer = nType == self.TYPE.BIG and tbBaseData.tbNoBigRankPlayer or tbBaseData.tbNoRankPlayer
    local bRank = (Forbid:IsForbidAward(pPlayer) or pPlayer.GetMoneyDebt("Gold") > 0) and true or false
    tbNoRankPlayer[pPlayer.dwID] = bRank
    ScriptData:AddModifyFlag("ChouJiangBase")
end

function tbAct:IsNoRankPlayer(nType, dwID)
    local tbBaseData = self:GetBaseData()
    local tbNoRankPlayer = nType == self.TYPE.BIG and tbBaseData.tbNoBigRankPlayer or tbBaseData.tbNoRankPlayer
    return tbNoRankPlayer[dwID]
end

function tbAct:ClearData()
	self:ClearBigData()
	self:ClearDayData()
end

function tbAct:ClearBigData()
	for nV = 1, self.nMaxVer - 1 do
        local tbData = self:GetSavaData(nV,self.TYPE.BIG);
      	if not tbData or tbData.nCount == 0 then
            break;
        end
        tbData.nCount = 0
        tbData.tbPlayer = {}
        ScriptData:AddModifyFlag(self.tbTypeData[tbAct.TYPE.BIG].szBaseKey ..nV)
        Log("[ChouJiang] ClearBigData ok",nV)
     end

     local tbDayCacheData = self:GetCacheData(tbAct.TYPE.BIG)
     tbDayCacheData.nCount = 0
     tbDayCacheData.tbPlayer = {}

     local tbBaseData = self:GetBaseData()
     tbBaseData.nBigVer = 1                 -- 重置当前使用的存库版本
end

function tbAct:ClearDayData()
	for nV = 1, self.nMaxVer - 1 do
        local tbData = self:GetSavaData(nV,self.TYPE.DAY);
      	if not tbData or tbData.nCount == 0 then
            break;
        end
        tbData.nCount = 0
        tbData.tbPlayer = {}
        ScriptData:AddModifyFlag(self.tbTypeData[tbAct.TYPE.DAY].szBaseKey ..nV)
        Log("[ChouJiang] ClearDayData ok",nV)
     end

     local tbDayCacheData = self:GetCacheData(tbAct.TYPE.DAY)
     tbDayCacheData.nCount = 0
     tbDayCacheData.tbPlayer = {}

     local tbBaseData = self:GetBaseData()
     tbBaseData.nDayVer = 1             -- 重置当前使用的存库版本
end

-- 返回当前数据类型的版本号
function tbAct:GetTypeVer(nType)
	local tbBaseData = self:GetBaseData();
	if nType == tbAct.TYPE.BIG then
		return tbBaseData.nBigVer,"nBigVer"
	elseif nType == tbAct.TYPE.DAY then
		return tbBaseData.nDayVer,"nDayVer"
	end
end
--------------------------------------------------------------------
-- 下一个抽奖天数
function tbAct:GetLastExecuteDay(nType)
    local nLastExeDay = 0
    local tbTypeData = self.tbTypeData[nType]
    if not tbTypeData then
        Log("[ChouJiang] fnGetLastExecuteDay no tbTypeData ", nType or -1)
        return nLastExeDay
    end

    local tbExecuteDay = tbTypeData.tbExecuteDay
    if not tbExecuteDay then
        Log("[ChouJiang] fnGetLastExecuteDay no tbExecuteDay ", nType or -1)
        return nLastExeDay
    end
    -- 不能用实际的开启时间来算，要用表里配的开启时间来算
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    if nPassDay < 0 then
        return nLastExeDay
    end
    for _,nExecuteDay in ipairs(tbExecuteDay) do
        nLastExeDay = nExecuteDay
        if nPassDay <= nExecuteDay then
            break
        end
    end

    return nLastExeDay
end


function tbAct:GetPassDay()
    local nPassDay = -1
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    if nStartTime == 0 then
        Log("[ChouJiang] LotteryBig nStartTime 0 !", nType)
        return nPassDay
    end
    local nNowDay = Lib:GetLocalDay()
    local nStartDay = Lib:GetLocalDay(nStartTime)
    local nPassDay = nNowDay - nStartDay + 1                        -- 活动第几天
    return nPassDay
end

-- 是否抽奖（不是大奖）
function tbAct:CheckLotteryDay()
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    local nLastExeDay = self:GetLastExecuteDay(tbAct.TYPE.DAY)
    Log(string.format("[ChouJiang] fnCheckLotteryDay ExeDay %s, PassDay %s ", nLastExeDay or "nil", nPassDay or "nil"))
    return nPassDay == nLastExeDay
end
--------------------------------------------------------------------

function tbAct:LotteryDay()
    Log("[ChouJiang] LotteryDay execute start!")
    if self:CheckLotteryDay() then
        self:Lottery(tbAct.TYPE.DAY)
    else
        Log("[ChouJiang] LotteryDay not exe day!")
    end
    
    Log("[ChouJiang] LotteryDay execute end!")
end

function tbAct:LotteryBig()
    Log("[ChouJiang] LotteryBig execute start!")
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    if nStartTime == 0 then
        Log("[ChouJiang] LotteryBig nStartTime 0 !")
        return
    end
    local tbTypeData = self.tbTypeData[tbAct.TYPE.BIG]
    if not tbTypeData or not tbTypeData.nLotteryDay then
        Log("[ChouJiang] LotteryBig no tbTypeData or nLotteryDay",tbTypeData and tbTypeData.nLotteryDay or -1)
        return
    end
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    if nPassDay == tbTypeData.nLotteryDay then
       self:Lottery(tbAct.TYPE.BIG)
       Log("[ChouJiang] LotteryBig hit", nPassDay, nStartTime, tbTypeData.nLotteryDay)
    else
        Log("[ChouJiang] LotteryBig hit no", nPassDay, nStartTime, tbTypeData.nLotteryDay)
    end
   Log("[ChouJiang] LotteryBig execute end!", nPassDay, nStartTime, tbTypeData.nLotteryDay)
end

function tbAct:CheckIsGet(dwID, nRank, nType)
    local tbBaseData = self:GetBaseData();
    local tbPlayer = nType == tbAct.TYPE.BIG and tbBaseData.tbHitBigPlayer or tbBaseData.tbHitPlayer
    return tbPlayer[dwID] and tbPlayer[dwID][nRank]
end

function tbAct:SendWorldTip(dwID, nRank, nType)
    if not dwID or not nRank or not nType then
        return 
    end
    local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
    local szName = pPlayerInfo and pPlayerInfo.szName
    if szName then
        local szType = (nType and nType == tbAct.TYPE.DAY) and "七月抽奖" or "七月大抽奖"
        local szRank = ChouJiang:GetRankDes(nRank)
        local szMsg = string.format("恭喜玩家%s在%s活动中获得了%s", szName, szType, szRank)
        KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
    end
end

function tbAct:SendKinTip(dwID, nRank, nType)
    if not dwID or not nRank or not nType then
        return 
    end
    local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
    local szName = pPlayerInfo and pPlayerInfo.szName
    local nKinId = pPlayerInfo and pPlayerInfo.dwKinId
    if szName and nKinId and nKinId ~= 0 then
        local szType = (nType and nType == tbAct.TYPE.DAY) and "七月抽奖" or "七月大抽奖"
        local szRank = ChouJiang:GetRankDes(nRank)
        local szMsg = string.format("恭喜帮派成员%s在%s活动中获得了%s", szName, szType, szRank)
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
    end
end

function tbAct:RecordWedCardState(pPlayer, nEndTime)
    for _,nType in pairs(self.TYPE) do
        if not self:IsForbid(nType) then            -- 大奖屏蔽
            local tbCacheData = self:GetCacheData(nType)
            tbCacheData.tbPlayer = tbCacheData.tbPlayer or {}
            if tbCacheData.tbPlayer[pPlayer.dwID] then
                local tbBuyInfo = Recharge.tbSettingGroup.DaysCard[1]
                local nOverdueTime = nEndTime or pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
                tbCacheData.tbPlayer[pPlayer.dwID].nWeekCardEndTime = nEndTime
                local tbData = self:GetData(nType, pPlayer.dwID)
                if tbData then 
                   tbData.tbPlayer[pPlayer.dwID].nWeekCardEndTime = nEndTime
                   ScriptData:AddModifyFlag(self.tbTypeData[nType].szBaseKey ..tbData.nVer)
                   Log("[ChouJiang] fnRecordWedCardState ", nType, pPlayer.dwID, pPlayer.szName, Lib:TimeDesc9(nEndTime))
                else
                    Log("[ChouJiang] fnRecordWedCardState no data", pPlayer.dwID, pPlayer.szName, nEndTime)
                end
            end
        end
    end
end

function tbAct:OnBuyDaysCard(pPlayer, nGroupIndex, nEndTime)
    if nGroupIndex == 1 then
        self:RecordWedCardState(pPlayer, nEndTime)
    end
end

-- 记录玩家获奖信息(活动期间得到第n名奖励的玩家不再获得同等名次的奖励)
function tbAct:RecordLotteryBaseData(nType, nRank, nHitID)
    local tbBaseData = self:GetBaseData();
    if nType == tbAct.TYPE.BIG then
        tbBaseData.tbHitBigPlayer[nHitID] = tbBaseData.tbHitBigPlayer[nHitID] or {}
        tbBaseData.tbHitBigPlayer[nHitID][nRank] = true
    else
        tbBaseData.tbHitPlayer[nHitID] = tbBaseData.tbHitPlayer[nHitID] or {}
        tbBaseData.tbHitPlayer[nHitID][nRank] = true
        -- 统计互斥排名奖励
        if ChouJiang.tbDayRejectRank[nRank] then
            for _,nRejectRank in ipairs(ChouJiang.tbDayRejectRank[nRank]) do
                 tbBaseData.tbHitPlayer[nHitID][nRejectRank] = true
            end
        end
    end
end

function tbAct:SelectRankPlayer(nType, tbHouXuan, nRank, tbAwardInfo, nNum)
    local nNowTime = GetTime()
    local tbHouXuanPlayer = tbHouXuan.tbPlayer or {}
    local tbHitPlayer = {}
    local bLimitSmall = tbAwardInfo[3]
    local bWeekState = tbAwardInfo[6]
    local tbVipLimit = tbAwardInfo[7] or {}
    local nMinVip = tbVipLimit[1]
    local nMaxVip = tbVipLimit[2]
    local tbQualifier = {tbPlayer = {}, nAllTicket = 0}
    for dwID, v in pairs(tbHouXuanPlayer) do
        local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID);
        if pPlayerInfo then
            local nVipLevel = pPlayerInfo.nVipLevel or 0
            local bSmall = MarketStall:CheckIsLimitPlayer( {nLevel = pPlayerInfo.nLevel or 0, GetVipLevel = function() return nVipLevel end} )
            local bWeekCardState = nNowTime < (v.nWeekCardEndTime or 0)
            --[[
                (not (bLimitSmall and bSmall)) 没有小号限制或者不是小号
                (not self:CheckIsGet(dwID, nRank, nType)) 活动期间没有得过排名奖励（每日抽奖潜规则只要有一天得过排名奖励后面就不能再得）
                (not self:IsNoRankPlayer(nType, dwID)) 不是现在被限制（禁止奖励或欠款）的玩家
                ((not bWeekState) or bWeekCardState)  没有周卡限制或者处于周卡状态
                ((not nMinVip or nVipLevel > nMinVip)) 没有最小vip限制或者大于最小vip
                ((not nMaxVip or nVipLevel < nMaxVip)) 没有最大vip限制或者小于最大vip
            ]]
            local bQualifier = (not (bLimitSmall and bSmall)) and (not self:CheckIsGet(dwID, nRank, nType))
            and (not self:IsNoRankPlayer(nType, dwID)) and ((not bWeekState) or bWeekCardState)
            and ((not nMinVip or nVipLevel > nMinVip)) and ((not nMaxVip or nVipLevel < nMaxVip))
            if bQualifier then
                table.insert(tbQualifier.tbPlayer, {nCount = v.nCount, dwID = dwID})
                tbQualifier.nAllTicket = tbQualifier.nAllTicket + v.nCount
            end
        end
    end
    for i = 1, nNum do
        if next(tbQualifier.tbPlayer) then
            local nHitID = nil;
            local nHitCount = 0
            local nRemoveIdx = nil
            local nRandom = MathRandom(tbQualifier.nAllTicket);
            for nHitIdx, v in ipairs(tbQualifier.tbPlayer) do
                nHitID = v.dwID
                nHitCount = v.nCount
                nRemoveIdx = nHitIdx
                if nRandom <= 0 then
                    break;
                end
                nRandom = nRandom - v.nCount;
            end
            if nHitID then
                table.insert(tbHitPlayer, nHitID)
                table.remove(tbQualifier.tbPlayer, nRemoveIdx)
                tbQualifier.nAllTicket = tbQualifier.nAllTicket - nHitCount
                -- 删除所有玩家名额
                if tbHouXuan.tbPlayer[nHitID] then
                    tbHouXuan.nCount = tbHouXuan.nCount - 1
                    tbHouXuan.nAllCount = tbHouXuan.nAllCount - nHitCount
                    tbHouXuan.tbPlayer[nHitID] = nil
                else
                    Log("[ChouJiang] Lottery del tbHouXuan err", nRank, nType, nHitID, nHitCount, nType)
                end
            end
        end
    end
    return tbHitPlayer
end

function tbAct:GetBigHouXuan(tbHouXuan)
    local tbBigHouXuan = 
    {
        nAllCount = 0;
        nCount = 0;
        tbPlayer = {};
    }
    for dwID, v in pairs(tbHouXuan.tbPlayer or {}) do
        local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID);
        if pPlayerInfo then
            local nCount = v.nCount
            local bSmall = MarketStall:CheckIsLimitPlayer({nLevel = pPlayerInfo.nLevel or 0,GetVipLevel = function() return pPlayerInfo.nVipLevel or 0 end})
            if not bSmall then
                tbBigHouXuan.tbPlayer = tbBigHouXuan.tbPlayer or {}
                tbBigHouXuan.tbPlayer[dwID] = (tbBigHouXuan.tbPlayer[dwID] or 0) + nCount
                tbBigHouXuan.nAllCount = (tbBigHouXuan.nAllCount or 0) + nCount
                tbBigHouXuan.nCount = (tbBigHouXuan.nCount or 0) + 1
            end
        end
    end
    return tbBigHouXuan
end

-- 》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》
-- 新版抽奖
function tbAct:Lottery(nType)
    if not ChouJiang.bOpen then
        return
    end
    if self:IsForbid(nType) then
        Log("[ChouJiang] try lottery forbid type ", nType)
        return
    end
    local tbTypeData = self.tbTypeData[nType]
    if not tbTypeData then
        Log("[ChouJiang] Lottery no tbTypeData ",nType)
        return
    end
     local tbAwardData = ChouJiang:GetAwardSetting(tbTypeData.tbAward)
     if not tbAwardData then
        Log("[ChouJiang] Lottery no tbAward",nType)
        return
    end
    local tbShowRank = tbTypeData.tbShowRank
    -- 所有玩家
    local tbHouXuan = {}
    tbHouXuan.tbPlayer = {}                     -- 所有玩家对应票数和月卡过期时间
    tbHouXuan.nAllCount = 0                     -- 一共多少票
    tbHouXuan.nCount = 0                        -- 一共多少人
    local tbHit = {}                             -- 所有中排名奖玩家，最新消息中使用
    -- 整合所有切表的数据,以及将玩家分类管理
    local tbCacheData = self:GetCacheData(nType)
    local tbAllPlayer = tbCacheData.tbPlayer or {}
    for dwID, tbInfo in pairs(tbAllPlayer) do
        local nCount = tbInfo.nCount or 0
        local bLimitCount = (tbTypeData.nLimitCount and nCount < tbTypeData.nLimitCount) and true or false
        local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID);
        if pPlayerInfo and not bLimitCount then
            local nWeekCardEndTime = tbInfo.nWeekCardEndTime or 0
            if nCount > 0 then
                tbHouXuan.tbPlayer[dwID] = tbHouXuan.tbPlayer[dwID] or {}
                tbHouXuan.tbPlayer[dwID].nCount = (tbHouXuan.tbPlayer[dwID].nCount or 0) + nCount
                tbHouXuan.tbPlayer[dwID].nWeekCardEndTime = nWeekCardEndTime
                tbHouXuan.nAllCount = (tbHouXuan.nAllCount or 0) + nCount
                tbHouXuan.nCount = (tbHouXuan.nCount or 0) + 1
            end
        else
            Log("[ChouJiang] Lottery Limit", dwID, nCount)
        end
    end
    if not next(tbHouXuan.tbPlayer) then    
        Log("[ChouJiang] Lottery no player join", nType)
    end
    local szTitle = tbTypeData.szMailTitle or "抽奖"
    local nLogWay = nType == tbAct.TYPE.BIG and Env.LogWay_ChouJiangBig or Env.LogWay_ChouJiangDay
-- 》》   开始抽排名奖励
    for nRank, tbInfo in ipairs(tbAwardData) do
        if not next(tbHouXuan.tbPlayer) then
            Log("[ChouJiang] rank no player", nType, nRank)
            break
        end
        local szRank = ChouJiang:GetRankDes(nRank)
        local szRankText = string.format(tbTypeData.szRankMailText or "恭喜你参加抽奖活动，获得[FFFE0D]%s[-]，附件为奖励请查收！", szRank)
        -- 该排名已经抽中了几个玩家(筛选条件逐步放宽抽奖，直到数量达标)
        local nHitNum = 0
        for _, tbAwardInfo in ipairs(tbInfo) do
            -- 想要抽几个玩家
            local nTargetNum = tbAwardInfo[1]
            local tbAward = tbAwardInfo[2]
            local bWorldTip = tbAwardInfo[4]
            local bKinTip = tbAwardInfo[5]
            -- 已经抽到想要的数量
            if nHitNum >= nTargetNum then
                break
            else
                -- 继续抽排名奖
                local nLotteryNum = nTargetNum - nHitNum
                Log("[ChouJiang] start rank Lottery ", nType, nRank, nLotteryNum)
                local tbHitPlayer = self:SelectRankPlayer(nType, tbHouXuan, nRank, tbAwardInfo, nLotteryNum)
                nHitNum = nHitNum + #tbHitPlayer
                Log("[ChouJiang] end rank Lottery ", nType, nRank, nHitNum)
                -- 抽到符合条件的玩家
                if next(tbHitPlayer) then
                    for _, nHitID in ipairs(tbHitPlayer) do
                        self:RecordLotteryBaseData(nType, nRank, nHitID)
                        local tbMail = {
                            To = nHitID;
                            Title = szTitle;
                            From = "系统";
                            Text = szRankText;
                            tbAttach = tbAward;
                            nLogReazon = nLogWay;
                        }; 
                        Mail:SendSystemMail(tbMail);
                        if tbShowRank[nRank] then
                           tbHit[nRank] = tbHit[nRank] or {}
                           tbHit[nRank][nHitID] = tbAward
                        end
                        if bWorldTip then
                            Lib:CallBack({self.SendWorldTip, self, nHitID, nRank, nType});
                        end
                        if bKinTip then
                            Lib:CallBack({self.SendKinTip, self, nHitID, nRank, nType});
                        end
                        Log("[ChouJiang] Lottery rank hit ok", nType, nRank, nHitID, tbHouXuan.nAllCount, tbHouXuan.nCount)
                    end
                end
            end        
        end
    end
    self:SendAVAward(tbHouXuan, tbTypeData, nLogWay, szTitle)
    if nType == tbAct.TYPE.DAY then
        self:ClearDayData()
    elseif nType == tbAct.TYPE.BIG then
        self:ClearBigData()
    end
    local tbNewInfoData = {}
    tbNewInfoData.nType = nType
    tbNewInfoData.tbRankData = {}
    for nRank,tbInfo in pairs(tbHit) do
        tbNewInfoData.tbRankData[nRank] = tbNewInfoData.tbRankData[nRank] or {}
        for dwID,tbAward in pairs(tbInfo) do
            local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
            if pPlayerInfo then
                local tbInfo = {}
                local tbPlayerInfo = {}
                local pKinData = Kin:GetKinById(pPlayerInfo.dwKinId or 0) or {};
                tbPlayerInfo.szKinName = pKinData.szName or ""
                tbPlayerInfo.szName = pPlayerInfo.szName or XT("无")
                tbInfo.tbPlayerInfo = tbPlayerInfo
                tbInfo.tbAward = tbAward
                table.insert(tbNewInfoData.tbRankData[nRank],tbInfo)
            end
        end
    end
    if tbTypeData.nNewInfomationValidTime then
       NewInformation:AddInfomation(ChouJiang.szHitNewInfomationKey,GetTime() + tbTypeData.nNewInfomationValidTime, tbNewInfoData)
    end
    local szContent = tbTypeData.szWorldNotifyHit
    if szContent then
       KPlayer.SendWorldNotify(1, 999, szContent, ChatMgr.ChannelType.Public, 1);
    end
    ScriptData:AddModifyFlag("ChouJiangBase")
end

-- 参与奖
function tbAct:SendAVAward(tbHouXuan, tbTypeData, nLogWay, szTitle)
    local tbBigHouXuan = self:GetBigHouXuan(tbHouXuan)
    local tbAVAward = ChouJiang:GetAwardSetting(tbTypeData.tbAVAward) or {}
    if next(tbHouXuan.tbPlayer) and next(tbAVAward) then
        --开始发纪念奖
        local tbBigAward = {}
        local tbNormalAward = {}
        for i,tbInfo in ipairs(tbAVAward) do
           if tbInfo[3] then
                table.insert(tbBigAward,tbInfo)
            else
                table.insert(tbNormalAward,tbInfo)
            end
        end
        local tbBigPlayer = {}
        if next(tbBigHouXuan.tbPlayer) then
            for dwID,nCount in pairs(tbBigHouXuan.tbPlayer) do
                table.insert(tbBigPlayer, dwID)
            end
            Lib:SmashTable(tbBigPlayer)
        end
        local szAVText = tbTypeData.szAvMailText or "抽奖活动幸运奖"
        -- 先随大号
        local nSendBig = 0              -- 实际发了几个大号
        if next(tbBigPlayer) and next(tbBigAward) then
            for _,tbInfo in ipairs(tbBigAward) do
                local nRate = tbInfo[1]                                 -- 百分比
                local tbAward = tbInfo[2]
                local nSend = math.floor(tbHouXuan.nCount*nRate)        -- 想要发几个大号
                for i = #tbBigPlayer, 1, -1 do
                    local dwID = tbBigPlayer[i]
                    if nSend > 0 then
                        local tbMail = {
                            To = dwID;
                            Title = szTitle;
                            From = "系统";
                            Text = szAVText;
                            tbAttach = tbAward;
                            nLogReazon = nLogWay;
                        }; 
                        Mail:SendSystemMail(tbMail);
                        nSend = nSend - 1
                        nSendBig = nSendBig + 1
                        tbHouXuan.tbPlayer[dwID] = nil
                        tbBigPlayer[i] = nil
                        Log("[ChouJiang] Lottery Send Big", dwID, nSend, nRate)
                    else
                        break;
                    end
                end
            end
        end
        local tbNormalPlayer = {}
        if next(tbHouXuan.tbPlayer) then
            for dwID,nCount in pairs(tbHouXuan.tbPlayer) do
                table.insert(tbNormalPlayer,dwID)
            end
            Lib:SmashTable(tbNormalPlayer)
        end
        if next(tbNormalPlayer) and next(tbNormalAward) then
            -- 再发剩下的奖励
            local nSendNormal = tbHouXuan.nCount - nSendBig > 0 and tbHouXuan.nCount - nSendBig or 0
            for _,tbInfo in ipairs(tbNormalAward) do
                local nRate = tbInfo[1]
                local tbAward = tbInfo[2]
                local nSend = math.floor(tbHouXuan.nCount*nRate)        -- 想要发几个
                for i=#tbNormalPlayer,1,-1 do
                    local dwID = tbNormalPlayer[i]
                    if nSend > 0 then
                        local tbMail = {
                            To = dwID;
                            Title = szTitle;
                            From = "系统";
                            Text = szAVText;
                            tbAttach = tbAward;
                            nLogReazon = nLogWay;
                        }; 
                        Mail:SendSystemMail(tbMail);
                        nSendNormal = nSendNormal - 1
                        tbHouXuan.tbPlayer[dwID] = nil
                        tbNormalPlayer[i] = nil
                        nSend = nSend - 1
                        Log("[ChouJiang] Lottery Send normal", dwID, nSend, nRate)
                    else
                        break
                    end
                end
            end
        end
        -- 把剩下的人发了
        local tbDefaultAward = next(tbNormalAward) and tbNormalAward[1][2]
        if tbDefaultAward then
            for dwID,_ in pairs(tbHouXuan.tbPlayer) do
                local tbMail = {
                    To = dwID;
                    Title = szTitle;
                    From = "系统";
                    Text = szAVText;
                    tbAttach = tbDefaultAward;
                    nLogReazon = nLogWay;
                }; 
                Mail:SendSystemMail(tbMail);
                Log("[ChouJiang] Lottery Send default", dwID)
            end
        end
    end
end

function tbAct:TestLotery(nType)
    self:Lottery(nType)
end