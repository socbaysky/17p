local tbNpc = Npc:GetClass("ActivityNpc");

function tbNpc:OnDialog()
    local   OptList = {
        { Text = "与情缘书", Callback = self.PlaySound, Param = {self, 17} },
        { Text = "剑侠情", Callback = self.PlaySound, Param = {self, 10} },
        { Text = "大英雄", Callback = self.PlaySound, Param = {self, 21} },
        { Text = "爱的废墟", Callback = self.PlaySound, Param = {self, 10020} },
        { Text = "画地为牢", Callback = self.PlaySound, Param = {self, 11} },
        { Text = "三生三世", Callback = self.PlaySound, Param = {self, 12} },
        { Text = "停止播放", Callback = self.RestartPlayMapSound, Param = {self} },
        { Text = "你先忙！", Callback = function () end},
    };
    if version_vn then
            OptList = {
                { Text = "剑侠情缘", Callback = self.PlaySound, Param = {self, 10} },
                { Text = "大英雄", Callback = self.PlaySound, Param = {self, 21} },
                { Text = "剑侠情", Callback = self.PlaySound, Param = {self, 16} },
                { Text = "画地为牢", Callback = self.PlaySound, Param = {self, 11} },
                { Text = "三生缘", Callback = self.PlaySound, Param = {self, 12} },
                { Text = "我们去找到你", Callback = self.PlaySound, Param = {self, 14} },
                { Text = "停止播放", Callback = self.RestartPlayMapSound, Param = {self} },
                { Text = "你先忙！", Callback = function () end},
            };

    elseif version_kor then
        OptList =  {
                { Text = "与情缘书", Callback = self.PlaySound, Param = {self, 17} },
                { Text = "爱的废墟", Callback = self.PlaySound, Param = {self, 10020} },
                { Text = "大英雄", Callback = self.PlaySound, Param = {self, 21} },
                { Text = "停止播放", Callback = self.RestartPlayMapSound, Param = {self} },
                { Text = "你先忙！", Callback = function () end},
            };
    end
    Dialog:Show(
    {
        Text    = "你找我什麽事？",
        OptList = OptList,
    }, me, him);
end

function tbNpc:PlaySound(nSoundID)
    me.CallClientScript("Map:PlaySceneOneSound", nSoundID);
end

function tbNpc:RestartPlayMapSound()
    me.CallClientScript("Map:RestartPlayMapSound");
end