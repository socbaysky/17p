local tbAct = Activity:GetClass("ShengDianLoginAct")
tbAct.tbTrigger  =
{
    Init  = {},
    Start = {},
    End   = {},
}
tbAct.TIME = 4*3600
tbAct.tbAttach = {
    [7] = {{"Item", 1927, 100}},
    [6] = {{"Item", 224, 1}},
    [5] = {{"Item", 2569, 1}},
    [4] = {{"Coin", 3000}},
    [3] = {{"Contrib", 3000}},
    [2] = {{"Item", 1930, 2}},
    [1] = {{"Coin", 5000}},
}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        local _, nEndTime = self:GetOpenTimeInfo()
        self:RegisterDataInPlayer(nEndTime)
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin")
    end
end

function tbAct:OnLogin(pPlayer)
    local nDay = Lib:GetLocalDay(GetTime() - self.TIME)
    local tbData = self:GetDataFromPlayer(pPlayer.dwID) or {}
    if not tbData[nDay] then
        tbData[nDay] = true
        self:SaveDataToPlayer(pPlayer, tbData)
        self:SendEmail(pPlayer.dwID)
    end
end

function tbAct:SendEmail(nId)
    local _, nEndTime = self:GetOpenTimeInfo()
    local nLastDay = Lib:GetLocalDay(nEndTime - self.TIME) - Lib:GetLocalDay(GetTime() - self.TIME) + 1
    local tbAward = self.tbAttach[nLastDay]
    if not tbAward then
        return
    end
    local szTxt = [[距【江湖盛典·缘聚江湖】发布会盛大开幕还有[FFFE0D]%s[-]天！\n江湖盛典倒计时现已开启，倒计时期间内诸位少侠可通过信件领取每日倒计时登入奖励。\n盛典发布会将於[FFFE0D]2017.10.29日18:30-20:30[-]进行直播，过程中将会有更多惊喜大礼恭候诸位少侠，敬请关注！]]
    szTxt = string.format(szTxt, nLastDay)
    Mail:SendSystemMail({
        To = nId,
        Title = "江湖盛典倒计时",
        Text = szTxt,
        tbAttach = tbAward,
    })
end