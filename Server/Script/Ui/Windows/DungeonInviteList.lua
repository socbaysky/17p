 local emPLAYER_STATE_NORMAL = 2
�nInviteIntervalH 60; --申请间隔
�tbUiH Ui:CreateClass("Dungeo�	List");(� Grid � |�|d.tbSettingX 
{
	["PartnerCardTripFuben"]@z	f�\ function (dwID, bNotH ify)@			RemoteS[er.)TOnClientCall("�#Player2(�, 3SendA	XRandom�+0 �*)���G}
J 
'�tbe):H'Data(tbx lselfL*xH� L=todo 显示_	if �	.nImity thenT好友A	�pPaneluAZ,vej%ti`", truee	.0Level�
`	+$Label_TText�	acy�h
��� .. "级"�+,ProgressBard
Valu�H
T@
 math.min�$.�/ �Max� , 1)0�-�lb�DescSstrXV.forT("%d/%dX��X$��)zf		H;T#elseX +\T#1�faH`�L�{tbHonorInfopR)(��(p;E	)� LC�]LE(� Heq[�(e ]\���x'�5�lbRoleNamel#�F?� 2T'�+|/L*|�-sz|t%+� SprX�_Ani@6V�("� TitltPB'X.ImgPrefix�5=�+�4�L+�:(� t'*L7��.��3;�AT*�;�l$�ISpFaP|N�= �:GetIco(��(�  szPortrait, szAltas'd	�vSm@�+(�l	*��4T%�("'`M '0 �2>� gCHeatr1�/Togglep�Checked("�TeamP��'b� A� |7 or �>D�l�not Lib:IsEmptyStr�XSpcKin�T>�Family�Tp�+`-��tT�+�h�=D����nd
�M��D���ckI?{��.a .�%x(H'(`*'���+= x'`Xq�.�'�+/Ui:H#�"()AI#�#"\"x�'�"�!X
Open(szType, &h!pX�House@Peach:InMyFairylZ>()'�A#oMgrl]�emberL>= 1'� 	me.Ce"& Msg("人数已达上限不能邀请#�$			return 0p/��)2;End3D�)�d1% %h�� D�TZ"default"p��bIsl�+Q(+� = "(t ��	ShowNearby =�f)HlDb)` T*h@,�@pD-T2Foribit�
Map[Y+n\ TemplateId]'�b`�L�YvenTYH�P ��SelTabD	"tabFri\�$�r�'= "�
�G�5	��'l�	)��	\�	.�/�*(d:Upd@ HBtn(pYu.08'T�"@�����8� ���xAb \ :HasY ($�#5 btnCep`�x*@	:�H'� /p � All@ � $�.lyX>ecte|�/��+)~, �"e�N,��33@Sx(Q�IPuterVal�(���PX�l�m.'�&�'+T �dGȌh�	�utbm�S'p6�'�6[��]"p(@,� hB+D 0<4x �/(7,�,`7%h:#�88,�.�Is+\"� Id`f� nTimeNowG}Getq(pP|?� tb�d[dw�(�7� X�p	f+ @;*x>D9�2D�l:'.> 7\'�7�  ����'�,�
�By�#�0�ScrollView��sTp��:�(� P� � ��L&�$L)�:tbNpc"�*me.L:R()���XByReX�"|0T.RELATION_TYPE.\�ow, *a .S�yer��szPT�R�= %�8gsub(P.Def.szFull#h%H�mat, "%%d""(%%C+)��)�Itemf{}mtfQ�_"\9P in pairs(�) do@�xpg= KX dById�.nJId"�*0�|K�tvc.dw$o4ID ]�0���d�X== 0 �	D�le.insertP�, #�F			" EMh ��,l			s#�6@��i	A n%�1��'| #3't �'l #87�'� )H @)$X%X*|,L�6S3ch(�\7�6y&"IKs�<�(Mn&P3@��"](D$"%Id�	�,�"nSe$�9]}l�*�'X$�KfYtL7tA'(i]CC"�N,]Ad\]	'P "�F"-�2[inM]l��s$�HP[�f^tb�8d)�(,�%�!�
, 'hx!�'�#�-d��(t�
 ��xT?� L4D3�� � �)� P�-tbX!�X!�Shiph9'd �*l�Qualified�~4{}L
pvi, vB4 i�v'�v\�v.nState Xk4`W7�.�Xh* 	��O5ortX'�(a, b�Ma&�LN b�thenD'D2T)->`(< `&�9��@#ML ���ndX �FՈsP( tb0@�@H�.Jet�-+@'�,L.@^M	3P.�;|�x:0xH�S(��(�.�,�f�`g5�OnShowP[ � 	$PX` �/�h�I�dvIdxW(vre";\#�<H�"Me"�<"5a(t#�3:)��.�&)| �Ytlu�	h3|H���L@["�&+� �Z,�P�KtbOnLine�r +`�(XJ/� �d)�/��,��\'P�)ID��+%[P��(�)�gi���s, vD'�Y�n�\gXm+�'.--#�` 	家族里还没加入头衔L)xCareer <l��\�8��{-l�D\'Zet\-+` L+|.@�L.tlF@y4t�<�%1�@�VD�+u,�x@dX�.�
$�0ALltE*�
Q ��tp��sH HU���Button_HZ#M("tab%>)'4�@
��Hp	x� @�z:@�t#�l~'L"X$qn"hg�(,JYCe"�?#�K目前DI有成员可以�%�KD �JEe�U6�)+�+%�)v.�or v.n�:Iĺ?:�1%�9���,�一键�z��"j�.�$�E@.#A s#4QTY|#� ]y"�a�"'�re+ht7( H-9�)xG\;h/t.szS$tJ�P@�@(`�"(� = )h	M/	lG| 4� riU"|\ X � \ ��W1L]tW�,�_'�=��`( (#|\H׈/(� (�[6(�H	HL*4��'xp�9�{��t*6 �0 cBy(p�'X�O+l �0� 
"�-]�O"�{+v^Ui(Y .'8P�(<(hH=�t.x3���1 	��xK�O*�7�t$by =  $�'�"d!h�,4�'R3�--如果是'0}��bHas��`"8wX{��"�5�eIs&�p/)")'P��*D!i$.���M) $$@av%�d'� 	�:�v��s=			+�t�p&� &+1lse�W9�X� �Es �'T 1�~?by �� �hӒx		 ���X-)d�X�)X已向侠士发出��，"����待回音#�I'-��未选中�	�|7D�'x,�.'�PI.X(r Al"h�4��U%%7.�^dm'��ld|E�qn"�U= G,XWl.nLast�	�"�V#.�<��4� + 6(x,d招募函`5�3�3等d3��他�.接受�7"�!&�=@ψ�w5�= pD�+�]X!� _*f()'P+�.fn,� @.L'+p�)_.� �-�%M�O��:PKClose(l;"ԚpWindow$8fUI_NAMEpn2(:OnE#j*ap 
RegisterEvent�local tbD� =D #8T { UiNotify.emNOTIFY_SYNC_KIN_DATA,�;+L)$�$ }#�T{0 MAP_ENTER,	�(Q,�U�}�o�0)p	;
end


  T(  