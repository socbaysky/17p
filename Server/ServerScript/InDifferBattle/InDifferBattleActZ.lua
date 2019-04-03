if not MODULE_ZONESERVER then
	return
end

InDifferBattle.tbAct = InDifferBattle.tbAct or {}
local tbAct = InDifferBattle.tbAct;
local tbSetting = InDifferBattle.tbBattleTypeSetting.ActJueDi
 

function tbAct:ClearMathInfo()
    self.nLastRequestTime = nil
end

function tbAct:StartMatchSignUp()
    local nNow = GetTime()
    if self.nLastRequestTime and math.abs(self.nLastRequestTime - nNow) < 60*20 then --内跨服上应该不会又开一场
        Log("InDifferBattle:StartMatchSignUp SameRequest", self.nLastRequestTime, nNow)
        return
    end

    if InDifferBattle:IsSignupIng() then
        Log("Error InDifferBattle:IsSignupIng can't openAct")
        return
    end

    self:ClearMathInfo()
    self.nLastRequestTime = nNow

    --开始创建对应的准备场
    InDifferBattle:OpenSignUp("ActJueDi")  --复用吧，主要是准备场回传 看下是重新写还是复用
end

function tbAct:CloseMatchSignUp(  )
    InDifferBattle:StopSignUp()
end