 6--选择创建角色
Require("Script/Sdk.lua")

local RepresentMgr = Tnet.import_typP*� ");+� ntEvP:� �)� AvatarHeadInfo8�/� )NpcView8� (� )� Scene8� �*� dk9� dkInterface� 
--登陆场景参数
Login.sz�apNameL&
"choose6"; ---� CJra�Main �"E0�7sz�ObjPath�/Plight/�4_cam/�001_Ctrl] "1Root;)� SelectAniDefaultdall_s01� 	全部人时的默认动画(�XmatorControllezP"s�X�tbDDYctionEffXP{
	" �/)/C�.4_/D_guangyun@'@jing'H _Z", M�Y`}
�GnBlackBgSoundIdD 8015lG打开黑X~幕布H.`�|P'�4D6RolexnU{TNkey 为 门派id ,D 需要从1按顺序G[1]pG		s�Y\	HO�Etw_dld",X
	选中单个Ht?F����/H?@�9"PQT1i	|ModelShowT`= "denglu'� �@lX"Normal�'� FirstL�����fL_LenK	1.5)�U\W长�n`0�/6rB		�2\versXT_kor and 5101 OnilL�szFa�YX"天王�  }[{	[2=�em �P �\xD�1�%�( V�42�<�2;����+�B2[3=�th �P ��18 �3:�桃花�[d[q-4=�xy �P ��9 �4:�逍遥�-�5'�[Player.SEX_MALE'` 42wd P>Take ""�sz d�20�<�5(		zZ		*vFE f2_T$ �� ��5627 �P0�+�武当x]U�	�^6=^tr \P>�$�" o�21 �106(�h*@�,�"忍y-	'�7=�sl �P �� �"7;���林,�8=�c �P�-�?%�,%�/1"�*/s"=s/TD�/F4_G�_h2�|E,� "9,"5� 3'� .�/	1= "xiongmao�i7� �t rj023 �8:翠烟��9=t h0P�@#�/.h'6 o�4 �9:�唐门*�  	[10�-P,���[b{
