 local tbUi = Ui:CreateClass("ChatLargePanel");
�Item7� Msg|�(� U	nX\{
	TtMgr.n@xMail,)\ �Type.SysX6t Public6t Nearby6w Kin6h Team6l Friend6t PrivP(Y}F&
� �2Name� [L/] � = "信箱"M		'� Ld&)hDL系统8� �%�世界8� �&�附近8� P(@LL帮派8� t*�L队伍8� �,TL好友8� �.]\*"密聊8� CrossX
l主播,� �R�t5P'名字4� BlackList@w黑z��x�Afunction�n:RegTerEvent()\_�lD� =Pbf	{\s Notify.emNOTIFY_CHAT_NEW_MSG, self.NewADtNp }xF-� o�hPRIVATE,� �6� )�DEL_��OnDel�0< �d_NUMwNGE�UpdPg�s_Num3 �� |MAIL+i�s<� SYNC_`_DATA�Show�9�MAP_LEAV�Close2��VOICE_PLAY_START�	OnVoiceStart � END,� End8� DYN�+NL5DE(�I5y�\REng9�@T_CROSS_HOS(��hInfo�9UPP+E_RECALL_LI'HU�<X<9�NPC)�*Npc�(T �Ui.�SHOWx T_INPU( x<LtInput�*�)�tTnretur`u�qW�end(@�(MaxCountJ~11R
,�OnOpen(�Id, n�hszParL� bAutoSelec�x��zp��:SetActive("Btn�N"D	 ot ((InDifferBattle.bH@�H!ofy and -� nMNtT�= 1) or QunYingHui�::IsChoosJFaLon()) @Z"if��'�Id == d)*<'( thenY	"�!+�  nilU%	�*2� T
h�HL. H\��\ |��X�t
�'tb�H3{unpY�('M )�=	--添加动态H�天频道Xloca"�$Dynamic�	Idsd
b	f\)h'xlc in pairs(@�tb,$) doX	tab\6insertH,� X@=HrId"!&	"%x#9![( i�t�o.szl�l"�-�so@D91�'�
(a, bV>		�aa < bXA	 |li,v in i�t-Ids3�,{, v�\
yk	LL�nNo���e'1	 EnD_L"�*Recent��g�[1]|Z:| .dwID ~=��7�	5} =�W�X� y:*dXup�C'-- �M$�!�L ，需求为放到所有�最后LHversion_tx�zlPntu"L#HostHtB��)'�+t	j.t�D,'���h��.H(�	  �*L.�(0.�@x:HasY ((T�*
MemberCareer(�	(p Basep^x-�2@'@�D|  Decorate:TryCheckValid�xw)Ask�x)�����djPrefix�Uke��'�z�:O��\� �,Ls��|lH?typeB�Ui))0"nua""�Bp)�  >='ynD}LtCBegin�*t-�[-1](9	b+H�@�,`�H$�1D#' �@h��:Init(l�8L.'�q.(� S(�(.� x%�1	p�FHx�p`)h #�'Num�<)` ��%*�HIP���/Add"D3Link"+�:)d �	else-� stEmo"800.L$ MuOX�ick.@k+And`�'(� +�� @�Switch@
p /	`"D'H", "�$�!^t('� , �!(�``h�d��Stranger�h 	 --每次重新登录第一P打开�� 会检查陌生人的状态信息
�.�#d$�zT~.n�HistoryNewMsgTimer'��:�<� �U�K9Y=�È�lU�s"\6"oDObjVfni# $�Cur" )"�E\p&Q)0d4�d,�gdBose(x�
�utbTouchR#�*"�F
"�8[#0GSmall"#� ruet
["Dreamland#�)-p QYHCh"�2/s }
.�+Cx�Scree�UForbȫ@1 �)'4%�!tPHX�&"fa]h6�)�(sz�!Ui`T@�(-y['� (p�p#��:6x-�'�"5MlH4Window(�UI_NAME)�,�
�P` � &t*	SpecialColorL�HK�>9+�10,9 1)8 "$+.<�fHNt�T
�j�t&� 2X�Y{�	�bl�OnlineLHs�:Is(X �W	#�(G1, &< l`#15d#\,�	�IdP,[i]l5"�()� the#�1�tn�m[#�4hax" .. ��sz_nelh�TpT/�-�-�~=(��Mail'�		b�.%D7 Label_SetText("TxtLight"l�}e�uE	@ >� Dark1� @RPVXtb-�H')hl*�"�8)D)�'hH"e�.#�$* �"#|XHH  h � �)2\!"直播中 � � Buttont8Sprite("M>n`Pc"(2yS�tNorH�M1�:	-� 52 #4PressI3p	�F	�b[}eckPa,��GetCh\�y	� ,� S�#1��|Mds-�� or 1p �)'�e�Ð-\5��< \7� �"Pz��",+��,  '  �,,  g��.��(�"�5h=��		� �W�O*� (0 ��f�.tLO����[(� p�\�
�ķX;*,N*2, "�"�'<
 � #|#���� 4New�� m(X�(("�4L�" .\ |��$�8�+	\{ � N#0o 
� $�p2� 9`<�th%!- )�H/\�)�	|=,�5H �h�)�)� +�r#<q>� �	$�6"�"�( $-%bXH�D�2tMsg\a3[�^)A]#�@lZdr�Eb	@ �0HD@#`�Y	8lbONum\���^		� � � .*a(dwSRer"�,|m%�?�!'?P"E4t.C0�&�|(� d
.nNo,?R== � �-d�Q*t|�$�+�C9�\p0�cr�>,X"4>)�S�P7@4+HnD$RoleIdd$P `0HpR4d ��+T0= %h;#�;�!�*HtBtn�"*x @l�P48T$\2�	*X�[n"�o'4:GetUnRead�&�M�&��Xp4Pb�t.PD�e\ d*u]D*�?(0�] --P	X2��	�J+T & 150\�'"H/"�O���	$�;�\ @�'> 0'p(� 7�|�xI�|l1� )�9� -�&)� math.min(h, 99)LP`��%8�
t຾5tb�BH5\:�;�x�Cache[�B.�a?	x'en"7�)'	�#�1�@�D�'l � )p>�  Y#��+		̯� h�|-�-5����P�P� .��xMail"|~,0t(�>0�&u3M-��p1Wot @��>,�%H3`IH?l��rL�t#�M�d
p�-Dp@ ((1� 2�0�  �`'�)�>� �IsBrow"x%�T'X@-�btbCurd2dB"�RData"� t��a8� (x�4 �"h!�Ftk|�late+�T,u p`*�  3-- 如果最新一条消息不可见的话，则视为在浏览历史�HY���abs$0O.H�<H�@�lPosi"h_% 8).x) > 100"8W�,�O\gl)H�+�ht"�$\�"�w��t"d%TP�[tb+9f]\Z',p'��X��\h[�Id ~= -	 ,t*`H�
I0p#�$tv.n$(&�me.nL"}	ServerPlayerH��	���MH\#hm�$T(�0'0-� $�%|@t3�,d��I+=$t��[#|( X*'X!'x,'��Q*	��+XP�6�'� '�$dvremove�J' y	-�|=#�$'@H2�Id6�5,�N�:*�s�-��'	t,`	\J(�`7��0�l*�Q'p �R	l�?@t�'�),|l���;$Dp(*' ,D/�-hl
H--8,�		�&L�>t-��"IdPI(�|"`<$�o:O�geTd�#l�&Pc/L �;( )� 0D�dX"�@T��"4�TR� i&܊d	(%�D) $p^���Toggle"�O#:Pedǟ, t.	=|�'�(�	�(,X��)�@y:`5	ScrollView("�(@ #�NL&�'|�"؎$�0Shipd���G|<�f"-�e"�� '-(�a�	)Del��.n���*��(��%="fE�tdPl(�itemX1, nIndex��tb��s[�%,d��3-!"H;"�)�%t�+dHonorpIL�D@�	LevelSettingX�j.n(d "&v�tb���	��)�2�Titlerue�'/� $YAni@�ion(",� \L'�.ImgPr"���	elseMA	/Me'P�,0)��5	�5sz%D�Icon@$�hIf(t�*n��i,@$dXde�("�X+|3� -8�2@��`x�EszPortrai"��zAtla|`��`#|x+��Ci>TxtureHead\1���	D�Xgete.'�D*�dwIDdr'�(� $�I.OnTouch%�� f�vp�6@ }�.�o(\ب�5s,@PQlY|�'tL��@���bGoBottomx"�,t(�plL$�}'�"lP�p
'!I �s"art>�2����-�2dX%�t�X#(/'�#xCD`�Y tp@(+�))"�/#x	<���nel���%�6�%�<Msg$�$.8>�H�+%{'�x<p#�#L�23=T��T6D�#He"�vP;��LnH"�z1��#($\�lat,63= %�L�f 4D-��"�'#(� �*7��pn	eT�D	�0n= � P�	�0	�t"P0E&t'd	3�t'� @=D.�b$_\HND'�"'|dR"L@\ `Tx%��|Z�bSelf)SP#2== 5�2*� ntA'���X�ܫX�",0p
�lc-� 
h�+1X�\Q�b��9� D�H#@6not  � OQFr��5�f�
(T,�t�=H�Init�O(it%M#tt=�e\Op
�>m$ �+0�.p8"��or�R.��Y	,�	:l�G, tH�'	Id�"�ml\`rtb�=�U L#$H�/f = )�����:Widget��ize(&��416,*� ��v[2�]��($
H��DZH� \ �oLa#�DY)t�2}�[)�]pS��Rtb�.R�nd=�X"�nd�5�Is��#i6	�('vru#0��90$,0)�{40}); "�G��始的最小L�#<-高度X?TL)`u#,,L |�(��9@&} (�2�� 4 T0�6bClear"t!@2�'�	x1�BtnMoreHcX�)�*?� 21� nNewUnsho#�kL
T4"�J	%�p\��U.2� �0b + "�̸�cSe'.+t,�"�Jx:.�#�;�-�:Pp.U='�#">' (T�hsz�  string.format("您有%d"xQ��读$�PP*�/��T:4t  > 99(���99+.�/ �Label�TexSTxt(p���>� h&'� \h'��q+�
Timer'��:$L��7��,@	7v= �
$��er(7Tu&T尌�:J�ro, ['p�Y tЏ(�"h��tM(�>�V�+�"�;(`	��.7�Jini#ܯ@`X "( ,�1On�OdPnged�,llU@f��h`X%I�'(h �'T�3��)� P>�`b�|$!�( (��N)�AnchorLf+�p#h�x�+`  thenT�86)�T$HostGroupX'|P�I#p�P3Yt"�Is�{(me��	HasJoined, b�p)� '� �@
`5�.%�#sz@hsQ"#�6IVb'� '|*� *�"t)"下"��p�"退出�	el$�C+� I��操作"�收听�ndT!*�((�h#��'�'t`#\�#szd!"D7s, nl"LQTeadUrl, bFollowingGCha�-GetCur�%�nfo,��L"当前暂无�$��|?\'XH<�#�+*< ~= "")X)Fst,<��在$̨：[c8fa00]%s[-]DG)Pd'�\{TLibT�EmptyStr(T�)(�"��0H\YtT��
��0� Common�faL=0� v5ur#$VP.�("�'N, (� '�;t(�  x'0،+� T0�XLb�C@!)�or)��S'� &$-�'} e@�,0�`已关注"�`����)��/-`�_�
\(XM`�t�,��Mail��\dp#�ZusX\ --这里面的Lad"*会去掉超时P\p:Requ"�@@`d�3�"�G`\H�ttb�Hi| "XG| �X'�(�I("l(> ")`�̙"(FT	@|�l�fn`DescX'a(�"h+�nMinu"<Rmath.max� - g, 0�|k�< 8640(���� -剩余%d小P'", mxceil(�/ 3600"&�		�_>2��4$��	���1�fnL�"p1+$%�8, nInde,t_`.P�5&:e�	�.�'� H7'h �W$tY"(��8D�.RP�Flag���<"Hڰb`#�&q=	.d-\Titl#�^�K.�X6�f �tbAttach t��.PL$&R�Tix�p9� AM�xhd�l')i$�A�/t��h x(� �;@"'\RecyleTime7d/�mu%f�abd(t�'((�I\�=�|Yf��l�@� }y.t9(�%,(�I�f�S7(h�%V0,(f("(, $yWs|GX�Ie'��PW% MQc(\ hL]'� fnODhD((d<ClassLMD2\=��>1�] nT%'`	p#���q('TDlRoleh�#��,3f sz"�!fent?��, in.��Rtb+�[�]
 	�tb�d�\�&Ps�hp\<��LXD�+�rDL�@*� ^1 	�	�f�`
d)�@)� �1.OnTouc)�fO�:D=�
\a2./	(�
+W, fH#�G;�
�!�;dw�$\*��7�p�d�IdH (� @X&"�'sz�l'�'�(�*�xH�x%�3(d�&l��5'U	+�= (z.s�OT�'� �szCurTalk��= s)�
@l�+�lBtn(a*	)t \E�l�(� ,D�L"A/.0�gX�F
--0'd$ ��果出现也在插T '后 ,Tn��/%前4M-�L�1P�sertIdxI9#d\zDtgOfor@�dx, �Ds<,� )%܃l@�6�aͥ �j		+nt% L�6�#	L�.
\$��ot ��}IsHB�My#�s(3� M/	���Id ~(�K��t�xl --不X0' $*	�+(,
P+Dy?:'�Or� $�yx^9�D)8"�.(8 �](8�4�/� l�+	"�|>$4��1�
"x�6�t	��&I)=�t'�nIn�NQ�	t:)� 1��:�tx.q	$m�i�	�&'|PU'�,/��(0�?�&\$�,Ui'�u=9(�t-8V(� D)x*#�m(Tϼ��..8XE%Ll#�-t2�*|�((x)lable.rem0�, (0��	�� � �>tb(�"D2"�/T�T5.X1N 2"�"`�(P�(< �sx$��'m#tL-#`"(� (s��h:o�_ ,X�(x )�t*�,&a0e&�]sz(|	�P==+d�&�%� .�A(p@Ld�d"MHasj()'�-�L]�is%�[�HJ$$S%� :�_L�"BC("�Field")#?#K�	T�JD.ht\\�#{1ity��2� eamDS-(9<申请�T� �� (%d/%d)>%s开组啦~！", #)��ember@F�, �gr.MAX_MEMBER_COUNE2z��,'t#XJgsub@?Msg, "^(<.+>)(.*)$_"%2#���l5�Se%t�)�,X;{ ..DL�`h%DhLink�*p�{x, {me.2I�,�l�hId()+P *M}d6T	A2�� )l	�$�6<	�#8�L:ht@A"�;�(tUl.��Idpx��"�� < )�XCente"�|(-�目前��0需%d方可发言�6'�)�%�A"""en$�0:�L3/�,(�,�A(uFileIdHigh, �Low,LApolloF=Idp-t�`X0, 1000%�#�lite"d�@+'�( .Grid[""�C" .. i%Z�f ��)t-�.tb"�mand (K�			*�"�"0#�B(�(L +	.�lx�*8 t3� L )� Tt��,� sz+��<� X�/z )':		�x:Playh&�0Ani# :#��#��ing�"h3			break}F	��	e&�@(h �B	� � .��C�*)�, ~d e`�3�W. '\'h U4 .XoM(sz�, n� ^�"�!L.�e�)3PClient�hh}(T1� #�IDx)�)�p� � -�8�szP�q�i'�.SelfT�'-%s#$$&%�)'D��-� S/�SpU�e"�v�@Cil, 4��e\�)�ODZh� �.�  �nY�ep 0�<Change(x$��de#�fB�{}\��no" �"j3Id,e bD$ectRe"�1l# V@r�nI"iO,(b! i4=�)��U%t�?(� )lNl?(m  ��YniLtX?(] E3nM	,�9�!,�i$	|�(� mt,�$()	/ktru#}�	��X @D�n)}[(|"�=pl�9�Xu+_�(P�)�)$�<r�3(dtD�~=neHT(P��
(�,t&:"�0(�%�(H	QHa,X�I8nY.n6D4�/tX�M�i	,�B(��$*�X�"�6#< �'�h%�O�#OdL-���4pO�#40$�?��� 0�"�`X$<7�n}.'I :�i$�/`?LN�	t{LtbO`�"t,@ or {%�<H"�*1, �$"D�01,� [<!Dt-%�*D|'�,�FY	%�KbtnO�>d1� x)��,��.�Id<�XK�:U4A#X��&��bHas$ǉ, b"�KCha#�M'h # �Te(��x0qG"�D��`|@'� '$�ost'@ 	me.P� Box("确定要下播吗？", {{k认LLd.Leave*U,&�I
}, {"取消"}#,8		elseUr	h_y:/� �	enA�	�T�:I,�(�)Xd90LX.'�$u=	G�how'T InE}bx)t'''�h4*�,��*�)dr+�, �'�l9�-�,�x`"Wen�G�#x0\ (�E #� ��/fn`X'(��l6xd�'�5
�6 
�1�	 0�Mor$3!Ui:"�?Window�xp1�I�',Pp~h	Tl�&|(�$�ќ�|N)p HistorhS}�(��,�.XL�2X17p T;�	$����<szpc�s,  !��Lz�'�E�tOpt(�L`s�ingxU'tP�(�F"1��/uT ���.9�#p��'�O-4  �"$��4� (V 
+4"�AHInit(t"�EX'T	x�X�I�th�(�DE(0 X|OH�LUEt`\E��DealLink�wH�C�strin(�[365888&��Y	�	.szh�oor �X�5�%8[.y�xt�]Q�s"PY>� #4PP�n�$PYdD�v,\SizeA{"8q0, yN0}h+"�,(�)+J"�I�u(�M > $8K+g Low# //P U)@E '$0J�sz,d ~= ""t&�jH(L+*8<then��7��)\#�<Nod"؊true�",� 9�8+K4��L%l%�" �L)�:�"�'e%�>�'u��0h	�7<'� P<Lib:hDesc4(#X�floor((/1000))��?s$�;�?*�%�:Getr("��er"�۰�Gtd�+�UP\b�Tx$�Bh�%		�y.hO)4^+ �t�hq)� tT�max(*� y,-� yp'�+�e&�h"�)�A'b 	el�L1�szHead,"�S ��uRn&�ܐ+��KHR�-(,8�'�`'nSeh%�Iror&�)"�b$�m2�z'� nderT�"-�xl*�n�Pr"|�P9T�#�*H8(\ Łn(F , �%, (,�y&��'= SP)f, pt+�0�xP[$�p�..�sz�	pl	'�fDeL�( #d6�L-- 头像边框D� #�Fr@��&r>Bg'� bDefaultx�"�,*�.tbParts[(<"�|+�(�	'&",`	/�pn"� "$ /���&P7(�"��\3@��*�hGa(i3,(��*� .���).�#�<
HEAD_FRAME].nd
X&͢s�g�&Ayg,\h'��`\h�(4'| h	y<	+��*4�'� "1x+H ��
\R��OB泡H L�ABubbll��Ah!1('� t-l'd'�p@+h|T|�>�>�� |BUBBL)l�sz�	�"t$��+X,P�d�'DS+� ����T+ /�d'�C�7��,�	���6�bSelfD蔲�Id"\Ome.nL	�&�P(�pl.5�Kl���--\���族��的X�衔显示规则XI�`bL^�er\��L��Id()==t"�)t���(� tbCareer"��(� Member�(�@#�H' �\*� [-�$s�(szSTit�]""|T#��	,� 总堂主�e&�CAn�"�(@`�T�Manag�X��)�V,|��_q�[�] E�"#��	��' *�	0ZSph��L\��A	*� S({Txt(� faO); @?隐藏再�=, en"Ȏ 	时些控件会重设位置l* �&=*	`*l)d�Self �0 �P-�ColN'= �AH^"�4|�6�(� b$�TPK ��l5��|�L2��2D� 3�2 d�	���"�Gt" H"World���#`7�XngePosi<"PB%�(�m]0`50, 0�XED0+l	 %5�	(&nd�Զutb"T,D0*T�]]�P+�-\#�8��msgD-� `'xT^*� L�nOffse"!�2L �)K, -�.x - 55\#�/s.y-��e +d�.x:L+,nHeighkmat$���y %2�U6I8�;T�"M�o"m�s)��+(#���*� T++<	�,��osp�/2B$35x)�Qt��='� #�5'n|WidthH@.�xY4X(@f60"*��'�7�25�V*�Nge�(~, �
@P���$M� �"@��v)@J"�"Ui:Dea%�F'�tbLinkhv@�tb"y6t(_ or ��M	T�处理红包链接@�|���色PH_(� .n|.�.\�RedBag=!Ce�(#,��;@�251, 159, D0T��X+ES'(3Q92llP q)	�'"xG 	C)��|�"�*Lib:Is'l�).sz)� ),�tbd/+� S2tbL�4,$G'�t�/Ex�'� /t Q:09ID,�*� ID@)�at(�'�T�xtY"�(�ClickFns[�pO(�"&0	t#�J	�9(%�J.z�ni#��%|�$�=�BЙ*�S%�@(ddT!�"�5F��Or5E�t�-SH erId)"h*#�@�g?�'X(tbObj, id`�'EiO�(�$edL�+�
�t�sz&�T='�C`}LIWithyC�g+� U,H�t|/p\x���"� "T)X@"h�#X;d8thz�%"�z"�t(#�)5� Tip��D>� P��Family>� "��`>� �<��>� MaC= ")�#$X'5t�$Lb��X/yFn#�I*p)�(X�+TimeTips'�i$,��a"<�&t��NTDP�'�,	8� jTi"��(@,&<6TodayN?(LD�L�#�8Day()p.R tbC.nTL# U&�5szFo�"�@b�
d�"%H:%M$�)%m-%d �lv.�$�&Se%d�,�os.	�('�hZ4(��D-<�DR}ntv�("*�ac	.SWid/�pa/bm."` 20, 28���.D!y + N�30��p.�P4�(�-P)� (��BHP�|tbL��Y"t�8t'H l1�U'� d7(} .��pT#1xx��C;�/0\-'��[.�'�@�*� �|�`�,�s#l М��LҁHSLt�# @�"yi � =<�t�)s},-�/p�*�Ni)T�r(�xC\6�
P5.Tm2a4974&Um �h.��]S)0'�HW'� D�6��_Tfp]�f( 2�L+H/]t�-20Xd�.y / 2hb�9�1'�X4q�t��tbO"�"ckY$t0Q o',+'D	0� :Head(_, nPosX� Yl�@b)nSPlDj�meDb0-M @3� <= 0' �'�
ҰdwB�IdA0'En$�r=*|o�HYt.w=�U.L."@hv"�-'�(�L�P	"t9 	@��t9&LD��ot%�'�M%(OL&�e� 0&E	�B'tba
.�P1i)	�&(| �H@:tI�0tb"h$X"$T
#��|12Du7	$HfD)� sz�D|�TJ�^,� 'X �Fac"8E-� ���A�p/�5D�G�D#�"�szp@D�,.t"z�tR"�?Popup\�E[t,D	"x.�5PosP�%xsD�RealAiq($�n�gz��>Ui)��AtN("(\�-76,T�@@�-322,D�i,Tg3);	D`UY 	?=1"�7-5X�#9u9Sx�Mt�=�
nd\
�A:�X$$�A(uiP��t"��Is��#�tFileId(�%t��)}�,*0�Low+Z sz+�) '��Clear\	"���#��'�(X )�r�*)` �HHB+�>x\1x2\�)Ms*�;'��IbRe"�I�qN�*�++`r�en$"}IDi1	T�
"�"��TI6E�	*� S��Ar&�, +��"��il, 4�en#��t �
tb$�ETlOnLongPres`g5` P�%�E4�	'	:u%F"Hv��`Ք�2 Copy@�s�, n�, '��ED&PWindowVisible(�el0v�1 �xXn0� :Add)D�"�Otb"Y%s"H$��"H&vDndx�%�AHailGrih�]C�2M�%�N(� �+#�)L�0 �(� " ��H*�gDet^ed�%�C�t<��I�DSet�("`PB� `")
end

  ��  