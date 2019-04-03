local tbAct = Activity:GetClass("CrossEachServerAct")
tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }
tbAct.nNewInfomationValidTime = 7*24*60*60
function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		local szContent = [[
            互通服详细规则（Q&A）：
        \nQ：互通服的游戏内容与非互通服有什麽区别？
        \nA：游戏玩法完全一致。
        \n\nQ：互通服的储值管道会变更吗？
        \nA：资料互通後，储值的方式将按照原来的方式，自行选择需要储值的区服进行储值。
        \n\nQ：互通服中iOS储值和安卓储值折扣一致吗？
        \nA：为了保证游戏的公平性，确保互通服中iOS平台储值与安卓平台储值折扣一致，当iOS用户进行储值消费後，我们将会以安卓的折扣标准对该笔储值差值进行额外元宝赠送，请玩家通过游戏内信件附件查收。
        \n\nQ：互通服资料互通的功能实现後，当前已经开服的伺服器也会使用资料互通功能进行合并吗？
        \nA：不会。
        \n\nQ：我使用同一个帐号可以同时使用iOS和安卓的手机登录同一组互通服吗？
        \nA：不能。
        \n\nQ：我使用的系统是iOS，再使用安卓手机登录为什麽没有角色？
        \nA：登录帐号在iOS和安卓设备之间相互独立，帐号内的角色无法在各平台自由切换，使用不同的系统设备登录游戏时，即使是同一个帐号，也是不同的角色，即iOS和安卓资料互通後，如果互通的服都有角色，是不影响各自的角色资料的。
        \n\nQ：我之前一直使用安卓手机在互通服体验游戏，後来更换了苹果手机体验，登录後还能继续玩以前的角色吗？
        \nA：不可以。互通服内，同样的登录帐号，iOS和安卓平台下的帐号资讯是完全独立的。即：更换为iOS设备登录後，即使是相同伺服器相同帐号，也看不到该帐号在安卓上创建的角色，反之亦然。
        \n\nQ：互通服中，会不会存在和我一模一样的角色名存在？
        \nA：角色名均是全服唯一。
        \n\nQ：请问互通服中我能领取到对应平台的礼包吗？
        \nA：可以。
        \n\nQ：请问互通服中的各种排行榜是分别区分不同平台的吗？
        \nA：互通服中，排行榜的资料将是该服的全体玩家资料根据各类排行榜规则进行排序。
        \n\nQ：怎麽区分我进入的伺服器是否互通伺服器？
        \nA：互通伺服器的名字以互通服命名。
		]]
		local tbActData = {string.format(szContent)}
		local bRet = NewInformation:AddInfomation("CrossEachServerAct", GetTime() + self.nNewInfomationValidTime, tbActData, {szTitle = "互通服详细规则"});
		if not bRet then
			Log("[CrossEachServerAct] send new msg fail")
		end
	end
end