�\_#�GSel�fP"m2_k @1d<�)XX1\�dl�	P?D%L#,<@,� ���	 �<&<<C 804%�<�pv0�<10(p�)"`%�7l%�P1� �T?���'X�&9�<L�+ ?��� ��~)�昆仑�@ 	#mB Hb> Hgaibang ��)sz1��0� �sz   �%�0[]597 �%1;HH丐帮���J][1>THwudu �� 	� � �
"� �,��1̥t�'� �ld/��(�!. "� -$.� �*�9�?� C�9�v�Hl1|;\K五毒+�@u(\K3�Vcj �s%�aAniD�%�VL(�s8l�s?�?s l h�*Gs601$� -- �d-lpA+l9藏�ܞ���p(�Js2\c �s3=g"�f%�[s J<�,�.,�/gyD/��L0|(�> �3f2		 �长歌���H^$�K t*� $�&= "�hd�1� m1_tsd c�(PT�.= "�-� b8045#�2"�%		*� <K �f2t/>�� t�4)�+,天�$\�T  [1$�J �
2_b qVm�>�*�#T( b�
608*�[)D[ �
1 �f� ��*t+|
霸刀*|S$hO |
1_hs \>�\�T'�;s?x!X�&�),(��� 		 �&�5"�!11 d[P(�;		 �� �}D�\>�� p� ar1)dM�,+�华,\)�� SERVER_TYPE_NORMAL 		= 0;	"\"正常&X�*� OFFLINE�1�维护2� RECOMMAND I2�推荐2� NEW 	A3���服2� HOTC�= 4� 火爆2� BUSYi
5���忙"܈$��ACCOUNT_MAX_ROLE_�a];(� SHD_BGX{10, 11M 2L  7}  --每次登录歌曲从里面循环
if &�3vn then
	�7q4@6, 21 �else)�"p�8�H	
end

fun$���:Open�#)(b"�� Loading)
	self.tbSel)��Lib:CopyTB(2(�"L��bMapr	edV)faH"4��
b|	ListDon"��LYb)�(	Ui�Window("�ing", @5me.nLTemplateId�enU	H
�Mgr.s_+� D == 0'�p:BackTo�(truep!�:Ox�(�\"|.hL%hkRes&`�["cj""�Ud	��D3�T.ToolF�4.x	Y(�s$�6\"ZN, *P $�U�X!�*�	e�M:|=60��&�'XW.Pret�Cre\+h"��/`	nSynct�<(l(LM	(">>> role lB@ df@!!#ġd5�nCurWNNpc�3$��# � 页上断线重连 X 	新载入选\$��会清T	returnD��9.b*tDTt3@TP&��`CGetd`�
table.sort( t�, '\( a, b )X�
 a.nLevel > b�WendtD'�e"���A{�� 	for i, v in ipairs(t�) do]	�D&�Nq(:~ea'�(v.n%0TP	.nSex)tl _QnotWSelhCYCre�< t��		��0 = vA'	(�	@���出现同$4�$0�H5名的tx=8�LOhters(�'�x|A$L*(2��	5�(�= {�rH�;inseX;4�'� , tbd�@:��C v��t-� R+K, {�g_idPX9oEID,�na#�v.szz� }d��]sz,7 = |'EncodeJsontJ+�#f�	S#Ѱ.�Datat�g("0L�XdM@vAppId(), tostring(%2!IDPselfH�yLW, 2�w:On�{�AndD�qeT
@L�/�ClearB�s(D	�e'��f�f|\6LDhhX0�xesL"$6h�eSexs(�
l�_, fh i)LFes�
'�
RealV@hx
|�'\�	��szB�fb�9= �*.gsub�4H
&�Sel%�Y, ""�2$U2"��	hl`Ld)Res}[)�]  '�	/��.DeZoy,` 8)	eY	�5	� �Xm:�6Timersp6���fnl�(���X'(�tbxo, nF?Id^ Se���tbParamT�z�P �H(\��	T�*d D|X )T tbSe'�XB�in\)T "�%Gif P�VisiO�("C'�") == 1'Ui,t Pc`#T.�eEe��Ui:hWind"d$)O, t�!�nd�� �>�&Hl*�0�
*��<J t` �and(4 H (#�'� +h P.�,�	"�&Set,P �'(20$$��%1p qt"T(�n|*�X� |='�
�A:Upd��&��\8(|t3�0��R0tb(� .�@8�szBan�.= ""XL1,� _Endtl < 0"�>+�.n)� >Banx7*�+� Getl	()) �G+(已冻结)x�!řvT�~MRP��p)�,�S�y,�3!(t�#n/Se(+4��, '�Itv�.f"��t("%d级L�+� $�&)H3�/�O9��1"d#y.)4"�ot �| p�pݓ* --+� #�]y�edL%8)P�D�AbHasNo(�]-tXS\I �G, vt� 8< 9v`@\d 0���, l	J/		|׌@�)�t&E*	1��~Q	��� �&$0$)L= nil;"�1��%d?��清状态\n.b+��g}	--^�("�}Bg"):HideAllMovie(P'0�b-H �
�:tbUi]$UX��")hxx%R$inQ;P�Ui�HX�ntbXbenszi"}=tT	.pPanel:� _LqSize(""(�"%7	i-t(� .y ~=\�'�@根据屏"X���辨率设置 fovt|!(1.77864"HC6)，  I3� , 30) ",E 1366/768 , 4/3��fnFovP(30 - 26) /( D�) * ( *�xD*= y+� +L	�H&�`�'�	Ui.$=l�$��Change�Q(�);WEtod#�5�K� �LP%Ui:CloslA��#�=��"�;�?\u�b-Y �self:On"�*CGT�zK	e' )�Set`;�Active(�bAR	l4KIOS'd\Y(��X"FCG�|U:p
	usicVolume(0�	)+�B��a`�'� n|��%� /pAutoS#��RoleById(dwjIdlLx$�'re+�?fp��v i'�.x(\�D�
nfo)/$= 00`�)�MPeD�
�r��\Z| $�@!�
SCre%�!.��ID"<)/�		��H9#�**F�, |�T	A r�) h7�f�M4�tb.'	#�4nIndex,v2)p1��'�		z�v2>1	�witcht9P:�(0�T�iH	� �1D`<)	��)2		�W	` '$ �� � � � /�.03t|q@0	Ui.UiManager&M6U��(� �~j�Se0p9b Ui%T*"��dDtingt}@y".)
N= d�-c SexHY�Il# �tbLast��foXClientl]User"�*Ȍd."e�1l�p">L�h"l$d�g�Y	\
+�[\Accoun#��()]\XT� x�D� 
可能换了服务器或数�Vں�D�这个$q��#�Q	还是无效%�J�bFindL��D�]i,*�$}2s'TRv.<x�
|4p
		break`�		en`�� T	x��l�'�'����'� |l#��果没有记录"�U��� C#就�"$0�	等级最大+TnMax$�S= 0�fX� X�> (l�	'�= ' �		(� ����2�self::��Fpe./:= �3�An%��Sel\A IS_OLD_$�K#�;	MathRandom(#�
tbLl\hb"�")"t'<� ����oc�er:��2Q()., �'��$`F`(�(�, �Y, '�(|2�\$PJ&�k"(jD ANDROP�thenD"Q:XGOpenAnnKuce(��� /mS0Qt)P<@'8�"t��@4)� T��\D'� �3�� ��	vX8�[�l��� '� ܒP|eapalc"�-Lib:C$qlvi�	��k2, v��p&�^�) d$)	t)�[k#r�v2E	�X	#�A'�Newt(�{ )}��n=� + 1,#'� '�,�[)I,\	�&[i]�F'�1,�- 1( At)�'��0)D#},	$ u��|g7<E��K� /x	pc"��et��Ani(f6--.yA#-dS"��^ma�(&�Obj�	, "all#85 �5$M� `�2wSet�L�orEnt0T�5
,�| # `, szS#�.H��M6�ynMa%@x�-Lqnot "2g�Ui:$L4&uO"�ing")"6+1 xtT�返回p 时 会先显示一下��列表{aUi.�<a6\$��P�F��M�wQrueh΄ p$LH �tbAdd~UUi"P_��= #�ZHujnù, v"�,���\,|]v) �x��tJ�xe"�$dUW�Get�^�s(�
l�� �b# -@`"'"�F�'U,��B		�@x((2Tnil;���p)u:x0�D	--Ui:Close�A(+ l0\
PreloadUiList�IGUi:f�WiJ�w((0;K-- 2t huTH,�essageBox�--�"�$XL加载完*�	"�$��'h 地图���况Dself:O#�'d"�OAnd'�	(p�$/�Clear"�U+�dfun* �P>,|*�^Yl#y.v@2`P4)>	[n�dܸ?H	�`JIx#'� = 2�tY	"!Pl<HR�Q$�"��F�Cvv[dk	v.hPx L	�"	re"n? v6sTry"�TbTReT^)�,nDelay|�l�"�%1;#0J)D 是该函数之后设上L�#`x(0T)�x�s7%ov2�b"-oL,x�`\6)�l�,oor �>U�t%�%P[|0��#�7(#�6.`"�G*Bg�Am�	p5�1@! 
P� = |�]	�.#��j;st+�^ker/�	/%s.prefab",L�M�f#u), 1� nn	e%�L�l:Reg_�er(�(, '�(�#%"On�0@M)p�		D$dX '�
/H*� �2e&�bl�Fn)0	DV�'(�
, *@ D�|�� x
,/u[1�] -8 � (`0Tg'ToGameObj(1�a#	�t)�(E#vXb(�pG@+� �$�H 6n	e�B	0�Se-4r2�, "HP� ��A	 8&�#v2rfa@#@.�
TZ{Cl)�*�XL!'�bAtuo�0'+�L�QM0AZ�ve4otru$H�Px$��"T#'X, 0\-%s/%sD&t	�Se�b,�w(�Py�a^	 /�"A"tL+��.��.x�~�UI��v.%ֈ=�"�(D���3L+���l��f/gthD\+�`�3 A2vYHC�=D
Gect�-�Env.GAME_FPS * )�, .f3��(v, *��t�m�%Settin#�Q		\meDZ\T>%v\�'e(d�A --最[�帧`	�/s*	�t��>� P
)� /�3T
�*P
 1�t)q+�"$+��2个模型动作x�-�%$�$�6|/(3�
End(`<.,�#|"<jDXq�1yF	#4FPB-� )� �"�FT.�"��		lWue�W �/h.��Jd
`+lTh7s%8�@1(PB|0|
 	(�� .��Se%0i%�")�, "/l@E+�"L"L?��#(Nself.%�#S"ua=� �wret)�W-- U
I+�U���"d��()A 0�x|v�er(�T'�"�sme.CepT Msg("暂未开放，敬请期待"�8		h'�send��Hj:C,`7#q".)�@�)4 TH �� �'@.t (�$l@--没$P_P  直接从外面进去时DL-'$!�4p8�.�)�(�:�6 5lD"�1	eLjH�*�a\候 �#�G�*��&:9d�
�.�已经�其他\�@%x)v_ol"`g�.`=p�TU,+LTV|h	.��~Pr�w(�X��\gDf�, ��DH  �(p2@(D?�, ���%-�XQ�gD*h PhX '�3'� #T6.A�b"��$�Ft%\F*8P*'�=�-� ,2,/d�.X-�12�' 2$'�P&�/)�v&il��*$@)(d *,5�L�-�E{�XinX�uFuben#�:assert(sel'�\-T0X\0��6Check��-� 0�'�<�	�	+� �7,��Role+��:��LtbLas �z+� 0zP8&�r�+T�"\"��lateId,��4�	L"Di allBack({Pandora.On�, �, �,+T;,@ UK}$�B'��1S$��SetR�or%��Q-	�/\@F(<#81�FfOu�)'H�Gir0� = �(�EE,324, 't�X	�i�2<"�YQ.	"�(l��zw.b�'e	"hr"T`�DataElg"(B("98002", M#:H�*�� tostring+�ÐD��	l&List)�ۥ_	x Hnx ML 5|�:'��:Inite( �:.tbAccSe#d�\U%0b 	--初始化�#��信息
 �/ClientDEP`"4LNFiIo"YtY"/�.ini#0�.�  .Network.GatewayPor�utonumber���D
2� P(/PX�Skip@.(h = "1�endLr'td-��Ld�inValid(sztD�L�"DY�=T" thenT<"<*cUMes&�a, "请输入您的%ba��"�&	%�[|p�`&�}tx'���nl�ol2Utf8Len)�d�< �s> 6'<�	名字长度Tu在2~6"V8��K内��|�es�e.fin�'D%w") E�x�'Available�# 4x��含非法f��5�else@�'�h#�1M&�N"�ELEN > 14*3'�9�I$w8H(� < 4 t�N<-�M�:太短5��7�]xt �过XF9� Up|SL33c
^%d d
 不可以数位开头+�ix	�bxBx0��l(��\�Hvn�Hs'U<  �8  `	 ��nX�ԣ true
�AL�--从g���"H:帐号$���� --到时也是�#�>移PUi里了.tFOnSynAc��(...x�
--TODO 改成D C调luaS把n�clp�T
Hҫ传O:来HW�Wtb"�$Q�{"ԑ"�i,v in i$� {...} ) d#���[ v��] \v[2];X%4�= , nM%�T�#1�"3�-�t		因为这是P�加载��之前'Hd/H�Notify.On�(Ui� 	.emNOTIFY_SYNC_ACC_SER_INFO"-�/�GetA(�p-$�- #&+�%1or p)P�4t���感@�据，如果存Xf��܍��也T�用请求TAH9�	
 获取本地T 暂D=TT\p
�&D 	知道和服务器上哪个P最�h�
�@A'�P:$�&:\ (د(� ��-- �"t)*[sz\ount]`3�+�&CREATE�	RESPOND_CODED)4"$\G	有大侠叫D@T�ܕ�G#重D$�%！�"���包�,g，-� ��I�L���须N#2-"3$字 *� 伺�\0R0��@@过多\无法$T�x#���*h ��'(关闭��功能�此p��只P由指定̀���da��T~mat("一q-�p�下�A���%dD�",�`MiO	@),
�- . 	OnCreateRoleRespond(nCode, #R�ID|lT� +��Ui:7�-selfDr6i	[�	]"X/"未hc��误！��失败P�(		{ {} }5 PPK�意"}h�Z �1TX/�^c("1�H-�Lx&J$;��-x"�<#dL#�n"�8"�'"X&�$n"�A�`ed t%�)�KinM"p�QqC��,�(� #Ю'�%�Un�Ntb(� s�or $�'� �+ 1&`$�> #�SYJD�	�= 1Q�	�0I0:x)�+� [�]u6	.^= ��C�Save'���	/�=$�F��L�� /PStop)�xT]4��@_-� 3� l	�	3x V2ni"�R�/`CheckShowhProtol�G&�*tx`h�vn	��G"(�X�(+��AAgre�+�(�J tbtlE�
%�%\)�=#�EL!*�
mentPanel��e,�6"$��
 b�Large)�nd6,Allow�&�0�nNex$LN"�L+�Flag("+~ ")`6�o�LeftWaiting�-D- os.time("`$L/�fnt\'�('�	)� m
U"�F,� jtCl)p�)�Dx�;\]@n.�> 0'�-�), "�D���连续"�K����@�
次\n请於[f@  00]%d[-]秒后进行尝试NR{{�},x�P�
}}, {"确认"Lq .�+6re"�s/�  <= m2el?/Set+(},l#0�nFailC"X%A1C��Pl�?�E'� )�+� )0 į�X3, (� pP4�+�@*���'0 >= 6#�;�D��r-�	= -@ + 5 * 60"<0 登��:超过6次H8
, 5分钟内�#?再�DȂ($d(�F-�1	1��K�J3�10tH3��<	C�5'�+�@N,�t,4kRes2p�Clear�8,�`
�)� .�H�4�Connect",9Way('n/, Kuth�, nL�tfrom(�
Ne#dX\XC�.C�!) XT%� szdwayIPX(� .'X (� n�Po#�Y0� `XL? -- QQ和微信平台可�l�hE��的|	P地址T@�"�`Is�ByQQ()'P"��or )� ForP)� 	7@iOSQQd�or@)'8 W			-�to%4])�*y)l�*� �	h_]	84Android "D.$9UnY�	lL))ByWeixin)@\*l)�  �WX't|)\�$ �'9[lse �',L] ��-'$9T7�Guest)�)d-`;*�	L2�
��7�Ȑ-�
Ui.FTDebug.+�= ""��*T @*4� t=-�)� +d h�+T ,d*h H@?��$@�FreeFlowq�(��)r Pf�'l HX\:|��bPCV%�,I�R%��ChaA�lhInstall)D Offer`�zGe$�(Extra'�		CoD��L�H��4IP, *�,X%dG�0�`l"�nePlat"HA_None"
=		 ��(e�k ?��pf\2�/n�5Wa*�,&.#xm�E15i8@A"�+Open$l�("Lo(VTipsP�"正在$l"剑侠情缘..T/�, -(-�:E�N*$0�LdAddCe"�{#���超时, 请$�L�#�t	rCl)p.*��!} e�"'<�HJEqui�@\%\X.��re#,HmUiManager.*� }&"���|�thenX	%8 \Apple'�,� )� "PC"X�� /�-L	ICCID("�" 	�� Q�"�XQT�"<���狱才有H�"'l+P P�� 
--%lW
��机型号�"�~, 网络类X
，运营商.�`JPh\mBasic�{Yl#�0s�, n�sromHNetWorkTypeUT"�omOperT{Fri]sTGameЏ\�t,, 2, 0� #�Ship.tb)� n, #D�VERSION`d��9\	0,	(� �bn�al/$zne\64�NUiT^�%#ɮ(g\		nl"+\$aJn)�P1)� T\@ NETWORK�nINVALID,*N 2G+9 3,8 WIFI��n)<4�)� � TELECOM_TYEP_UNKOWN +L MOBI ,,N UN/H lIGe,�DD�&@A(Apr�"�Ld*0~8	n)�)� t)X �)H*� )X �XRNsz(	tostringX��#H,"unkown�ps�`@)� �.� LP{D�:IsP��()'0s)�tl!ssist)@
h�'� | �DĢ'm ,X�, p�fllb��p-�,#�2ZMshfoStr\or "{}p"�0X�"�Y#�NcolParams(x��xnIsEmu@�V	= �=P&.�,� . (
()��{&0; \$���)L)�2�IDFA(hGIOS'��.@!�VIdfa()hسp��"\��xy新�T���实\�	数据上报{tbXinshouTransmit&<uTgamenL TN"jxftr.	o"��"oY�r�chan_�cod 
�J�0p<GId(��equdidL	�:\�]�db��
stat_"8O@"2015-03-09 15:00H �account�
"�role); msg|�ep�80T4�#�gX-ANDROID�.�X�1e.�androidw-lseD)� � iosgnd#�}sz$��JsonUr "http://syonline.extp1 .xsjom.com:10021/custom_�""��127.0D 1:3000/Y.�Post�#��b?(n#dtP�etbxL(self4H@E�.s)� os.date("%Y-%m-%d %H:%M:%S$�&�*EBA�:��(ar�:me.dwID(e m�<stz�.fFMunSk:%8�(@�d�LClienp(CurServerp��QR}Ui&�'d%WebRDX"�9"'�Enc@^e6(�
) Q&e�:-DOnNotify�Ba\ed(banTime,D�ErrorMsgD'HI[Box"x#P/"Mes&��LTal nPivo"Ǣnil'R sz@f"LK"4S� == -PF�\�	家长禁玩E	�3�Big@
"�!��D�P|�� ~=(d;'\t�XT("%��#�v已被�设定为�"T�无法登����戏。\n"ԁ��疑�"� 请拨打服务热线0755-86013799�"x\谘询D共筑绿`��康�环境，感谢�理解与支持X'�f�%�^sz'0 \�"违反�规则L'p�6(� V�Nop@Noti��Yg�m*� "(%[no��_n�%])",H-LFhH�+� t%2�:p+�t1%s, H0永久��\�.J
	e��*�$��N*�*�c(�'ht`	| (x 1P@1解除���: %s/Z, pp@�t'Str3(ba�i)^!		�p� U+�}s|c�\|Ve, $BdilD�jxՊ
-*Is�.��(d-- 韩国版本@W论什么��都是自�&BZ��$��\5&>*�o��tru����]> ��bIgnore'$7S!Set'� (bhl3@Dnot �7>Cl"�^r*|HT9�	F�a	i"�v	�sz�WorldI"�mX-H.| FileSe��(� � 1�
�0re#�>�b�j�fa@WH4�Received9,P��4$\P(�z
Ip�	P<-P�r*�(�(IpX�X4�Set`'�Nnt`Z~ Ip|<VT("S in:-� @�.� x-�= (�e�1hb��t'�I`5`qSplitXp@��, ";��self.(�(*[1]' (� *8XJ+� 2�V("d| �Url:X4�'T�(�4� (} Ih*4(SinS�WRspH Addr, nPort'��:� '� }z*� l 0�and�~(d�Ip'�s�L$4�|
�	Connec"�Dld�-�H�/� CheckRoleCountLimit�\��tbh@HagLis�Y#�>=�4ܕ',,�")�#Y[t+�'每个%Y��6��^��"�R可以在��
内对已有�#���$� ��Ș操作t4lX4�)�c�T��'�t\�6��OnQueryPf"�)�G�"P)'�.� uz)� \5'X�P0Lib:De'�*s*� }�{��J3tb�.\�"�&(��me.Ce&0V'� msg*�sendT"�7SetSe|��
('� pf, )3 KeypTD�V#�^WayVerrifyRetCode)GNot\:t�GATEWAY_LOGIN_RSPPEt64h|:uO�wayHPoSuccess(n�)oGat"��)� \3'� x#H|�}#I$Hv'por �,�U&�On�('E e&4�1��	��Ph�4�-{Has+�) �+�eD�M	:]='�'x�-�%#�!Pf��td��=ei#�!bSe,<
F�, P |#��3�.bR%XjInit�"�/%l�7<#t�ROLE_LIST_DONE, �
OnSync��Done�`I |�=HANDED�@b0
�p�,\= true;
end
  �  