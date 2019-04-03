--武林大事副本
local tbBase = Fuben:CreateFubenClass("WldsFubenBase")
tbBase.REVIVE_TIME = 5
function tbBase:OnPreCreate()
    self.tbReviveTimer = {}
end

function tbBase:OnJoin(pPlayer)
    pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "RandomFuben")
end

function tbBase:OnLeaveMap(pPlayer)
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
    self:DoRevive(pPlayer.dwID, true)
end

function tbBase:OnPlayerDeath()
    me.CallClientScript("Ui:OpenWindow", "CommonDeathPopup", "AutoRevive", "您将在 %d 秒後复活", self.REVIVE_TIME)
    self.tbReviveTimer[me.dwID] = Timer:Register(self.REVIVE_TIME * Env.GAME_FPS, self.DoRevive, self, me.dwID)
end

function tbBase:DoRevive(nPlayerId, bIsOut)
    if bIsOut and self.tbReviveTimer[nPlayerId] then
        Timer:Close(self.tbReviveTimer[nPlayerId])
    end
    self.tbReviveTimer[nPlayerId] = nil

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return
    end

    pPlayer.Revive(bIsOut and 1 or 0)
end