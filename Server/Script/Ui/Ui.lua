Ui = P or {}

Ui.UIAnch\ = luanet.import_type("�");tGameObject 5� nityEngine.(� �CTraMgr5� '| �Eff8�Represent\	�	ToolFunction5�*� �Scree6� U)<��
ResourceLoade6@,� '� �Setting5�'|�t
local@8Manag7�Ui�ll<�H'l �9Sound�P2*� |	�CoreDll5� tInterface.tN")hH�@�;
�
UpdaHD2�hh'� �'Applica9*L)� �)@ @)4 @\FTDebu6�Ft��SceneTS\D'4 Lm3|+�	d�<mE\.��r-s_CS,|`5��g��1ouIPe(@X2,T 54.� `�9Touch�2��d�Z
SkillControll7\-� x 
-- 注意：此枚举要与C#内的Ui_LayT
保�D�致|LAYER_BG 		= 1;			T	背景层(� HOME�2�主界面+� NORMAL	M	3�	普通浮动+� PANDORAI4�tenXE 	t pandora 精细化运营UI(8EXCLUSIVEY5�独占,�OPUPu6�弹出式菜单+� GUIDEq7'� �导+� INFOi8�提示H（各种��#等）(�LOADINGM9�加载图所处@	(� DEBUGr10�调诐t	BUTTON_STATE\_{
	NormL�= 0,
	Hov\=P:MP[�sedU2TDisabl�3,
L�P
tbUI_EVENT =
T	@A	以下顺序@J满足 C# TJ对应�M�
	"tbOnCN�k"\�Submit'; DouH,� �'� �'7 Sel\�(9 ctc'8 Drag)2 op'3 Key', wEnd'< Long*�UiInputDhange�UiPopup)T �allBachL'Ui.tbQualS�RGBK,{
 B "f� P	P "62cc40�2fb7e`�e43eff�fdaf07�d6df3h�bIH�VoiceCfd�false��|ickUseItemClass�9"Rejmt\
	"TimeCas`	"AlphaChargeAwarl	"Speaker���BookEx�+FurVur��AddPl|�Level�LotB�yTAe�?WeddL�WelcomL --婚礼请柬T+HouseWaiYi�d��园皮肤FTo�:ShengDianLD
\T#hbtbSafeAreaOffset� --x,y,width,height
	["WiT�ws"]j60,Lf� }@W	["iPhone10,3�-4D3, 8Z 60-� 68� vivo X21A�45,r-9XJ nWnLi@d=140|
@�qMeta�__ca#�!f%d' (self, szUiGroup)
		�Ui@|_RUi['� ];P if (not tbUi) then
H�print(deT�.traceb[[())gendHreturn xPl	};

setmetatt�(Ui,\p]
� Ui:mV(IsS.tb�S {I	��(@ WndStateD(P HyperTextHandl,n tbXFX�gForOp#(+(� tbNotifyMsgDataPblPK@�知消息中心
�nUnRead'� NumH0;--0� 未读�数�tbCe"�'LDl'` H�"�,'�eD,
if |2���$t�3'�;
�*\Create�(sz� -�T?�l\�-�(] o"4H!Lib:New�(�DefaultS9	re�?31_Get�(P MountUiTUiNameX`$M?(�''ttP.insert/� ,�e�	;
	�D�*	 
� �e"'
1.M�")�
	/z (sHu�0On�AH�)� 	fH3iy#.���1 do
		X"� == .� [i] t�I	�remove(.� , iQ,	|!� An;���szNexU|.D[1]
	3$�}Jep�o:On�:Emptyp�dl +$0� X�sz@loadStLbi!"tt�� HiCloseWi`�("Map`/hq	3 "R"
�"F

+<�UiListtXxx2)t�02j = '�LR'$T`t+
		{L 		"MessageBoxT�			"RoleHea��XC�tSmT��FX�JoySt\��Systemn�ce�x\ Tips�TopButton���p�AchiP�"l6Pane��\x
��d"�)�P�PWelfareActivit��	A�	�^_, s�e
 in ipairs(tb'5)�_�5:��:��9x5(�*�5� 
ui �4`�P���'Log(">C  ExB> "(�rgrey�
�A_:Ƀ(*V--?l-- 打开窗口+�	OL�-�, ...Yl#^DbR"�# UU�sL�bidShowUI+TT��R�DOe&
У� :(�AtPos', -1� ...T-�*�8� n_X, x Y, ...'�ar"H+{...};
�;CheckAndRefresh�ʾ2);"�: 检查UI脚本对象，发现重载���更�H��%tbWn"L41�\P$%�$V) �%@+2X@:]	�..�")�	= {g"X, x C#unp"&L")};
	�2Dh- ;nilPpy:�FVisiblT��l)a�1'p�)�An(, faZ�, )`@0@ 已经�V 则需要先执行关闭
�b�/nRetCod"'1;

xnt�X#\1�-'�.
3�;
�
h	L�D6.CanOvend'|t!�:(q (� 0'� (��
� @�.O�
 ��ji, �(_LibP$�8({*� , �,*"})A	-+; or J%		)�~ aD&.� "�@'前
	�"h,l(��,*� �	|�940�PH"(/= 1�"mH.]/S|�+��(���*}	n+`true�@�&�/E@�/��m, 	�A,75�	6�9��G� @�#2P��('D H�OTIFY_WND_OPENED, *�eXnH8a+:)p),0I�q��败"�F)$操作
�
|�IsUiHideD�"-'p'��0p��:Set��e("MainHr���5x	D�q	U$�9"�+] = h:\\�G--OD_Br"�!op(�^rey� �K;
`"�S��1T4V..j�Ui*�,D`, ..\�* )L,� b`W�\��QP�"�7..�ش��&T�"U)I;�/1��,H;+-n��(�xm9(h7�~= (��,"eQ	� --ȹ�- 了就什么都不做
	i
l�@Z�!�l����� �t�>��, �,0�T��&h
'l
�s���Q9xx.,"�B*  ��在初始化函数则调用之
	�?w, n|�D>2e,���;<t�	 
8h@4�F(�t(�, +lh'�OnN��5�CLOS.�H�"_:On$�!�3'�t�CtbL"3-= U"+USam%�6t(�
�Np�4td�.rem"@;�)
	|next(���5tbArg"	Ht�[#� "�:"�.O"� i#�8(Xݫt�)l�G��H8�.tb��|OverLap('( � = H6H��'tDL1�/�Te"t�' ,0@�,P�t'�,�#8?�+t� (, �	��'	ho|�
x��/All�*"|="PDk,v in pa"\8�)H�#�!)$e8U+�(k@6��C�aitZ�Fo(�P�--按队列$Cc打"6�"�k"H1��果嵌套�同样的$�gL会等S�面�结束r����新'� &�Z*�D;"�P*$(X
h?PhH, ..D�T/X�/�@L�1�XQ�o"�O
'�|
@8� 
�Fi$�Mt�J, 1, {...}P,@a�i > '@(+U 3�F --凭证失效这'�l可�L� ��非常多,直接让�* 	��顶掉保留最后3个
		'4,�
�- �XH"0,�AUh�"th$>\	 5h�T[Ui:(D�1,� )(yr#E#
�3� ..D9pT2<�zT3xB�4Clos)�,� 8���..T2���E=�,�	-�  4	,� 
 �P	50y5	�'48'� 1;I^
 �*��
BlackBgW��YlfL-(ltb i+0"�J��\\tb.b��o
�W��
�	H�`l #�-��换$�-状态P�r���O�关@qg�����起来+�JSwitch-�, ..|Oyp:*� 1�I"�I..T�*�:� 	nX, nY, ... Ul#�L,�.H$� == "Commander" X  Sdk:IsPCVersion()�( 	-- PC版不允许通过*- ��GM面板\.��;
	ll��"V/cF~= '�(�.|���A)"t%%� �Cl'�QU#Qe,*t-�nd
l|>查看�>是否\H<+X5�
%]2 h1%*;�+*Ch:�O
	l�7Q�n;�N�d7�.s$Xl�6
	p.�_tbBase T,�tbClass[��]�%}1"� Re"ga", �UI_NAME��})	|D实例le��类DF等于模XB'\ Lh说明U%#S重"�R��D$�R�$�ST���反注册消息`TZ�
RegisterEvent'8'4XTʉ:L(� (�	m�_h�'�tbZ) #
j		P�$u0:"�td�(tb�[1]'[3] @��)y� �	响应事件j	eTQH� Ui.CreateUiLuaObjLL�.pPaneltt�/�U�3)`%\)"�%��成U�,'$�p m 
)x.�pF, '�s&U
'H�D= At�Js�P" ~)
tQ#,;�)�3$�I"[ERR] UI \"".�Y.."\" �is "##,b"!�	�n;
	e$h2�,D<Lib:N&tw�Y	�.U�$As�;	l&为每个��表设置�Z�"dQ�s���p� U"u%U��]X�p��7\`+(X _ListOfP�J{}"�BK�组SC列@Wb卸Gd时$�Y

	d*�
On�E "I'	��&?\�:��]�?��R�Q�RL=L�;\bL�3H FUi�h��H^082], �l hb		� � UiD!LoadUi-zr#�*\Rk;
pl�销毁UI�g*�OnDestroyU(dWD�L'eUU"�?U*@x3L+�X<T<$4a 
释放或根本就没创建
��.H@./i
S�.tb+�= n#�LPVStZ�[s�^pS�X!�XPP@/A)� f%� Ux&3� (
TADY-��PD7�fX�?�U�E (�t<�,
��i,z�om"W in i$�=�.(�)��@=�X*\&m]�p
Lp`�4d)� )D)�	.)`	�
 � �(XUi()#��pl `V�F���)�p1�T]�(y�,\^Parent,H Self~)
:�.Ui��*�Z
;
xB �" .. DN�.U̳PA"UnknowBO")r" TRD��*�..4�!6�w= L8�@2�x(TYR�
	X�as'P*l\ �roo"�tb�`�=��<\F�TD�0]FtbLn	t#Pi&\B�.(X-��[t1�LK)�U	�LJ�()ue"8"q 
��TC��]��#&*�关联+�	H~(<'�	GNObjDKi~n��Keyx� in �n&��))��X#�]'�v	szLDV, _*-� �			d5��Ֆ(+@�	�"�)	� t l +�OnUi|�t�a,L&�OUi.=4PAP@|+�N[tb��c'�U@�'�V$�4.� ,&�3 `$5@?1d@!�-*x�,\�],Qt.D��sz��W�8['lp�]nDb���&6(OnH
�]E� �Ue"$�!!!", '0�3r��HW�	�� \�p�/��UidCall"N� Tkm is�T�0�ޤfn'� ='�'�@X)�)� � �
�LL�'8L��A,*�@Oper#��:Mark�etx�!*�CheckWide$]�O#Ѱ()�DeviceMode"��Ui:Get)M (t�;tb�\;`�.tbS+(�@)� �'� and (�1�.nWidthL"l�d0D'1a <EA.�.w})��&'� �'/�"�i"��(H--修正sXarea
�7'�=Q:7�\K'� th#ULl&��.Set,=(%�B�'�
$�&Pl"<�HeadMgr:a(p-Guide-�|LHotkey�
	LP�eOB"�{Npc.pwC, Y}Y
L$l-�
�1�kGAME_INIT_FT SH, �<On`
`Finish�D `SYNC_P$�DATA_EN"�elf\�Enterf,	x \ERVER_CONNECT_LOST�X
ConnectLos"h#H `CHANGE[ GHT$��(\hangeF"��#p-� qO�SEt�@V	rt�Server� h+�+gEnd pIFLY_IAT_RESUL(�#��2TxtResult cMAPN7AD#puD5R!Ma#ݪe �t	ENTER,�WQ	EpL� <�WARTNER_AD(�
Companion"�� ^RE�VFAIL)�ReCon|VFail ��ITEM�.��HasCanQuic&�̴ $TEAM_UPUwE�.Team$P� 4DROP_x_TYP�
OnDrop"T�Type,�7 P�vAUTOFI@w�I a@vAuto�v� \\>_SKILL�WSAdd�	#�д @REMOVE�
-uR#��
]�t( 	RLKRD_BEGIN�D��RecordAr ��+ظLEVE@"p@L�D#U�C��d, � TCREATE_ROLP ESPOo�SdkLRole$�2, D TSHAPE_SHIF��P7ShapeShif R�7/\�7.h

	--Timer��er(1, $�&@�'�si@�'Z )
/ #+�()#@Ui��P$�('D emNOTIFY_�7xX�b_POWER)0�. "��0�a�.��NpcCurHP,�}0T,� �$=*pP = me.GetM(DC"�Di$�ј#�&p%I;;��+tHz.nPLife > �Max�(� �RestoreHP�d	l *Q8:�`�S:n(n�n)
%�)Floa"��W#�sDisplay%\-" .Class("3� #�CiL�
 == 'mVUi-l�6+� 	XClos%�}:�#�2� X�l	0 and #3�.tbShowQueui,0&	/l#�knPopL?� [ p"�1"8�Bp�InBag(h'�0pOpenW�/6�, n\HJ9�?:`��T(sz}�)�K@#�a#"(� "�eO	'K:On�|Info l	'� (��)bxD)x ��:Ism(TlX�(VAc"�7:CallDo(A (Ij.L (D `
.act_mode_non"��`d`l +OnH����(n� ID@+�ŅL+3(� D�+� , (n , .("�31�Ě�Nete'>�.� ,3�5�*#(nn&)
lR�`BxR.DROP_OBJ#$_SPE �C	US.8.PlayUI�(8005P9	elseT9:HMONEY M4 L"�& I6�
1`I\L$0*x VfClH�D$for _, szName i(>PQu(�*�'`Pstring.f@y�	�) ~= nil�	re#̵true;
		xE� 
�#}�;0Check0-(n`Id, bNew, nNumberD`3ot Login.b#�1"�;��;
�tMv(� h��u�)��`"xD���#�,Zmep߄���d��n
((�.I�s�
x.EQUIPPOS#u[(� ])`�EquipPo��'L R,-1�
z))��Gold�:��	SuitAttri(meE	3� Train�, -�Xe7
� tb�' �s(1pO��3T\"" �bId�\;���.n� ��*FT�ionLimiti�0`.�	.l me.n�'x���N <= 0�		3�:HaveUs@��z#		r�
	@ An@V�)�A�]�b:CiaUl��3s$d)l�A�h"LYv.Ex�{MBAG(�#nnTemp"$1,�i�|V	t"DV.insert(3|*}!,�r�		yE	` Tp>P)'�Fy0�S,GetyI+)�B�:O � 5��� '�P0P"	&a)h�('dand ��@�Ѝn�0)'�P� P\d! �the�	h�:$  �'d_ X, �� red�@��7� d-�#Com(�H(nPartnerI\�nIsSyncH�@-`o/�d<�eT1�<'��d!tt!)$+�")�c'T �	 � = #�s'��$ -&`�"CardPL�ingRe".P")�X|H-��1� ]�+�x 	�,(���-� )d\7�. *�P P�'-�	'\"~4",�	@�#�#(",t /,[1],0dx2l +
