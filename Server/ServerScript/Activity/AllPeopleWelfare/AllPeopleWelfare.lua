
local tbAct = Activity:GetClass("AllPeopleWelfare");

tbAct.tbTimerTrigger = 
{
};

tbAct.tbTrigger = 
{
    Init = {},
    Start = {},
    End = {},
};

tbAct.tbNewInfo_Old = 
{
    szTitle = "迎战新服全民福利";
    szContent =
[[
      武林盟主特令，侠士进驻4月12日0点至5月1日0点之间开放的伺服器，可获得“闲庭雅居”资料片独享增益福利。助力众侠士早日独步武林！（增益福利将持续到开启59级等级上限）
      福利一：[ffcc00]共战[-]。野外修炼打怪获得的经验增加10%。
      福利二：[ffcc00]财运[-]。通过摇钱树、每日目标、随机地宫、野外修炼、商会任务获得的银两增加10%。
      福利三：[ffcc00]天工[-]。通过帮派捐献、武神殿、惩恶任务、帮派烤火答题、武林盟主获得的贡献增加10%。
]]
}

tbAct.tbNewInfo = 
{
    szTitle = "迎战新服全民福利";
    szContent =
[[
      武林盟主特令，侠士进驻5月1日4点至5月16日0点之间开放的伺服器，可获得5月劳动节独享增益福利。助力众侠士早日独步武林！（增益福利将持续到开启59级等级上限）
      福利一：[ffcc00]称号[-]。新进玩家可获得新服专属限定称号。
      福利二：[ffcc00]共战[-]。野外修炼打怪获得的经验增加10%。
      福利三：[ffcc00]财运[-]。通过摇钱树、每日目标、随机地宫、野外修炼、商会任务获得的银两增加10%。
      福利四：[ffcc00]天工[-]。通过帮派捐献、武神殿、惩恶任务、帮派烤火答题、武林盟主获得的贡献增加10%。
]]
}

tbAct.tbAddBuff = 
{
    {nBuffID = 2301, nLevel = 1 },
    {nBuffID = 2302, nLevel = 1 },
    {nBuffID = 2303, nLevel = 1 },
};

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:SendNew();
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin");
    end

    Log("AllPeopleWelfare OnTrigger:", szTrigger)
end

function tbAct:OnPlayerLogin()
    local pPlayerNpc = me.GetNpc();
    if not pPlayerNpc then
        return;
    end

    local _, nEndTime = self:GetOpenTimeInfo();
    local nCurTime = GetTime();
    if nCurTime >= (nEndTime - 10) then
        return;
    end

    for _, tbBuffInfo in pairs(self.tbAddBuff) do
        local tbState  = pPlayerNpc.GetSkillState(tbBuffInfo.nBuffID);
        if not tbState then
            pPlayerNpc.AddSkillState(tbBuffInfo.nBuffID, tbBuffInfo.nLevel, FightSkill.STATE_TIME_TYPE.state_time_truetime, nEndTime, 1, 1);
        end    
    end   
end

function tbAct:SendNew()
    local tbNewInfo = self.tbNewInfo;
    if not tbNewInfo then
        return;
    end
    
    if tonumber(os.date("%Y%m%d", GetTime())) < 20170501 then	-- 这个时间之前用老的最新消息
    	tbNewInfo = self.tbNewInfo_Old or tbNewInfo;
    end

    local _, nEndTime = self:GetOpenTimeInfo();
    NewInformation:AddInfomation("AllPeopleWelfare_NewInfo", nEndTime, {tbNewInfo.szContent}, {szTitle = tbNewInfo.szTitle, nReqLevel = 1})
end