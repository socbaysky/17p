 
Require("CommonScript/Player�  EventRegister.lua");
local SdkMgr = Xnet.import_typH
RInLface�
function �� :OnLogin(nIsReconnect)
 @ self.b�PtrueH\ if �tbMapOnE|Param then�|Lib:CallBack({M.�, P, unpd4.)}dxl 4� [nil�end� -- 玩家在野外时登陆改变战斗状态的T候会\ :uservalue同步之前调GetVipLevel()导致vip等级不对，所以必须放X	P	面保证下L\函数S
用X�'4正确�, \3hargeT(�2, �}�%D3*  == 0;PGuid)@�'4'D,�Awards(()P '� ,� �	.CheckCanBuyL*�	*( 	 --特权礼包红点检查2T@O tner.UpdateRedPoint, �50StrengxU((L , me}�`,Item.GoldEquip(� ,\ �2�XnrydayTi9t(,\ 4�WDrareActivity(� -b , .14@MarketStPt(0)P   ���_SafedX0��,5LT�pose.V|o��EShow(d�*� H
x�L --任务>�AchiXyment�R(�)h \
2Kin.U&rH��MTimer, \4�OnHook�#, �,Xtu\4ؙ,�	ChuangGong((L 32�T�(� P � A.C$Bag��9�NewInformat�(�,\ 4�SeriesFuben(� )P 4� t \\.GsdkIni\�T41AD�aBattle()P 4� �`Cl�
MoneyDebtBuff�`4� HuaShanLunJianH,questHSLJZKte~(, ,� , tH�'`
 SendBless.dwSynRoleId+`.$	atMgrO^atDG�rat)�Cha/t  ��'(� Ho\�(��3� 3�Weddi*�� 	A@O�onT��Client��, *l '�,hZhenFa(��5� 'LabaP(� P���5To) P3�
��if Ui.nLockScreen�K-h Ui:OpenWindow("(� Panel"��e"�%�
$*nDay@Ntonumber(oHQ
ate("%d", Gets�())�HIOS and �~= �-:H Flag("PAY_WARNNING")�meT\�l >= 14�not version_kor-4�
Set1PP%T�T�C�.MsH CEFUN将会严厉打击使用协力厂商代充的相关行为，包括采取“扣除'�  元宝、限制游戏许可权\	短期封号X永久� 
” 等措施。如需储值C请��
 内苹果官方管道��#D0x)0@�~�Re"1Data#_/GamE90@9\ :GetCurAppId(),  tostring(SERVER_IDT�f.sz�	c�Lis"P1�F1�*1-�@QClose�QQuickUse"�%")�.� FloatX�Display*� LBIdw@�Id<=.l,d".LHDetail+d�'`l .� ProgrW�Bar�̖��!l#7p��NpcPhTL,M()H/)� "�*�p,�AutoFight%,,SkillX_f", 't '8)$,#Wea]rtA'((L '� ,� D�H�Hq( 'H 5� JueXue(� �$�,�%,�%L/Card(� )P '� �8�;out(�I#h9bSuperVipO0nil�,=�M,&�1h'�0hX���T"4 :�X6�('l�PX*�tx�g return �
d�/t'4�UiNotifhɡ('D  emNOTIFY_SUPERVIP_CHANGEX��WbLast�Y'C��i�F��b*| \�J\dw@��P+� ~='���|d'�\S)�A{Ui:Q&R%�7�"�*'�yC�H4�'4u;.`, falseT |�	� 7�ESyncOrgSerP�Id(n)0 �Env.*X X(*8 Pa<�Ddv(pKillerN

<� 	ShapeShift(nS�TemD�teID, nTyp�H.IsAlone()#t2-H"�"onMode:DoForceNon"x:k(me옐� 7�#jEUpZew�T|+print("��E"4L"�J"" UpRInN,� # C(� )8L(	-- DED�'�#��H
�0� �Popu`"shengji�KՐ:,B(� ChangeNQ�:#�0*D;'� W,x?)�Ui.SoundManager.jUI�(8008�|er:Fly]r)�i, 6:PushLh�"�1%�6(�d<"�A��k(�TeamX�FMytXY(�&�G�T�(�"<!X˩9()DcherStudent@�Up(�
D/�2\(,3�@+�e$�*30Starti�PH�(nDesXH`Y YX oLen�Size���pDg@u\�0�`��,����Qe�tR.�.`"\d
Map:Is@mbidRide(MnQT�wd) and n� >�� RunSpeed.tbDef.nMinHD�ot #�5HIndoorY
)-�p�#�K'��ByPos("t&.EQUIPPOS_HORSE�:xl ]p�1x|zMont�#�XDo(A (U-.L (D `�.act_mB�_r\!.��,|
l ��`x�bRetLd@H"�$TI$|R@+�D"�@T&�@p\�,�dRemote��$�HX	*�5�	.E<b'�
�D"@�Hx�'  �P( = 200.X	+plF0`ȉ��HeadSte(��� 5dStopxv(ntx6�(�0�d= P @�nK1TIDPh^aap()P@(DXb�.U(�)�gL1t?6opD	t"�'<h8l 4a=$�!)��/`��>+� |.@#�"�9H�3�P3CloseToWpTb(�8P$h�#�)tb(� -�0| 	= LoadTabFil"�jetting/P/NearToTips.tabY�""$A"nNpc(�Y{.H '�1�|"��&�j(x>�$(� (nCurFIdH��(H"x+��"d"�+(�%�3x%�IdY�0�H3[�(�]-L�C	= 0�;l�(� @@��#9+Ui:$�<Visib`3" ?`Pop") ~= 1�>Ope'<%*� , {�Id},#�R� '�lse�aU 02	CLOSE_TO_NCPT/�)H( �!�� 5sOnC#]&FT�ion(n�Ik=OldXZID�;N7Ui.xHome$HM$�XM$=?�0� *��"3��+ �(� 0ul"�' tbOrgPos@Dy�F"�@:ClXoyS�r(�5l�.��L�X�'� x`�(�('l .n' w'� :Save'� �Log+90 -X�7H<;ReC$|ZoneC#h8�,1@JK�Mai%�EPl"�~Attrib, �"�8'<,� %�0"�@1ute4]A	,(�r$lAin, (L z, "� �-� #�& s�s:�erDSt"�WE�n�B"�&�<Dd��ass("Floau�W#HYDisp#@NL?" 4QueueZG{}�^HClos'�O5� 5� xPower]�"�D#�0n"�gPrivT"0RP�)�o@eckR%A�?U P#`D_ADD_FIGHT_POWERP<�	ZngD\x(nSexK�Old@(� �K$�;&�Global("O$�\]z3  )� (<)P tx)9 :0<#A5<�XR^7er�->.n�
Id'X7\,<�L$�7�)� h�:�/Sta(<7T
*D+l  T(+P
+�S)�+:P,}C|\#$%?�(� .�On(l :�0�hape#�Gh
.�S't  PVhaXYP�"�w2d�]� pTc8`P/P7�"VNSe#HNsDST(bIx  )  --服务器是否处于夏令时��"�N�@8
bIsDST
end
  �%  