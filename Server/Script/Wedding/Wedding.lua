 local RepresentMgr = luanet.import_type("*� ");
�AvatarHeadInfo8� /� )nFollowTDistanceG650'�nNext�AttackEnemeyTimd|Wedding.tbTableNpcH1P or {} 	`  -- 所有需要倒计时的喜宴npc
(Scheduld1P ,`行程*� All�+`)X � ` X't正在举l
H��礼4dApply5x��		'p
申请进入�T信息(�
nWelcomeCount)x,\ I0�+PL
柬数量(tbHad�	)+X T�3X已经邀_	过H玩家
--[[
	h"��结构 ]W')�{}D�Utb)\ 0� )� PlayerBookpZTM{N 	nl�O123456789;�T6� P预订_6办'hXK间戳j	tb�d[nSex]\{dwID\ x , szNa�\�};�\主角|nOpen H开启�		�SendMail>� @发送提醒邮�de�	'(Overdue D'<�#W;期�
'H*�DetT]"{�&|0d'�y)`��这种方式存h%��是为了防止L(8\�Dq)p�=[�+v2tb�P*VMy�8�\D� 2�T{[男x��id`xF, [女.T '�t}�M	�>�h ��+>My*8t65y .�5LevelD,(0 T%7� dnp| 9� .�
Jtb.�
D�`����P�Mapd]T��H�.ned\�H)l 'D�,m SE�t���An.L +� �M{3�;��\�}�.l�.insert(��m�, '�)� ��5���!Z	n�oIh a�;p�Bv.��nHonor�!�)< �Portraic�v.n��szKin��vP
��n��(v.(8 �Faction���)(��Vip���X 8�l*�d%�*T�H��据/�	W��`@�L)P (�	self�Rtb+� ��W��/� *<	P	[Gift.L�.Boy`���+��
X�>�&	�<X:Ma�5("{*		}�(lGirl:p|:tFemaledA*�J3]]tW�u emPLAYER_STATE_NORMAL\2 --"0'��在线状态fun�D�&:Role*9(+�%M:	�+0�>@�7(� +�%+l +T@+< 
end
hG��轿�\��相关&�/'�GetPosih]	InRay(orgX, T Y, desLT LnLengthh�%nB`�T\math.sqrt(� -�)^2 + eY�YD�;�UnitAXE(UXT@X) / 't`A,� Y�Y�Y.� TRreturn p	En'�* �,mY)n Y 'l Eeb(
'��2:Is`<�Touring(h"�fY.n)� OAte�21=Oܠ��	d:CloseA'�1Wnd'l 0tW!truQ	l� r:Register(Env.GAME_FPS, s~Do�d��T6�+� �Ui:ChangeUi�(Ui.S�e)L�<^�ratJ:Disp�Walkin�%local p$�7me.PPL�if�thenA9	p.SetHid"n8(1_	en\[� 3LRemove)��s` /lW'nilD(�En.�U7�DEFAULT, h0hTn	显示自己@ �0d
�� 1�T0rtWatchDte(n^(Idx*�?.AddShowL\)� 	BindCameraTo(d , 22h6�End3�.50�		@'�B.Clear)8tp3�^$�@�Yx66Yr%`A)<7	e.&�BiD@?�(�3,�d)p�, �+9l�v-�	 \Y0��["�@l ��(/� P#ll /l H�Wp�$� 1�Do)D)��S�\?A
KX |qById((�	\not p(� �	3d�	X>moteServer.ĄCheckP*s	re|�Pe�	�$p,R/MyP�I�n�Y\��WorldI(���_\�`�d(�|2� nH�Squar"�HLib:\�"]Ks�(�t
�2��p%@� > (�OP#�L^2) �'�nx
xLAih����|�\�h�x�(N* 0.3�l7T
Barrier"�((n#�1\h@�== 0'A	o+oto�(��	elsi�	0� �`
�Y�l���];r�= t�9(TryBubbleTalk(�PPWFTIDDb�Csz�XA�K.tb�Msg[|]]X@2'� �.self:Do�+��	�bt, �)\	�T� 3�1L��	@`	�?p�QK@lS6�Y ��)���)�sz@(�tX6�OnLogin(bReconnectPxFDAhETemplateId ~= �#nTour@I)t 5tx/T-1�"and Ui.nC*U! XQRST".�l'�U 	<�� 1�Tb|
$� (l�*'�tb(| :'T LoadeH�H'ADh
P3+aD'l�'`�TL
DecorH0t68-� `8z.b�('��:p��*~	e�|�:"�%�,� nd@�XtbForcl�"$#�[%�1��时候不$h$巡逻兵PT#,�dBdʹ{/ing'��Se{["�Yb""l8q�}H
�#	ClientL:OnEnteeU(/", �
E5eu"�4b� 是判断c���#d'氛围�X��准 �Dq�'� )�中(� t��M #XS"p`�$#�\L诗句1�
SynData(tbz , �,P`%�
, �@Ll@/� �"H�(�]0t��Q/t��q #X`\LS:UpdateExtraSound'`I0%,H|T��)T %�Z)p twRes"�LdX�pf$�"�&@�P,�	=' �:]D)�p*hT�], ���t�P�d�\$,$�K� 1`OnJoin�,(����`
$X,048
AutoFight:Sto%p#TeammM,(l�6�Cl3u9fH5_, v in ipairs'~tb+�) doI#	x�l	Window(vd0�� �i拜堂&�A/==O"�RteMarryCeremonyStab+Dd(�6D0D9X�,� 'Lh�)S<1, '()L�6@;ASYNC_BATTLE); HpX D9X�3�E"�f/�p
(eE/�9BUi.|P�P+|Fuben'�U7��L�nenH�� 3�"(C#�01�xL�隐藏 #�;1d
�� 7CEnd89挴 #90 8��*TceneAnimT�p'p�, nL"�L|	local #�\SettiN�= �2.tb��T��[�"$++$=YS|ObjActiveP(� .sz�	�, truelDX\6 $|)�"�UpPath.Woman, fals� *hLoli(�PZEenՍ"�"��PT�tPanel"Ybh4�n��#�v�?� and  � .L�)��T-Px'�the#`K]4:tG�3One�(�x4end&�P3-S\�, pA�O�Ft [�	'LH7��<�xx"5�!1 TryDL�royUi(szUi"�_m	UU�lL��,h .UiManager.3� 6�6�,=8�Hs�rD%@!�XV�s6�6. ��46�OnLeavF�p(1H"HomeScreen��"2� Mess_,Box�\�恢复$He	游戏速度HeH�Game#yFSK�e(1",##�&$$$&�����self�+�"�+|1�Qepl1P		CheckBeforeC#l:TitleXKHusband�, [9ife�kif "`("&Mgr:Hask() �~re"�K�� , "你没有组队"@ �%�CnMyI"�tme."�tT-�IsCaptain(�7� 此等大事还是让[FFFE0D]@长[-]来操作吧.(D�embers = lx"�<eamM�(�#'� ~=16�必须夫妻双方5OA'r� 'X[1].%�dID(H�l:IsLover�", n�7h你们�"m:����系( L.@0PItem#(�InBags(}N.%�B�@`Id)<=0 and �Money("Gold")</� Cost7���宝O足'<Il#!Fsn1X1"�RUtf8Len(sz*|
h2(� 2/� Wi,�
math.max(�P'K
2)>��h�Max or m�hOU1�<.� i(T*,�st"�l.DlD	 ("可输入的尾码长L�%�� ��%d~%d个汉字内L�0�, .N axy e||&�6Cp{hAvail"�g.�`dy3� (�7���Pz非法p ��，请修改后重试'L%\ tP�'�'�2�[C(#Req-�Az(`'�bOkfEr"l�j#:Cp dX	 the##-9zLYe`-\ RemoteSe#�_On�]uO�("C+,j9zH:d�+�1�PropD�(nBe�IdHS'7 Npcbsz��h@T�nde�EUi:*�)"�%iage�&�)nilL'd X�/|�PBeside({��@().nh(�SId}lW��State(T�,/�B�(n�Id ��
`B "��
�l!<P�?��
� ��'�#� .�O*t  = Ui.ͷU$0{PVX>ration:1�AUi6�@�[EngYDdQ3	U� 70E�$D,nd) d 8E/�End�	(�(Enc�Wal'�}Ui.Effect."+All'p$Obj(1|�:+M-"3zifح�*8��self.3~1'iU.�7, h�l�b� 1]O�aResult(\�lz
:E1@J tȝ\@+nWindow("YanHuaAni��d	�� 3�Cancel�#xw�S2��-- 对" � #��求婚过程中打断了（切地图或者下线）1'`BreakT�'|7$F�Ce#�\sg(,��>.sz�Be�Tip, s(�), �4end

P$�F� 'p�� 	<0`�,�/�,&tb��bUi:�0hуn� in $�U�"�!{}(P*8D+��'y	�+� �,	祝福完成1DOnBless\_�RUQnlP��\�#�ing'�^	T8$f)tb�HUi = {" ,Box=#V9, (t8Task=i*}1Set�V$fW(b`�h%{R.tbu-Ud,= o"L�X�Tu"�&� �vt,szUi, bAutod
*���,"h(Ui:Wid|Xible(x)==1��U$sA).p�!:Is%�MX�in")'�	l	(��		�~'5[t&�jR		�7"=�U,(dt!'� H0DelseX ��h(zseX��&)��"�^)d�
�	,pp9H5��1�OnDr]GC#('(bOnx	�LDT Xa:0��6�UiNotify.On�('D  emNOTIFY_WEDDING_DRESS_CHANGEE;Ol8Syn&�@"CP(tbx x�[T1�@��L�^�rt�'�A6�7� 	sel%�B/0�Arrange��qif next)f�)'�	a.'��\� (a�E0 �\1�	$,`	#�E�� 1�-� ���nNowxWGetd�qpnT�"�(#di��1��y)�U�
9X�L4tl�t��&�D#�>DownLv[1] - n�x}n(� >= 0':		e
.Xu"(,�
"%s:%s", v[2]u�"L(%)yJ	�f� �( p72� �X "hUJvr"<='T(�0\#�I$��il|'�� � 1�#d+�KmAr�AHxL.�
�7"�l �:�(1� P,tl 1t &�ux�� 1�%,7\�&�ɆRe;�:)� #�6vOn)� 3��@'�'�OnN��('E e��#Pr�SCHEDULE|v6(DF#<�"��re#R(�'*an*�c�D��#�&<b -- 但会各档次没人$��的日期1�BCa#��D�n�L.�l\\##໤atbMapPstingD�D��(� [+d"�lDP|�+or .N .b"\�'X�&tb`H`�-ԍ(��+@L�&x�+ ,��(� $<�5� "�|rtl�(�:@)��xLL(�Hd#H "�$0, t)�.nPre - 1 d#�9�*#d�Ei"<�'L@��otH)�&lݺv		�!�:pwA	0l�*` == �.�5_2 '	*� "DSXw	ByL"�SDay(�p		elsel9�	�	0y3 xWeek�, 7, @&h �"�2			-� 
paulf20181228�--WselP�heck�1+�	"�Hooke))5t"j>.i$y�t|J*� ��L	� � r�w�',/l2K'HadiX(+0PH�>tbHH5+p
(	D�+@S��,(� [+l "t@X��'@(�t((�Hw+�)�
@(� L*h ,�  Xp�$��)�[�]x*`i&�(	�#��U&	p+@08+�dRH 3�2h �Hi�(�ʋtb%(��=			�.�= � � �'�= ��,�IN,DxRc		�m� �Q'�P8�%@!�eUd(`
=<!"�0y�6L P!)|@ata, bMerget`(T�� ���`�D?�U"eL�Y 	hA�	#�&)�1PR�, �p�#� "<GD�H同步�8�AS*�Finish�&U 08+$MAP) $-- 返回�*t�40"(���:Sor&��T��A�+=&\$/,1Y4#2 > 1 �6�{fn|T5'](d>\/d6n~a.$��y}b��	D�  次而优先最新$���#�&�2P	����y> X
.T ��?		l�高�#,()h�&D��LX	�l�t�rsH.5�	� X�s�xN"s챂��	函$��数据1�'�Y(|	=�StT�*lQL�2� ��	� �WELCOM*�/"6���P:�$ �1�OnNew#���:SetRed#��%�1"�?_�W$t�	  �h��理09�#����� �(|�2�$l�3aSx< ���, b��|DPv"�0�'�W$��+,�Hv�U\e 	��, �x�� �])h=RGe)��
�)��tbLis"����"�F&�jpa6்)%�0L9筛掉�发��Xt�h%"X,@#(�[v.&߆d] '��ins��, #,��}� A0#�L� 	�		|�H��%Td��`)����< @�'8 x�/		����, -X�	���M%�)�	家族成员10
\6KinMember7��8n"��DM�P"D8er"��"��`HX&p1��.в����
tbOnline�"��\l�H�" z$a;;\#��/� bM()�T0�	'a�)(o	刷LK离线K6和\L�Lf����%i��爱侣XpO- xN�"Kand `"�&/�
,� DV� ~= me.|*#8`-h ,��Ei>P�'�H  =/��W按职位\�低排序�	a.nCareer ==`W��=	NO�|�贡献�#��	�Ut	ontribution ��Co(D };	��%4.nOrderA\NKin.DefL(�s�[t
�]t>math.huged+	B8	b�1
re# K�< �B}e#�>� E_#�\> (�t(�!� 	好友列表4FriL�_X�<�L����F= �Qtl $All�X�Shipx'd ""d()d4�2\'� )4d X@f��_\= e�a<pmo]�om /H��*thenX/�i 6= 74亲密Oi从Lr到底`�Sa.nImity >hr�Ue�S 8T
���6'�)f	We#�)#�c(l��W%#aC0*$$%=�On#$%)�n�t4�= �0�D�9/p�(�!(t'�o{Zk, )�i�x(�}�t"QLW�$[k]Qgv�7�7"�1* x.Q.�3�1��	"�A@)4 p"|�����<�X�����3Ui+	�W�4W�#�y", tb�lT	'��=�= CnVe"��vers]�,Rtbx�Dx	{name1, gold1}|�2�2)I 3�3�...P	�"SGiveL
boolean|nRemainS123@�1$t�CashGift(nHost1, � ]t'L�'d Dself:NormalizeIds-� H#Pt��s�|��.U o%X�1� [�hC:t  �	2d	�IU �CWEDDING_CASHGIFT_C#,|L�?/h,`|0|���"x��15� R;ot8��,�ReqPV�(.].�TY&09!OX�gout��1�]n"�r6#Get=<,p\	t 3k	if "*x-�	�B1] P!=� �IHt��r$i${�q#čH-X4Lp=math#(&Qp	�$& (9�&83/}	GP~�*L<-p	X"�X:�L#��K+me.x�X^p!"��==�/�)@ (�Z�%x�
"不能送给$-0"Y	e`�\ {
ot )L�2�tj t,��L�选择赠送金额1�-�Se#[�s[nq]7t)P\合�(@��H$GetMon) ��
6R�)��, "@H_enough_gH�'�	DMsgBox(st+�确定要�&��%d�	[-]作为礼@"吗？tzm)^�		��	{"�	L'��v"x�]Qo9�-@	H�8,�9P�� iJ	|X�8H取消"�}"TX�\t;b�On$ ZPromise�W��-$���U���Me�N'��:OnRT��State(#�bJ	se�C"Н(�]�/Ui:"<q$E�(&`N/�P"#�BX��.n�Endh@8lChoos'ȸL>A	T��"d�Tips"P"t�2| XI)x 1�'�t,�',�\X
6�"���#��	Firework(nIdXڊtb�L��H�p��s[\"\m܃)� , Lp�#0}&}Li$�L(� &l4@"l$��(unpack(v#P��� 1�8p�`� p`|� t�
TryEatFood(nN"��m6s`_#����.n�kWrIdT9�(8��%.nDinnerWai#�� * E+��'&()"�K�m.0t#� 		=L�#hlhl��;�T;`P@F|rt@pcess("食用中@ �XR	
1�/��X�"�&�Map#�e"%PnPKd) 5�L	T�}&��"HStrip")"|I(ED���P`�DfXl;/���9�(2� D	x�l 2x TA�5�$� 1�"��@�#�b$��\
L�)��m_"��U$�.gameObject"Pd�(not �;7�#F"�1tlqX%Talk(szx h$�Gtbteue"6�4|5(^ ()"P"#,F�Boy"d7L* [Gift.�Uo%�2�szP|�La.��}"" �tbGirl|�($(�a]x)Zszt'�pl.�re#�N,t!�"a
"]as'�L�t	��@(6�O"�A@[D.Pos(tbT xH�|t�.ost��8"�%a"��E(a	i$�.n"��Q,PL"A�[�H`�&�!0� [1]P�\�TӐ.�[24Y 3HՄ
1�O�Replay�p$�T`�M%X!8(XXceShowL*@*V Idu fan� invtb�)%lP'\�Mgr.�IHh���-- "$z��双飞1|��DoubleFl�Ui.��.hX'�Zw(0`�:*truelf#.n'JBeT4STDT/M�U P>DOUBLE_FLY_BTN_$J>, #$1zUi6��ViewPhoto#�*Opera"(^&��Click\\�:CQ�r"��m�`�Scene-` '}sz'�-� P%L�hm , "lian_twofly_cam1", 1�h�-(9219, 0* me7�+2hFinish@�( dFmsz(H p��8\� 'MsZj:O%4/'� ) FJte�)�� 1�	 
Ui:-
1`�+,
'TTh�(�CheckAdjust~B()�t�l (� En"c*t|m U7�	D�ZTqx� ��\&'�TrapO$�E�"�S$�=请求�v回调3�%��'E(u!U (COUNTDOWNL)�� B&�� 3蕅�tT%3'�~)In� me.bI(dA�t\�H� �*�d\$�9PreLoad'�Animue�u-- 退出�8t ��A"�@1 �Z �H(�|�x点加载�动画1�6�%�8nLove$P1�sT��"�,"<J@"y'� ��ElH*	Resource:Add(H (15, "��/Xfabs/#\�Jing/shuangrenqTgong.preN")E&el2� 1<OnProcess�	e(&��#v/, �| �&�XPROCE)�8[end  gj  