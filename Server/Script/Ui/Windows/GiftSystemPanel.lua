 local tbUi = Ui:CreateClass("GiftSystem");

�ActXT ivity.WomanT(�  emPLAYER_STATE_NORMALH 2 --正常在线状态�nNumPerRowI7D|.nDelayCountTimeK1 	\  延迟递增的时间（秒）
��AddInterval]3���加数量G隔'帧\�� HideUI =
{
	["BtnGive"]\	true,�Txt10I 2-H ScrollViewIl+,O ber7� Head*q }p.�tbSettingD�PartnerCar�l	fnOnOpen\function (self, ngId)R		)� :RequestyGTBData(�`:UpdXF)� (*'endP9		szNoFri[TipT"没有可赠送P8门客"�Select+� 	请选择要-� ...�bNotShowVip�`4�
gAmilXV` [92D2FF]与[FFFE0D]%s[-]友好度HKOD：R%d�szChoseReseDR�'��日已���物DIDL@+� �"�<� fnGetAlll/\,��0return ):�CanSH.h(me, sD=.nCurDw�=T�#fnMaxl}ls �*� �C(PRemai� \`N���T6�x\|mitity/�P[tm�	4�dDDExp(nl�(,NIs�?/�6.bh/��lk(@\�d./4XnId@�@���*�`l�nD1� +�Hel`W( 	�
D�d�WindowA�eR�alpPanel", ")�lm"��}HI��'lu�:��(n�yiO,XΛnfoTRzKey|�StbVSe����[sm]^(if�Y+� and0V .f�thenI	�
(�'� �LL((�|else|pܝh��LX�@k�Hu�`�*�tb�i�	R&
� 
2�End�i�p�0:Label_P!Text("��st30D~����49S)��	3��	|�d"*9SX�D�ve("B�02Lp�=� 1 � NoGoodjfaD0`
 
�-$+��)1�'��D4� l'� �8	 
`,(2\9��/*�.+8l$ AS)M8  P*� h42`*� X
+snot�u'� or }np[�
'q )'UfXszUiNaL�_ in pairs�w.$�&) dodv5'� �8�x�&5� *��[6� *�D#+� ̄VipPrivilegeDesc�|��t� *��l����.0�)L�#|(�10� -�'� �)p:InitBase(�s(���List('x)x p����)` BottomIU�(.h 2h�.�RefreshUi�/)p)P.p @3�$�,2}	$r5szlA = Recharge"'/� "WaiYi")re""P3h�8-�Pn���|o�?�� Imity 	�x��D3	I+0�&@*T�tb'�[1].dwID|V�nFaM�o" 3�-� �'� T�T�5d�'� nSexDPlayer:�2P���,/�tp'�.ngETyp#�:*�ndE0(G Cur#P �4�	sOnline(nIdxL+�EtbRoleIT`L
/4l"�$%�+(� .nStatF= 3�>'P"-- 更新��. �Y�ELhxbIsGoTopDH;�Z"�%Click)�+(itemObj\Րb�L�.�\��)���B��5)�6t-��>)� �(� t8)x x)p .P�
#x3P�:�Leve"�A�n�'(��|	�'�G��.��B�?fItxFT&�(�*,|>�+�0(�P4����!D(� "�!hhp�E�.*�m]@Wanted|�),�,,�P`;�#��-��""t0|
�$<� lb�,L��f#L!)@�Bd�2X <= 0'�!	-�S(�+Sp�ND'�	�� � ��t!�;'P@'�x�Icon(1��=/�prT"�0S�("'TI '0 �$�K	��nP`if *�%8	TempleteId t%T5��H, nQua"�E�2[Npc�H�P= GetOne�	"� `�+���eh��t8{= KI.X	X "�G�nP��+� szAtlasdK�#PTt,@.P�v Id�@)l���,ht�#lN(Hd��'L�lPortrait�lta"�E���xSmall/���?(�p{:IsO,�	"h2�'� �RP�� sz�'��(�>HGray`Q ZndpO�Sit���0Button*MainH[�"@"�Vp�ThirdNorM)"d~+\ DisabledM1�)p��	= �*p t�@G)hdD�@.�dT#�U= )� �+� �f\	�+l P�5X"1T"dEd,p`B�ex�4���\�+���	.OnTouchEven"�_' L*��:Toggleh1Checked("�1���%�F(+Li' 'p
�?�h��#a[C"�!��e�H� }c.(�]h[��(#�)e,'��L�&p#'��-8#�#$H2�� 
--$%�#LX4%(, T,l:Close#�O"Qr(|S 
�Af*�X�+a.�|\@�Key@�"a.*� #�+|���A'8Zxh�D*�Y��],�%�Y@�"!�j��Q�S�V�'	\!local bHad$�)@���q~n3�@) ltE`��S
X
T)"�A�(Qo3B`�)z* 	� -- .N�>的处理H#�'��H.Active"%OG$�KtD.T
-X= {}
 �� %�,�d2$�H	$�?L�
dp"�(IdP(�'�[1]�%/U .%@\u'0�P 当前默认选中第一个物品)�-�X%�CD�<\ �<'�@>t+tX
(nIdx - 1) * )+q+ 1B�		�nSte"�[�+*� D)� y�wh�Dl!ׄRowu�(y,�	���::@0u*(Η, d���	�,�n$�smath.ceil*uM/( T8X#l) |�(l	-�@4|[,@}
)�D�"�m�j(D|.Grid["h0"]["x1"],A- +  L	�@道具H^',DT�� 4�P!.t@�7*A{"�a	"\LindexH4(<%�OX�%(`�]�		tp�.insert#�)�4,3� �7�h� )D=�HG�\	隐藏所有"Ps#�r特效，�$�g点击.5S#(V'	n$l"�gP@�=0,100��$pObjH!�7" ..i"I@	D$`��t&�.breakL.��j=1)��hc�t�Baj���'e	�Z$		�	d1�",'���,/�)et��� )� > 0t7�T� 清掉之\�P3 操作信息,决定是否可以批量送（想'8 则不L	#��� #�kClear]#( ��@F�6n`Q�ĸHave (���= 0mI	�F�= (� +t ��p*v sz#$\[�< 1�string.L�L�("%d",nn) H�/q /�l��Q+ 
#�A"0+$xm�Suffix", �eJ	@ �0�+� ���Q�p
["MinusSign"]1$-�tX��X	*@�.Get��"�(s("n-, '@RHt�$t{��*��6X=��*�i�."�&*V .f)� �'8)` H7/<0� ��, `tg&�),e�:*|�l�$`y4��%%�! )@'�S,H(%U�(4<�'�Xp] ��-��@
�-����%+��L�$X�1`d#�R,\H|c5RSe#�Q(" G�, ib�, 'tt�#'4fnClick�]�xԂparentP	P�
.'L l^�*|;�V ~= '� .n�'y&:+�e#�##���1��d+�^)�`+"T_@t��{+8t�M	��q ,LQ%!�en#�C�	|/P!)�d���= � &�*���0d<��-8@(l �t/Z :S+0"(i,����У� �/ �(�ح�� �l4'X	$�Se'� 2�/�)� S�!\�%��x'%.B(Tr#7h/�;\P� i,tb"�+ in ipairs(�)) $�z@^�'H�,�]="�nfo�_p]Lt#�L[#�.";& i]�l2�^:� �[T�(:� �[= me."x�T��InAllPos'$�:�)= ��'� �
�7-\pL*'� �4� p)�  ;�
&|*,� �
		;S( �`&x"4�e% �U3][,$"0A[*L	8[,�m0,Q(4 $D�-�4�p=(��gsz"i, n"$]X ViewX %xb]]Ktc�W(at"�e|.&,K|�P]�)�Je0L�  	 � ��sz`#4`X�$aHl"�LdSeconq� (3��J�|��(#�>Layer#�*p
�,) �(�	`���
 �(S�� $p7D@)�5_�$)l�5Color(&Ti�-X3L'@-#�k*��'p�!?(��' d�nFragNumXCompose.En",��tb`Kt&Wjs[ns*Id]l)h	L�'�� A 	��s$�jH"UI/�I/New��mx�.prefab$б(� �A`yJfHmnet�lObj[*�8$hment�)�l7�|*X<me'@)(�+P&�/	 fa%��	&�'4fnPres"�m'�*&�*oBtn��bIs�) ��#+):ClU<C&j�r(�t8ot b� �9	` �,.b&�2#6Ril�
	yA:xD`Detail({n�E=��F"��$-�=+�]S#\L�L, bForceTipll,}, {x=370, y=-1}Yi	` $`*�e$a*	�'.#�'TG��|%$\G�"�(�
�TryStart�"i2r)� �DQ�	�6TT�C"liL�,tbRo#�MhM�.<8��7.i�r^nid1`H,�T�:Register#�5.n�Ad'��, ($	�B'���= ,? + 1L��bRe"�m`:8�Lt'p	q."`�*|T�	&�;�cd�&'X hBTP@6V 
.8;�7D-�Env.GAME_FPS *$�-��,�-��,�'6�$D�\D�2�ET"6�$C'��~),bnId'�h\{)$O�"�(/tWp(�,H0'�&�-ul#Dk&��Tx"$ %>�K�� )�:p�#�')(|h|Dm +�9�| `��2x
p�~� \U0R > $<"�m�or �LXJ������}Ds�,�p)�Bh,L-- 次数不足DY()�G�� L�})#LK'DB}-.�.H�ever'P\
"�\�9Pu"h�L�'� 	me.Ce"��Msg("剩余$4�*�#A�	М'p)>= (<dqtW ��.TI+ �1�(�"�*�P4��''�== 98u1:$D'�m,1t�%�r$|r.� )\����*�tp3xq./T \�Js 9`X�%�-L,�Ř&�5+`X-� Se'�##L#�W$�DIQ0txlؽ2A--q�: YX ���Re|5.l/$$@4Te`0���qlrS�ose�De*��rl#Į-d dD���tc�S-�8�-� )�-d ,��.�On�(p|��Ќ`3� 9P#@(�\row$U1#'�#|bT+�< (�x ��= �ֶ	fX�"��,)� $�I'0�^)�
|Z$^I, #!�w��� ��tb"ƼY"|�&P� ��U3*��	["0h�1��GTm'�((�X, )��p5�n"�&'�� _+�' ,PuB.-(_+� �`PH�p}Id) * �@A& 4�RateTR��m['i]d�$M\C'Y  ��h"�Z.Mai$4��E	nd	�
$"il(](',,�TI|%�?		,��
�lV�C&*)� 5�a"8Q$��+��#\"�!Y�s#�,�RXIs.�j��/U .#��&H��!'@<� �6�*D#(h�6',t|*�5D+��5p$�+�kInfo(bChoD�hi[fI3s1��,Y)%�Y�/�'� �+t
�@,)�'�4"Ky1",p�d��/�u2 � ̀(4�@'t
@X�'@ xN%l5"Pq'| \l"�p)x �m'| "�!�iHJ�n)�$=#�2h:�e�s0�u�X`3$�u�	%�/�d	�*p9� Will�= '�&- *�+ ��n*� '- >(� #�.�h'� �)(X)�(P �b.=�(:sz"�E�	.�QW"$PJ'D*�	�'\���APercen"$=(� /'�\*�)� ����:'0h"-/-"u#s.� / #x��,�2T^xPf�'<,|��	n(H�e"�%$4-05NFT@�(��Ba"�W�\(�O�4"P�\)��亲密	��R*45vsz)�'t+U =�h,h*� d1�#�-"TW$����,H*,s�L,)�)"�"t�ܑ-X��Q"@�,��Mszxz�X4a�*6me')a,"�l"r�) FX""|���L4xh�0�d)�+��
(���
��
xXU� �,�)�,` 4�+� h�=�!s�"�== '� ,p.�m=3�
�X1�TH7�8y� .l
�DO, s'	�A3� .� |�$No�
H,�"�,��<" �M'�*@xZT	"�X.�sz@bsz(�l�E4$LhU�s�Usth+�@']e'�<N3"'��B� .�5$$$'��#���T�&#\�%Ҹ= �Shipdm,$xj--按�"和(p	��排序， �的》 �'�fnSort�(dXa, bh"�:a."�V"O/= e�$iHb?� '�
%�>\
#�� > P�H�.T{VSt#$16�.<"') L
  #)�| &,0L�.��ސ>%��s](()�, �+H)\	�;Tem"XeLib:CopyTB*� �O�'��{})Role"h-Kjnil$� @')l	'�+"�-index,tb�i)|�n) &|=",�h#P�"$ 2<		tb)��
E	@ 	table.remove@v,il�@0���(� \L)t�<�
'@�+dT���	 �H"�T_temt|�,D )�\or .l ~�Idt#!5C"4hl�wX p`(P(P �dknfo�/)'�	=�x
�%�;�$3t(��TD)4 t2;�6%d���PX2T)� ړOw�-(meh�YnPriorIdx�<�Id'�foL*Idx, v i'l
��)�))�
v�$�TqI(.		'�P"��N		1���%� �tb�6���dx"(�PF*� ,�
�_., 'll#,h0� 1"좬Dd�� 
- 3 
R9tb"�Pic"\�j6Bt$QL*��#(5t	Ui:Closeq&it>dSx�OGiv"tH0X)tj� n#�8LB)7 < 1'�-c< $��%(cĹ`A�'	`ې )fn ,�<�`K*P���")4l"?)8 �}$�&��(.�el#nbNeedSuru&GY*:����)P�(8/�D+('�sziT�;确定�:吗#�/	@�
|"�Nxnm.p `1�N%At��=#�f`�&lO�!TZ�,B�3xA�'�	 �	)m	dQm+	p�.tb"Q&.(()�(Q =&X�.� �	�J'|me.MsgBox('F		li			{"�-",@~
RemoteServer.t`d,�$hq-,�1D&�K�l(` �+d); end}�D取消"�"H�l&-P	 .��n"�Pt|�N`6)�G�U� X�	'�/� .�wp�(�'�@9,��2�<�1�_R%��#x�"he' D��N	�@ --{ UiNotify.emNOTIFY_SEND_GIFT_SUCCESS؇RefreshUi� �83YN�DATA_FINISH�.3"��X5%`.tbRegEvent;
end
  �U  