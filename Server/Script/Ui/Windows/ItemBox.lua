
local tbItemBox @ = Ui:CreateClass("�");� RepresentSetting = luanet.import_type(".� `'�.tbPlaySt_AniK
{
X [1] =��lnNextFrame_50;�'` �A2(\ tbEv\�	d(0�"p\	", "shuiniaolfly01@0.1, k .0}(X+� QueuedL+ Take 0(2X+�	X �[21�Random�10.��9/d �!3(� ,�4G{{")J40X0}, {"st�45D�)� 2+� 2M$5l)<� 3Y4y%}\�/.|D%|.l �X �'31�*�27~-1 �4i"pEp�\ 5�loc�mTogglXXU]	LNoCountWW0,
�rmA=PO�LEquipF2,�Partner�3'c AllA4�--PHorsX 5,
}
�w
ITEM_PER_LINE|�{MIN�5;
--�nMhsAttribNumDT'x tbNotMainT�--{Tc6[tb�.X �E6 N/--,7TYPDP"�d�.PARTNER]E=H�@T|*� , -- 同伴装备
	[�EQUIP_WAIYIh*�.\--� _WEAPON 	� HORSE7� A .�HEAD � BACK � �:JUE_YAO7� ,�CLASS_'�	StoneE{*��L}I%e�P0u ,+rNo|Weh�O � _ �ZhenY@�@S �;
	--waiy`�+� �C`UnidS�ify 	`F%CoP�seMeteri�y"CheckCoposeable"T�+=� MysLL�:`Taskd^lTpNEmptyl��)` QuickBuyFromMS)` JueYaoML��-L�:2 	SORT\�
{
	XiuLianZhuDL|hBeautyPageantPaperL��+o VotpO��CollectAndRobClue"s"= 4���XinDZok@
X�p*I 6�TeacherStuh9l"X7;--师徒信物��	WeddingWelco#�!8;L�	婚礼请柬�MarJ$ge�9; �书�(�Script�1��SNUgD[$Key��%Q0xd�1�$MibenBo��#DM]pH�X"-dHANGE_h3_FUN1L$�#.�	function (dwTemplG@Id)�g*if �Y.Entity�:�ZIsCan�(me, + tH'$t	return H�& ��合成材料对应sort@'� end�^ ;
(������P8�pt-)
		��Ret��-tGetBagSM(�.+`L�nR
	L��+ (h�)�)-�.nLevel�'*� -� $'d	�IKEY�-y).��EX,		@� 未鉴定��)� ��,e  Df 武器�)� ARMOR�t衣服.� RING�t戒指.� NECKLACE�-- 项链.� AMULET� �	��身笴y)hBOOTS�`鞋子.;BEL�	�	腰�/,HELM�	l	头盔.,CUFF*� �J��.� PENDANT,	h+Xf��.� ZHEN_YUAN`
T真元(� �jSCRIPD	�9��通脚本道具(� %k&,		d+�%}&�)�rKtE  {}
for nIdx, nType in ipairs('X	) do
	�[�"(#{ + #4Hd�tbChangeTabPanel�Rh ["BtnRoX�t#�7erDetail"�$8+ute"�'8 '� t�*�:OnClX�'��L�(dself(�tE�a)�('q)�F,
�+\	' P'� "�=| +gClo#06�"�?hWindow(d.UI_NAME��	{
Tog$�')��, szName�ht:Updp�temList(*p)�-� Sed�PageShd�
)�dP�� !� * 2 !$*4 @$�7�< TP ��WEnhance�Q)E �)
		\LOpen�L"�/Star�Tips", "�+$x>HdInset� ��+x�det@�1h|� -d��3<��9<-8Title�PaX�3PFash"�&= �=�,d.�W"�3Preview")�'4$h?5x	if GetTime#�I#rI("`8#�"89") == 1(�'/�#�?+$"�$-eridian5l-�JingMai+\�X�,�Drag'�d�|5/�,L�Wnd, nXM Y�$}sB�.p�:NpcVI(_�3Dir("�
QV-ktruܟ�%D� h �D�xL =�'L+�;��L!'x'S:On|7(szPage"�.Hightlp "�#,D!d�Ani.< Atlas�#�dwut�|H.H ���szt�LL-@ or "iK�1_"�D1� �4� UI/�/aGLJ'  .prefab"��
�:SetActive("texiaotM zX�"Xfals�9self�A7� "0P � _TWH7�(�0[BtnݡA#NVme%�0 >Uo5)83� ��4� 27)�"l#}Rb�khDL,�:#�7o(me%�"5=M�yP*,*� s�OT�l>\�$0 %�&u:#�"RoleAnin�r():�p&�'(d.szCurTagPaE� `P'dX�s((
)\""@*+h5�"[�Page])'��	��+�"�XerExpl.� TitleInfopQ~ hH"�HanUpgradel(� �"N�UiY"S"�d|�.0 )xc�M(.n@rtExecuteTimer\2� :Regi"�I(1H�p_�(��, 1/,�FnW/()
R�

1%U#d(,� 9�KU�"FlagX:��&�RedPointtU�2�2$�,Y�sgnUi\#�#t*8C�$��O+� �T'0+p G,nil�0�#x.�$Hf�(p`�:1�)� 6�)� <T-T=�/� //� .�!1�/�	(sVte)�5|4�!/H���tbYt"|Q|-�q[�	]�2@1not �+�r#�J��`2�
;�)�fN�_,Tl~ in i$<�D#�r)"(<pl �fn�!\&j["�On".\c
[1]�|D(� +tLib:CallBack({'� ,��, unpbtb|
, 2)}�-hh� �,Et�,.)�v> 0 +��n�P#@)LMath�('��A&0/0	+^= �bR��'(*p+ *�,�.�(U' �x3�E���`l 20�	On|�D�(szWnd"<<U
t@, fCrossFD� , nWrapMode, fSpeed�d;�Lmation_h
 =;7�.�$ { ��?8� T ��Cp"H$*�tbP�LL*)��+, nIndex)����	�H@R'l�U�](� % (#�)"\J�S�D#0�^ llI[��r�nC"<uH
+�r3]+1nl\R	ni"��* ���8�-PP1], *�	2X�N),4@qr(8 �,+O�k�2�T (D�!,+.d6mO#�2End()�Ȯ$Xx_Set#�*ed(�"s#�)Hy"@6(�:S,uI"X%�)�/u:"Z7Ex$�,#�;@6p$�'TabPanel(s"*Btn, bFirst�D�tʨ,THl-�*== '�P,� d��� 'T:lose((D:^--pl else;�$@"�(� nse(�3-�(:Tll `%� (��"Ta%j.= �\$�3~�szY,@�) R�paD(X�,�)*pp~ ~(H�h� *	S'�7sLDJ6, *X,ieT%�pl =� )�t/ qeQ(slC(=6�*��.Open)t, me.nFact@�)�i:�%Feature(T�:eX;(5l
��,8/�?��jute�M|%l �'p $^&�B@hx*l 2��Can%m0(�nl#N;tb#h6\�K&Get�s(�
�Strengthen'� (H �xT"ǀ0, "�A.#�kPOS_MAIN_NUM  - 1*|
�b(hT�M'|	�n~	IdT�[i].� ����fp"\9�l'� l,���:T� �%��&dm n�����[iz�] "�'and tb0l or n&�3t	`7| l �=ԗ(5"�#\7 .. i,  )(t*� Labelt�Text\c'�"�*- j"+�*\ F""���3)@!|4.Gold�(:IslŜ`�RJ�me�	*�4�10".�t2�`.P"�m 更新强化、镶嵌额外属性�B�#�l\�P�H�tbLast/�HClient:GetUserI"�B"3� �'if me.nEnhExIdx t*�<�(�(�h���(*�*.�L,�P�p`+tostring,(4,ButtonlISprite(`�E
a'DcF
tb�.Img)
�+pL
Ui.UiManager.R%To�\"0()"�\seQ�U$Tm�P(4\�V _�tbL2%.'� +@vbC�:true'Ph?3= t'L��Bxl ��:T,�T$Sy)+�*� "](U"�5$<3 ("Role&Bagpannle_qianghua\+�R,��#��h&/�'texi)�V'%�'A"a:zXLaH�Scale('@(`')"}(�en%��T�'q.��_@��+(C "0�^�	LAeWI"�j oneMgr|_���V�Di(�9|��IHuet*I'Y)4<3��
D
(� -#�?)�  #$)8*,(Y ;(� �92?8)5ILD AI`J�CIP	XC,H�'Pb��+�C��Save't%h&|il 60�s�|sz( �Z-�:1N�un#�, ( ... ��:[*]�/�Pance(�T-�}(��*�T�2��:� 1� � tB��*
3X,x<szBtn|ׯ-- ",$��, n"�d in p%�6T#m�)&�+Xx+D?"�;-��[�] '0�dd&@2`'()��/L"�rT/'���zl�0 @+,T�,,`'`Hhl 2U#bcTi'lg��rIer�:T��(, "�"�6\OnClose(�1\*self �@���&7�	+�@}eL�;x+�8dl 9�#�,"|xl�`q:�Rol+�o�&({ All#!S&�k��nT"�j%�;(P	d���-.+� �<`l,s  = '3dl 3�$�%�<E"�o�&�fKPerV	me"d(X() /"�,Get"�Z�ޘ$�%--��5ProgressBar""Value("Ex"m+p\V�H�1e�R#�2(�G&.�(dquips(1K		sePKG�how�{}�t�<<-2<tb�	"d~D~["�"..)�;)� .n�PosAi�h5*� sz"N6Op"8�%���"�0.� fLh#� *Default#��(�PKV= }.'�?RING%�.�[i)x%��#|�YK�@=| Obj(�\�1�L�"x:�gEStr�=1) '��	�p)H�Fragment$�2T"MarriedY k%P}:� Atlan,"U&�New�/#9N/X�&$�(�	eT�'�	>`'@ 8,� e%�.d*, )(d�|,/�",��@/.�"(C,~se,�[(� "��t*�5�| �!(sipt��D2d
(�p(L	$ ь@A�2� �@#��x�+�1� ;
�3'� 8�	h%XU|�#n��7ڗ		�>'d(�'"()"P�Open&���"�J") \&}e~H		64+�,�		H-�/$1V])-� .Į\�&�&"d�L�`>T�+,7� faDp\V�;0`�tbZh$�Py`%'�) ==P�+t
hI1�Vitality'�`el (<
X�� = |6H
'��(R7h
(� �Sl� tb���9�
'(lp. 8�
t� -� =4'�DB�| -.(l.d ,@
l� .� 7��L��M�|  �Nll hc� PQ�Ppd?<	)d

--��`T}#X�=	$��%P�7���GT|*�9��;]	�LhvjOp0L \,� (H9��
Preview��.$=�	�XK.� 1+�\�A\ ,�7	�7@`7l 2�2H�Filterd%Func( fn(F  )�E�D+] =+� 7��$�)l"�8()4$(�List"�!{}�"D)_, nq 8H9hC�)[�r�{}���h��n&�}%޴�^Wme"�%dlInBag()�	tnIdx, #D&ai&�;a)&�;pX["�;�+�or��P�(y(�
) +Xt��L#T�"��[�.ntl$%@�dl �szC�\���xl �tbtD�$$ݜ�3}n"D�,� "��[��9ll X!�HAN*,�'� 0�x,�6� �'.d*�� \,�,�pA`� ��Para"4��L"8�|"��(�"<.:� �)u0+ �tbDataP&{ nKey1D�|�KEY/pp1000,�2L�:nDetail�7* d0 + �	��3'� GetSingleV#�8)\bHId'� dwId, d))j Te&D�",��(| P;�T~= ,DϬm/Xqt"��.insert$$>�pyns� All] ,Dl'�qd� 'D�+L�| p>+0@TPype) == "�"4
d]�i+�|.) do+dxl �	7vi]98th� |�2�string"#�2selfl&U]4�OD�L�"�� =���/��$By#D}H(� �6,�����| 7��	Vs{}7�Xd""�te#��s"�6t*�px*  �x.��+`elseL�]h�self+��5<��,4�e@+$x<<H7# V�$P�6�	Hx	'|\�| ��%�!#�R_SetTe"�}Xl��|", �R.X?mat("%d / %X�s, GameP� .MAX_COUNT_IN_BAGP�l	"�kEx"���
(me))�L--d%��#�8|`�h��'�&��Box�'� �,�	v	.n"tplyX[� LS,d ��@?��vs[�'-��(� \-D /� �-�`20 ��按类型升序，小.F ��X	价值量降D�	�xfn��'x(tbA,MMB�!x\Q.��=p�t*�	)� L�(� 24�)� H�(� 34� er#d�BA.#�#Id <UB��`� h&�		*� Key3 >�l'� 	*� l-� 2�U2'� *� -� 1)� 1�p��u4��)�, �3)
��CdR|UEF{L�t'e	�9D9l"�O,\�'P�(� nStar"�3(inX - 1) * ##��hJw iB1,,� .��t�0Zse+![�+ i4�(hX:xAh�ذ	�<�nhl �x#p##�0be%T<$true$�0xl �sz-��ni�hl 2� #�ST.� LY�d.��',/g == �4*�d)�%)4 /��,T '�`l ,x �1� �+� tUh� �1|-'+;i, �q@il, 58,Dlh�3, ,.< �- 'H+�58�L`>aF[�"�7)�Getz(i-t*p�| � �#ScrollView��( H�h.max(math.ceil(#��f� /,�), M�,HL{�u);t*\�至少显示5行7�<#�%� %Y1
'�EBag\S{}
	&T$�01�			t*F.tbI,X:$w(!);�
��	s&�9= $g)#"�9 h#PP(d'hL7�OnSyncqA(�A, b$�AAll)��5bStop�tOnce���d4L)( Iw1�ll x	�C|"� (Thl -x `D5x ��els(��Jse��0�'�tb/p ��t�!,��T�/� '��, {�)i)�ep|f| l ,��(d,� t�'�(0D���`a(�;9'Del`2�A���>p*�-h *�)h �8��BaseA#0��@}��pNpc = m#LIM(�E'� nMin, nMax'� t	Damage(�RseDB7 .Lack", to$�-(`
'�, <� MH"�x'� q.dLifeT�?&�zn",!Lx ]r$��cTotalo(me'�� �#D{X�)|0Umt�floor(�N�2)'9��3p"(2@	��TmI
��BoxP^%w�Sca�E {0.9|I�F1�J@� (\ ��J.15} X0贴图缩放比例2+UOnT"�$�%��9�e��,�� %|�`tl �8�1tbWPResLEbEffectP]2m�T[Inf' �n�IDxesX*� ()"�T�(U/	�Etb0�6X-0.7, 0.8r 7}"�1p'�-�B,d��f�;,y [@&|�] or 1�"--print("'�:+�&|�^6tb'�x�(9 [Q#.L H"� Def.npc_part_body] > 0,�fEntId, nDId i(䔶	) -lI�1Cur�=��`=l H� \�D	7lIFt*l7`m n)�%�\xl �j`� �1̓X"%_�(`E((@�PqIt�TE�	| 'Hp�Role`{:� +@=`'�/l<�5 JId)`gels(X=`@'X TD4I0-4'�=�X
  � ,d#n se(HT�Fh>L, @FID�u+
$4�-�	Set�+� ��L� Pc�bLoadpKD,dy:"�wAniS�ionh�pp~ --+P�]�Modelf�urlW�, , )
70#�	',,�Clear� �pj.b+F�il$�=h+� I��	--头部和�0@ 资源可能多次加载BUG临时处理��,�= ��R&�@��2y,�9)7NOn&�1sB\	\A�Pb/j1= "&B;
"\6'pn(� � ��	�X/q =.�Env.GAME_FPS * ($-X�#lK�:&�H (�),End()
�2$#�x��'/���:Close$�K.� P�.`  = ndP��:(}(�oHw9%t&`7� 3sel@�-���! 
Auto�)�PUi� %\��U$���'#.tb#�3�yYeP>�k"W�."�C1�S3L��(s&���t�� ~=�].�)PJ$�,0M['9]��b*"@$�szT� J�bC*2= �fd�l }	:-,0�Ui.UiMa6��.��Utm r#�Y�6dLh�u�E ��f�St\�ńŀ
b	.n��S�L��-�h�"ln+"st", Tyd$�H1l"��,�sz\
�A ��dXp��Hp$xI�h~St�+d�:C)<)� �d	�6�l2�)l#��`D)�-GetpLp)�*� P�h.ma%`O%�9thA�E)�), 2����Ljr:'��m,�lu
S*��/D|6yrH
���#40"�#5,��?�(	tbSkillIniSe"=`F"�ĈP�� ��T�n#j?ID]#+� KAct�ID�DC'� <= -�3�m %<1�p�#l�P,�n�Min���Max�9� �-  `d'T.�6�SMat�"�D�) + �.�DVInde" H*\�.�E�V!Idq&=-�tbH�1[n�
%�e��D�InfoONpc"�uX D�(nMI",3�oP!(�(�
t*�8�V/�'� �h2)=��x'XT"�$+�+��H�A'� �"�JMm&5C(��
� ,l!�;@
a.D�X#H%�(�t`P� I_2$�'hl *-7. 2`L�+(`�+ ',��.d�|-+��,TDTHq>.H%@Ԙ&1����	�(��X(�S A�+�p�,L� '�	6BOn#�#esFinish-9s2�# 	0�#��Dir("#,�"<E�2��*�else�"3�`6%�epMl self4�tl f.b�oleRe"<u"|!(\8L"04Data(sz"P](�� == %��$�Xute-x;86� '�'� Detail:Pٔ�}|l� l2�V+p)�5�;�#Cl)�== ni%�<u:+� (�e.4T+6Regi\E*���tbL�  � 			{ UiNotify.emNOTIFY_SYNC_"/,		#5.On`4"�c },
	3� DEL.� Del<� C$��PLAYER_EXP,��!}�ehK7��FEATURE,	*� Feature�7 UPDATE_TITL'� U,t�7� STRENGTHEN_RESULT,�xM7� INSET� '� � Y*�S_BEGIN, �(�$\AȖdW7�J A,d� self�>p`=LOADp_FINISH����e��,#�*R			. -<END,07EndP�  .�VHOW_DIALO���.Aut$P==WND_CLOSE@��*4<=JINGMAI_y*_�T,�	��L4QnBtnE

#�$};� r#$9P��v;
end
  Po  