Close'(t"0y�RL�"X*X i6I%� #)�  >(Len'�
=0��T#next(@>H�cy)�@��.� ,, 4,"Hg 
�L*@s�z� 5XH]'H14HT DL  'P  '', 0H�!� /EO.�)#	, n 
�	L&�y�4+)�'`�f nil'�)�`9��lse@�I9,� 'AnhRDd�	nd
4An\2�c'y(T&|y.bNow'T s = %4/�)+�O-�mwUi.HK.LoadMap(L#�1sz�?ap"�4, +T �M�0,�)

t!%L.qHS�J(n�Ui%�.Draw#�>�L+�>PrelPY�o}L.@
OnceRecycle, -| , true"�<
-�rOpera"B5 Tl-� ( @�ResetMagic�M(x l�,+<|learSysNotifyC�()Xog("MC1} =+ "Tif ANDROID�T(��en��J(1EeXPWIOS � 0) --有的时�"@�一次z&��H 会消失，但icon上还DK暂P调2\能解决
	P?-H.0�0l2�>H<1�Knot�Nb5�;
�f	self:d2�l#*Ptb�yOdCalZ7ar`��#u�(L --因为默认是推送_!息L#|��以存盘DL不发Xx��目
'"9My�f�lientdUserI"UN")� ", -1T�U=wnpdsT`e\�TodaySec(lj"b,i,#L�ipairsH��y) d�#b)tb)�[v.szKey]�F"�'v.tb"H]X4'` #�-i2, n�in �+� �		�	bRepeat"�9)<'t&i/	�$nH@~Tmath.floor(�/ 360{G		 )  �$Minu�3)� '� - �
*� / 6@	  		+(Xs*\Message(vT$2PtX �, v.�I5	A e@[Y 	� � � p 
	WuLinDaHui:Set�4)��*6On�XPause(pt "�QusT�c)P �6;5eV�
	�f3$�
�8ersion_tx�Pan%T�=pxl + 2�sz]+,�4X �+(pYv�kor#D=��S Ui, \cAndroidSdk�� >= 2%�, @ )�1HWithu�(� P-��, 1, "d�_silhouE�eWw"")#�^�-U <� ��	nd0QOn]Ar,w�()
H+@ALoadingTips"�g/dOnConnectSe"|�End(b�P	H0� == 0�A�LRe�Fail(j�	L`�D�b
 f[ !!x�KUiH�)AhL,p�0DH+�T1Ente#��(D4��x�Login.b'� �/] =#D!  --同步完进入游戏了
	jinTearNpcs(X�tf	me.dwID and �)�3JnLdҪ-Pl"��I"\�D�	` -- 缓d� ��家在本服的id"�ƛi����I��\�变
�.�5DcClass(6�nT�"
)Qu")m=$V>LoT&:Stopq�e$�`Y/
��Cl)Create"H}�=vFRe�0 *�:FrD� dShip:InitBlackList(@		ChaLv�Private�
��,�M nil
�:Zng)�(E"n#�&"(j@5�Oea1� 
x7ZWiV%U�"� /�=&�#DestroyUi(�;
�B Ui.�t�	Bg 8h�

	'I+:�n"�_sir`'�O, Leavei(XTeamMgr:On)X DBoss:ClearData(h0-|'\ MapExplore-� ML|��K�cCache�T2�:.�RankBoardXQBt|A�Shopnne'O  	C%�&dU$�-"@%L?;
 	Fac"�/Battle�l	 	SuU�y�J()H`lZ	RedPointTimeP(DForbid��'pdEscortFinishInfo�&(@& 	Domain���&,l BCr/� $�%+'hvT���U#�% 	%�Zremo4J,� , 1`pB�b.nUnRead'� NVV
	��.n��Identit'^	F#H["�sX(3 Slo"��#�N--tT5(3)
	"qwvD	^ea�K
�tb�Synci% ��'} SLjXx-�
2�MapL�d(nHTemplateIdEl{� tb]SR�in�<P"�-X �.� ;
.�Home$��MiniD|��$�;DrawWFogtAvUpLUseRes(H u�MZDUi�Check"}Hid�dUL�p`F�te.t)���Bl -- 处理�#��	地图后黑>z��"�6��屏H�问题08�'`p��-i ;0� �9�\�) t	AdjustView()��(� Do�He�TBy">(Y:e4#$Map��/� @ \*�TxE@3Path.� ;
M @`Z.nLock�?�1�P	T'��(� Panel"6���LTUV�wUY@
�stb'Q IEanP�p+�,�(� .��"�#�+Sor /Q .�fIDl�'��h!%{�"lp�j�`0h"�� P|�ifLszWnd, +$ͩ)"�:x�!:)p�h�Txl +XPx)L�)�!/PD+�;
��pNpcDme.GetM(�P@�then��/@,��dl +�F�˰(szUI, ,� , b�+��%�yp�)0*��*� [m]HIK;�XdE�9��;HHj(�'uU.�#h) == ,$6Z�os&p���l'l +�Is*T�( ��@, L$7���'-� (�re"o false��@X`�-� ~= / 	/03,�truT�)�'.�wCA�H�wX%Text, posX� Y)
T�(� �:� 2� ;��X�服务器远程�X7+�O%D!MsgBoxT	@, nCall"4�CounLtbBtn, bIsServer#��otTips|�, nTime,U�L" "@�6tbOp$"
$�$C71, ,xx�&�$insert(�, {
			'�(H��T				Dialog:On@D��,(�C}			H/, i}HF

"1szN(#8iJ:��D}xT\H"Tde)�>	5�L'���?;
`X[mOpe��List("Mes"KH", s$�E�t�.s*�, �-�W,(��'�`nChan"�58\FileNar4sz��PD�\!)4 P3string.gsub@'� , "\\^"/"S%	sz�	/� � � �(� �len*�) + 1l)Dz�%��(� ".lua$"'pt'�("RelV�",(�|	`&l -9C$�ELost(X#TIsAlone(#D�٢	Dr:Reset$�eAni(�

tKx�self.l�RetrunLogin�M(p KickOffline�KD^Wi8t;]� '
tb.L}�"]�	&�VTGtNowD6H�p�		�nNL�Reconnec^zme\6d or 0IZ	~Pl"dDEvent.b��6� <= �Watm�	@ 6� )� L@��D/����eM�
\	l3(�(,�"与伺d���断开连接)w	z			{�'L�Ktelfu�	` �turnTo�,� �{"重]"\b 返回首页"}, nil� UDeuH	��� end

	Ly&h>DS�T�@�U�L-U H��\�xt�	*�x��'Tt��^*�j:8-�dr到有��? ��本，点击确定前往更L�,{
	a {'-(Dg	Co̹.IOS` Url("itms-apps://itunes.Tle.com/D
/id1086842482��h	Q}9~	� {"_认4�e�GTo`�p(-�9�请P<H下载A�!	的用户端�	�	{0�	)�^.`URL($@+r.s_szPackT"�E\(��	;�d/��fil||io.oX�,�ers_�ent"�?PL� .. *Gray�`�, "w+�/x
:write(tXR	ring(SERVER_L SION)��close(ae2�8ShowNewPP)�
�+<��2\ ~= "%�	j�IO'v<�9�=u	:| )�	D&�[		{�� 'L3取消4�	�_ 4 b� �YN	E)
l -5 R*�dd(bCodeA�l#�JszGRMsgO�if �  == Env.emHANDSHAKE_ACC_REPLACE���P�"您D� 	帐号已在别处登入"
	x3:|�j_ERROR�P�dg-h'�@?PONCE#@�FORCE_LOGOUT or
		:�UMU_ � DDICTION_CURFEW>�'� BAN�\)0Addi#|Y@3"�P"�4ShakeFailMs�8D6t*,� "'�'�IC
l�'�%�"#l .h'= tr"�7	%�%fnRetur%�'= -�m:�%� (JK		}.0lnil
		mT	;���߽�{+$��� ��D�1e
�|-MSD�"�*F_(s"�2T�t&5+=�!�e+X^,,x1(z.b,TX t7@3=Xh � 1 �:�/�R*,h5Ll|�4� �#�'�|�����Reconnec% w*�({�|F�B)x �n�� ,)0HRese*�2
t["11L"v2.b#pV"De�k	)�I.
o.Set$~Gdeb�ra"Ag(#<:w�Ui.$L4Mgr.#k�Anim�Stat��+� %h�RoPion(D
1 +�(^ORe/H @("Ui -h "�"1D)�|	self.Awc+gY= npp1�3= �DSUi:O@goutFinish(2.� 
y0P"�RemoteSe"�E'��18� (1000D�v 
	Loading.nDstMapte&�eKonil\T`eave#�u]T'� ,&�K#�fp!�hCd
	CloseTt\gin.)�(@��AllW#X;��Clear�@'d�PP�Obj(h�_
	LaT:`n�#�{�L,r�an"��.�,, P�}B		L+� KX(� U}TI,� TeacherStuA^t)T,` 0� 	ImperialTomb)� *X 0� WGOare#Seity)� -d 0� TimeFramePClientD%^P, 'e }0Wed�E(�}/'Reg��\r"�ilegh�1t 0'\NewYearQAD\�Ui"=r.*| 0*(�)T 0� Achieve8�+�'T jClLTssCk>Dat#�}ee�l#�'_tbWndY�F"�S���[0]Hk 			-- 非战斗状态
	h�"Home$�j$z��"RoleHeap�"TopButton�(� Tas6�		)�.� ExpBar�ChatSmall�FakeJoyStic/,&�tD�n�[1(4 %*Pk"`�� X0-�(|)X	"Battle+�N}
8�H;"XtX;State�:Ui.��_DEFAULT~"--�:1E	)��l^	[')A�BATTLE�	
 ID：1异步/�,� HIDE_ALLduMIh2隐藏UI?�	r	--�3不知道干嘛�"%2
)�$0IGH}
�X,�
(�(�*)�
4*�
 d)F4 3KID
)PSPECIAL_F:\*�0X2�)5 �#l探索*�MAPEXPLORa?
�*(0 �Min#��Xu*�*+�	5�]GIxG6 通天塔？� 
)�TEAM_'�

�R+� *�(�  
@)�7 门派竞技观Th�U 
)(WATCH.�- .�)�8 �gm小�<��式*�MINI_@=At
<�4   
�> 9 副本�/4FUBEN m((�+�)+�)� 10 历代名将、家族]D
)xBOSS6�*L(�u�	)� 5(�)�*�1 又 , (4l 
�	*l2 白虎堂*�WhiteTigerFuben ��	=d13 领土-�	Domain�+6�(��.�	)	)�	 
x*� ;�
*4 擂台（@	主等待挑L者阶段X)\Arena�Wait(�(�; *�+�,- (p�d(*)5+*�%4�$%8Mai)�
*X�76)�#�0>�#�1(�,�2t*� 
 *P7 华山论剑
)HSLJMap =T �2�%x2 �*� )\*=8+<决赛.TFinals �l9 秦始皇陵("Py��，y�)*�IMPER"�+TOMB6 *$>p	 �*
(P)�	".�%	"-�D6Y2I��8�
PK n\)r
21  ROOM X  �2 心魔幻境+�
NDIFF�.A%]<
 �,*�	?�(9
T:�*�3 自拍L�景
)pSelfie(d(p 
L*�\���武招亲*�
BiWuZhaoQinPr"V(�R5P6�h <�25 花轿游城*�%DQTour(�-�0�2*�6 u%�#�21�-@)?�6�( *�7 求d���+�?�Engaged �+| \8 视角调整*X"�A#4�(L.�*�9�	拍照.$Photo�	
	)� 3\���飞
)x[4Fly3� 1 天牢*� PRISO)�9?�(� �	)�,(�e['�NI,~_2�		"R C�;�	) )�,DanceAC"�- 
��(��e{�};
*��ctReady��� � +P,�FAC#�B � +|55	,x_r3--#�M3D���队寻宝* KEY_QUEST_ r F�eT6�b'M		7y
}zbtbL{ngeS"�]ForceOp�3�F[)�Jn 1|S)<��9H\	$�ftbW/�f4d"��n�, tb"��	 in pairs(_t/� ) do
	0] [�`{}
	t
_, szP}	i�
t��9[�l	D	end
l %Zbtb,Tb *� �, �*P�5�L�AUTO_HIDE_FORBID$4efigh"8�"Mw;XN'�Ui:Is(��
	�8szL�"߽ = D
:GetClassDesc0�z)
"}me.nF`"�i"��0#d�"��")z..hPHr] %t�return ��2%� %��3*�Chec)���-L��0�'�x"{v	Ui$�.On�('D 	emNOTIFY_UI_'!,�helse
	@&<�-��`H� 	�'� pl -[�ChaHx�/�k(�0�)#�Ui::� ��_,p8g, b@��)
	H�/�", +=	lA�QuickUs��+�;
\$P-l--if*4qL2�L.l44 == 1)�A--LJif"��(U�@5�)(�	F--�2h`l�`�/`*� �\/� =*W
		`4(MainUi(*��$�}�Head�(pL$��xY�!lr+�
�0�Ui���, b܏Q<iP/��.5h*����9 �H���
	�gu.���nil@H��".%l�� @'�X0���TT�H^Ui�%�*)� -- $|�"<U$@1*P$\��*��bR+th��*�pM or 2` 2;  d��亡$�Sui��(和�#�R一样
Ʋtb"���'�a�"/�[1]yt0a 0�v�t�# 90691*;Can'�{}]-fhzUi,1J�i)���b"�!$��H6��\}i('���;UWthe�S,� `�d~Iif�/+� K�Ui]�W'd�!�]D  `'� 6p�> `"��	h*D�NUi�sH+%`�A-U��C�����x*�Hp' '��j#p�Window(�
q(	`���'h�	= "�$ @ b-
	�Cl+��i`�I �q 
#�&|-Hf�Ui�BLftb.��!m+:2�����wS �#x�Panel()

	%�@:OnD"`��'(�.bOn)��s̲加入� ��+ 7��[�H[Ui:ChL�Wide�OffsetHh?'� th�[Xi8W�3"�( "@���*�IsZ�htp
BoxPk(nMapTem�T,BossLX�er:Is(0 D.� W�
	 #Q1.-�pIM"x:4�  *ĝHTomb2|�0�'
>�'Onx�$�'��Finishp*�P<9� H]-� <� 
	H%��;P/LOnWorld%�!sz"�� nS\
erId, bIsRollZ)
pA'i  ]�0H0)� i1�xH9@E�DVTSystemrce5	TOpen�("+� , �nw	e$L+\-� ):d�DP�T �A�	PLk@-�+|@.�l#`��|C = �d�_, nId"H7$G7Cha"�.�T"�0v"{})��) L&x�	)���	breakP�� �.ot '� �re"X2L\@�\DEnH�%)�(X�\ xh�T�, ""�e0� �-�*
DropAward(nPo"D�x Y, tb�TD�(tbd#@== {}T�'tb�in%�=t�*�a` = Yer.�j[t�%8!"nil"`�pS)� '� �_\�_money �'ڠsz"�XMGp"=9Mpm('�)Q	�nObj"�: +� qd.� `NaD'�	t'P.tbUserDefMt2Y o�"�	�j2� , {'`�,GfTit#<�string.\/	mat("%s * %sT=�,L7h2[2])}�v>		dmP�(e/ XW�1��*iDz'�+p�x =T�AP�(h8da,X| �5t�>2], nCoun#�@�3]��� me.�MI`T/�
�nfo\`+�SetCompareTipsT\l��Z�|DUi("'= ")�)� �)D @
	tb'� .p#  L�angeYi# �"MainP4133, 234Ztb)=� -27Dy�2�dH et �-84�.�.On$� C|W�Ui,XT�Ui\�,"�+= U+s"5)
i{t"�0#�,�,(�O�\�,�(|`l +�OP�Task	(nTMID�nNpc� ��#+)�Dlt*selfi�C"(J("Situaj8al�uL�@y�nLookTo�NCtbLK?eck'b (n�IdTSp+� t$&A.L Z�w:)� ') IH'�y<	E�: �A	L&P%�#@^

�	'�1�, "aTH*�\Y �;$�+'�Ui:Tryh�l+*i('�, bIsOnce,@�CallBack, nL$+�)�0�.X/ <�
 -� hH5 L��&�h'qa"� C#��h[m�IX�8tE�DU[D�AL]P+P,+E o��@-m [']�r'tb�9'T ��'nfnhp�\	,@�(�!	j!
	@ Timer:Register(1, ($�t\Bre%�%�tbD*U[)�=#:	�&Sav��r�&h
a

 
�p�(��a{t'],.�1�Batch�gcene'<2@�T�"�#\P�rtIdxKEnd�sz'� �peeE�b$03"�<E�fE;iA>n/$S'Ui.T��#��'\+ .. ��'x *�"\-\4*�;
�2�+'HUi:On��+�,P�+�H0�5�-X 10@;/�SetF�/denF�raj�(b'N , "�C&��T�nb�I)t$��De(� �`*� &q2	)� = �e$�4*� �,� ��#�D.@�'�'\(�I/U��.>�U$
`z"E*��'�:D	� Up(]	}L"��.b/4�		me.StopDire#����	��.)Q('4����	t�p�+�%�`�P
\zNoti<�^$�k
DEN_OPERATIONLA'�h
F("'D '\@�(�#$"i9"mb"�"�Ex<MHIDE,�&��A70+\ CAM_AN@1 ---�d.@To|{$�n[��-U]H$߀Cha e�	)(w-��Tas/L�)K~Rol)��Hom%�J(a�	)Hx#�E",�*P R�tl5�"#`b��Top*��QYHLeT�#�.|"�~+D�) �DZ}
+-I0}Wnd)#�oif dl"�%.b`JAlllUi�m"$V%]) �X;��Xl��n$�9 �nl�T�1U

#<W_, szUi&�AD(M[�
])��Fsz_ ==�%�-�cm;
	�|� 
����lV= *4 \" D+�D�\ UiVis:�(b"�,, �)
̰t	Tu%=�#
x�`*��(	2� ��8� (5=�`�Ui.H-�
	 X,��+vUi3�`E.1��&�7&W;IsA_�ve($<)�	�t�IU`5Tn��		\�S�Ui)�	d-*),�)m�	�9� ��"-#s+���)�F>H�H 4|4/0,� = `H��9*�#IsTipsNeverlHPpcLH�gtbSplU� "��Str�p="�O"|"Bre"�+ �[#�]=="NEVER"0X6Check\�dx�
P	�b�\p("�]<��rX}nil
l,��)tb'� %�-Get(h2��li	�.�L�(L �t
	�z/� [szs*]
	�D�T	�,�4�Daily�x�X�|v�.nDated0-G ~= h5IL"(ZDay()'�-� 1� h*�Old'�'� �{{}
#<m�(Q=�N	eN	 D(�X)�(8P�'�	-��,,@P'h 'L�
�h.80
, value %0
�YCh"�NX>��
	�X� and 1l*}W
 Q   "t
if tb8�	 ~= vpJ0Btb/�
�B
\kbChangeHtrueDmX	q 
|D)��[s��/�8� �
		.�xt�thenX��:SaveUserInfo();
�j
f�O 9StartVoiceConflict()
	me.CenterMsg(XT("即时语音开启中，不能使用�聊天")Lend
*�.(�(fnCheck�@H4 not Sdk:IsPermissionGraVd(\ .ANDROID_PERMISSON_RECORD_AUDIO)�7H:RequestAndroid�	on E%	��D�l,Ui.n�$
EndDelayTimer�0���|$��败P$请稍后再试�#	�
�3
p` @bIni�2fg��#ver{"_tx� 	--除大陆版和新马L 其他D 	本讯飞返回的翻译暂T:置为空
HZAU*@KGSpeach`Xgnize(falseJ6	e\  � tc�n@B		Ui.,�= d)(*t and l#*Q ('�-�Mf�5CallBackTsnil

&�Q	ileIdHigh, f�LowMFOSerD,:CreatebIdUa
p3�O or IOS�/ Ui:SetMusicVolume(0|���$�L�T�"�v:ClosepRoomTmpM	\8":%.U(�topListen�l"�  nRc�0
	�bP|Apollo�S@`Mgr:�k't LLXH.� ن	���s)a(�%-�p�@�* H��8� n�B@�= 0�+	(.op�P�T
:OpenWindow("�zSrd"�D@�.b�ed�D#�L'�
��%*t,	"��輟�z�d��x`+�D��d�DQ"0[, bCancel@HD�@5
lNp^�-,�6�_�f4� = �v\_�T�stor. 
��F,4�A��- �R.N	= +4*
	`.� �+�*�	M�	'�Ui8�t0�1
p���@1)�= ��Q gnkr(� .VOICE_END_DELAY * Env.GAME_FPSL���( X78ynL�i))�AutoPW�Nex��@Y�6�Xa�E�ame)D
"您取消了�R输入�Rreturn*�dI�
x�H��R�T*00(� 
i
x++�S'nge�\Omte(�D$H:�tb��vNsUi-%
�E,� �D+T \w"&�	,D �� .�:O�C
2TxtResult(szLD=E�I.��PatX�voicexH���.��T (� ==)t,D�8发送�-�H!2� �� 	28P0MW;XVP��$,��tI�lA�(6� �v6p �5l\�&ľItem(nt 
Id, szBtnName��t���0H���Visible("*-h�P*+� , =�@K��xV+� ):$��P3�x t.l 
--nManualH�
ete为1时可$-Ui.$� .Stop�(@�sId)删除*�:l�+� EXM YM ZA$RLerPos\*��%b'x )�	.d���#�nXq�0M
Y�Z�p*��` %�+a'n`�HLl��	��	\�dor nY+�n]n�DGHgGetWorldPP�		nZ]0'|( d-�\�+L�L'+�2�-$Te.<*�L+,�31�)X%�  	 NpcSond(n#v)IDXL)�lCurnId�9y:dIDialogue��v'� , 500p4d��n'p T*�P+�
d*,@�Pl/�
#�u�'� 
"  �?�ID|.��-8T+�&��x2�;/��!1� DADura"@wY)n�h', ER1@ .�p+=D�/P5 \�@tb�#S��[�*]�BL�#2|&TI��B6� X:&�%.�p5 T%pAl +�h&4�  
 �?� X��".�!"�D.sz\_h�#�'+�*���l6� �6�rUI�:-� '�/t�UE=n(dScal"�K2T ic0H�l+`*� 1` *� ���*� /X �,F	et-�L%`Ty@@|-| h�Tl%@#0�^en���HHM5l#1>t"3r@mG�Ui:H�y5edting#�MUi.���T�%�@'
.f)�5 *  (D\,/ 100.02pM" B0�'! @ �!0� .8M '�pa\
#�32�  \ \p
@.h� t���4=�.<	2x.�  
p0�  )jUI0P���@G�F��/\5�OAar�()T
��	� ��E*�YT^)z(f�	, b"�Z)
5H*��T?d54�E��@
�&��)�hm�Pg���l%N'�8�'� ,�= �;�h'l /��0�>�'����.���d1\*p 
4� +����8L.�:�
howComboKillC@)t(nC}ClX(NotHide�Q]U.`�"Home$�Battle"� +D9`'@�+dR3� , nil� C')�"L]�	��WndUi[Ui(5�"9-b�)�
	tb�$�2{Ani*��&�"?� ,  �
.nS�+"8@'#nd
�?xXl $�DefDra�! =�nHe = "d-nMiddl"�!2A�n"P^\ = 3;	Ui.n$#5FPSD,< or 0;,�6D�'� (nT\'�x+(�PD?#T%'� �(&�]t �I X'� .n)�= "�4.tb*-.� "\Nx&�L_�n
	`
"l^nderHI6H�$B0� 3'� &��lCG&bOn|�dXeryMode�+B15L!�7lTH*� ="b��|'� #FG
	H.VSyncP"�@�, "�9#�3)eL,�45�71"U2	Hn'�Det'�6t$�X/m1 m3(o
		5 (8�t)�lT)��.4�`}
h(D?(0 @4Log("D'�
",)\P�*$`J'<
"�2|Q"�('#�*�"�DFUi3t+|>�Maxx�NpcCt�)!nH$`,�H'� (HMapFD�\Upat"{Res����ShaLaLevel`l	�!(,�X!2@5`+\&�p'8% s�Low�T"�iX4�)'�Hh&-D@U0�P'-,X���'�q��	.<#hX|%d �Q �H� @Թ @Y�
h�,��pa�f$��@M�-�=("FTݚ/P	racterColour"�rXHA5x $5�X#�d�� ��	, 5��TO��`0��CaJ�adT\�c ��{nMin = 0, 	nMax�n� 2}\8�1(� 8, '� 30*� 9(� 1L'� 4+� 2\�2*� 5+� 3(� 9� )�10i},(�s(�"eH�#� unt$�>d�%<!L��re+$k�g�%t��"(� E#fLT_, tb"�& @)pairs"�/t"zjLo(�) do
%�iv.nc/<= (@$��(�P�LD3�S)�D�-�H4��t@&��\�B� #�$Ui)D0%1xϜG*lP\Dt\b�(n@�,&�5ĕ"pW�XJ'� \D�(h >= 3'$~(X = 66H�d�+�@,CuXpX9@�D '5`)P,(d)�%Hf-,'PTaLX�"Ui 0(\�x�&, *� � --不限制模型加载数�|�Nx^Map �|[104 �1,
	p�I �3] ='1 4*1 5*1 6)1 5*2 47*d �3XD)|pFpTemplR�Id)@4\�)� U[H")� %xY`)>/256�.�����'\5�B{10%�3Ui6X"�!�Hʌ4*�#����Usd�S"L*Pq�m%p,���$$���
l�pXnL6me.GetL&d"D^p	���h%�,98g�PerE�m"��DD.$d��(l
l�)��tp",RTP%2tRpD'� *�!~=4�2Low��p#�!,�%�!t'��'`)� %�Y*hPH2H]�('�	e(m18$�%+��h#Um 474-�@ 0 �+�+ �))pT�>)<@�6�=>�	1��&��,�(�-�DT�bRetc":= D1P�mD'� (self,�224L�A'E0� �2Xx�) X�$_��h	H�0| ^,{}��Otb"�Da#��Lib:~
Ta�#�6u
/0 .tab@�{IsFo1, p�,�1}�U� 1�#(�#d#x!"@-xIsEmptyStr(%0"'H2%,��	�*�B7 �$$18� tonumbe1��X1�7�[�Typ�u%l'�'��/Def",'d3�)030T ��;DQ|�(
t" Gi.�1�P(�.15;$|Ld3"��D3L�HKTW(�1		<��h`'| <�
["-1 ]'�կU87DeviceP)Y
 $�""iPhone�8A�[Bod�7�a�X@%+�ZX�,Pp%.8�J;OS+� <#�2'�
 x�Hs,LM$�9\x#seszD�, nV$�(d0�N�,�)"�0l%�,LnH "(�\	#T��
Y�tgind�, �.."(%d),p "�9�XJ)= (y		*Z = ')X ԁ#3)[  >=(�)@&�!.��V���`J`| l .T)�+Hl|��D�X2)� Ī)�Ui��0� &�$�p
�{tD>�60� &�ŤHKnfo)����'�\X?�hp�X;$0��	x)�T-� �8L�w�uE�c"��l�$+eaM%�L��T5�$-��* �$3!tl� �)�tbLD9{[999$�2 [%D4@%�3F00��1}��bx�T%�)��
[a.8t2�$�"t3*�d'$y'H�=H3�- 'TbUi'�>how"S��sxl +Clear-D:'�+'<�*�Y3� @�`l +�TV$� �o%H-�(t)�%��]U&��"+� ", -"�]t'� .f2<nP�pH2~ or"�g-)lxP:* *d ��=���#$cF�il*�tt�)�D#|�l�dt� *�3Xp@)o Max�!#@#��@�)� ��'I	-aU#�\��l'�Z��,�x�#�]e'�7x�L�( )`	�!:8(T)�l�#�TQ"t-�),�)�J4�-d3�-� =[;Def)�.�$?�.�t(�1��-d��'� 1�EbD#� �6
"�&xCy4.*�l�uP1WINDOW'��$L�,� = "$��s"Tw$
-		4� �U'`�.L�nd$��
�͐+�1x�Ȕx\u"d27�U�X�`'� �*HD)�)�g*X��V��$D_*� )X $�P�P*�w�All���&p9�Q[0P#@2��4�"�yh*�:X�.`�1.OnAniComma"psQT�, sz'R )
rtb*� Vtb�L��"�8S#�(Y"�elfUU"�.* ; "."����fnExc@loads�	P�(`HpW��u		xpcall(�, Lib�qStackxt#l +SAdd(l�szMsg, bSys�n�"�6L�z'� U"%�"@XNotice",81[T'ente"�� mT�eY:�e&d�+� lj��)h�,� 
#�+��P@$X�"�&"#�_.l $;"�H��Y7eYn
X�PB/to��
\�#EKh+CutUtf8�, �H!oLen�#��	Mc.tb',@L\$�d�/�me."��, ,1eLTQf/fyPW�(U�CENTER_MSGL@t+�Fetch'0"y�<"��N.�t $(0'� B"{}'��1lr|BlDQ)D�?�@�=��+L�TaskdQO,�).�P#AniEndOzWndTyhH�t"D�P'� �/�:��~sz�dpo�.UI_NAME�'Onrfy1XANIMATION_FINISH"�k��	�H.`l +�\zrtProcess�M, nIrmva%L�)�"NpcS[�p",�%,)� 1�#$��D%�Bb�t9\>\-((�)"��"�) �
 BREAK_GENERALPROCESS, *�r@Ui$����()�1@BubbleTalk(npc,@�0ent)l�HMaxC"�aHDealy#��
e<n'< ��)9 >(��yr(�)� .��shg+\� @ xd %< �B��tbP
"\)L2"�Rh��T�0"-�'� $�6Xg
lseT�,� ��'�'� @�\��'�gl�"�Fi@ed(tF'#,F&0�"�7I
KP"�eById(nRId�T���x"��6�3�> (X �	breakY	��		i	.)hM�oXftB'�'��k�			'h�+"�3	�
eH l ,�|On$��RecordStart"�tLiYn#��= 1�L�'F("� �"hI$()+�*t�#�m	-��*  Failed!` ��*4&DoLeftpI$8)(...MU��9L QYHLEFT_INFO_UPDATE, x1tOnHelpC�aedX�"�$�<-,�GeneraltPanel����.*�SwiX�-T�(bForce��Aslp1�=X5t XGP6) �65� LY#t:�D"�5��t&h3\[Get/.l[6P�ZUi.nLast"\>,�7gSet)�7
#�A,�@�GBr"��nx�H
SCREEN_BRIGH_LOWI%	'�)D�.t"�9'�.nLowL$�PT	 �NORMAL�@%tV�)d9Dd#28=�)+l7@�`/91or0<;(PadHf@�%�z' "�S
\��.9� CHANGE_SAVE_BATTERY_MODE)
07how@oqq(#�3P2i .�'l @#�\�FT�7� 0�et��szx , fXM YM WxD\ $��HHa'�<�'� �bre0���\O'� @�"!F0T#��`�t1024@�c768T;/On�FromUnityLFunc, d�'|*%�Q/� "f5UiNti"��
#�)X\'L P,l/�oUi/|%�o"sd", "|�"�o�"�Btn��""�o�XVl'��H*AO|�urnP��\�P/��szTop��hMU*@A*l l
p�-�p,)�78SLXpV\�\�t{H?�L"p7�%"�^),%�		6(,�$ $*�.=.*�'P)|'l $P�"��"M*AY�sX!"$Ui\�\�`Logway@ !-1;
-- 7 帧内获得同样来源的奖励就合并+�-Merged
�Tips(tb�, T�gWay, b"��'T71~T�HP�/@+next&��,@'xH�# �DFr�tb,� �*��d@LHG$!L-,� T"y%	���-� H�$�=	$u'v"]'i$A�t� )"�m	3�;,�, vHh8tS'=n#4-�,�d,�$�O3� #7, '�� � �+�&�Ot-tH)�-�-��5Un�`�%x%+8
`M#8�xPp=#�,sXp%"L�AllUiS��'p \�.xL�|;"itI#�.'�)�|<`�l l*�dP+5On�"�f��tl +$h�'�et\(���&:xP+��/dP�fifyGT	x�(�bHtL6i	U"�2LogReazon@\qx�O��t�\Deh�`��
D#2(nmeH�&z3szHq}=tb�Vc[|j�]
Po(� }I(���)#�3""`�$�J.P5
mat("（%s）D�'� ;
T
@$|�Dhv+�L�v%�%#�IYT"#,[~ftbP.szEmo"�rQc�2\ H�P%�*`P,P	-���%s%sP1M�z�$�('D]'tN <|/"nd@",�4s$�S�Gؠ��#z#Ui�@s\�+t�B,���8PGhPl g�将�� ��画Ui和系统提示逻辑分开+@"�F��Ui(X	(�@WpT+BUi�&\D�d��+�-�X[h���+}SH"�@2�X@1�*T3� @_L 
��]�t`P9�
��^XM�'t.�@ 6�(�\1X-�tx,��xdQ  }}"\9�)@ � *�or +;Rme(�YI5eLdl *8
.OnHotKey(nP Pjotkey:-d 1� #;�AnyD2� 0x .OIOS%��Stat�3nge(n�R[IsLOrgingLD�("On3� H(2� Y U �CON'�6�Q$<7+ &�*1K1!b2 7� P'�J*� p� *1;0�O"��L�PackRetQ�-|�,i "X0upl?MessageBoxX "用户端出现异常请重新安装\{{},},{"确认"}D-'��true);
end  ? 