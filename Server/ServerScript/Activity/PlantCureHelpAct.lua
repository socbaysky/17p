local tbAct = Activity:GetClass("PlantCureHelpAct")
tbAct.tbTrigger = { 
    Init    = {}, 
    Start   = {}, 
    End     = {}, 
}

tbAct.nJoinLevel = 20

tbAct.tbCureAward =
{
    { tbAward = {{ "Contrib", 250 }} },
    { tbAward = {{ "Contrib", 400 }} },
    { tbAward = {{ "Contrib", 500 }} },
    { tbAward = {{ "Energy", 250 }} },
    { tbAward = {{ "Energy", 400 }} },
    { tbAward = {{ "Energy", 500 }} },
};

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_House_PlantHelpCure_Award", "OnCureAward")
    end
end

function tbAct:OnCureAward(pPlayer, nOwnerId, nRewardIdx)
    if pPlayer.nLevel<self.nJoinLevel then
        return
    end
    local tbAward = self.tbCureAward[nRewardIdx]
    if not tbAward then
        return
    end
    pPlayer.SendAward(tbAward.tbAward, nil, nil, Env.LogWay_PlantCureHelpAct);
end
