 
local uiTips = Ui:CreateClass("Equipl");

function� :OnOpen(nItemId, nTempl\	Id)
	if not*T  and�� thenD	return 0X	end
� 6�End3�FFa�, szOpt, tbSaveR\ omAttrib, pAsyncDataCSexnlod!bIsCompareT!self.UI_NAME == "��"PXtype((;) ~XuserdQ"�3� table"� K --最后一个传nil会在初次加载时丢数据，因为有链接用这个格式就不改T	�形_了]	(�TT'�	n�'|�or me.�]nH&`x �HPL�(pt;L+ValueA	�szName\IconX ViewX QualityGMax�4�h�0fnBtnClickC{}LQ�K~Id�(Q	�EK|.Get Obj�E`=�TR��O�P`�O		)0H
�YH �.dw(� T )� �2���ShowInfo(�+H D)�n� '� �\elseY 	2�H(� +(�(�T�<D��o	�/�{T�\�(p(4 �3�=tbtX+BaseProp()�hXit���3��h*�--出售D�nPricXJszMoneyTLrLZp:H@SellSum�(�O(�H�dD�t�:nCounta:1h�� �L
�p� ,�)4 HT)@ ��'�
�pPanel:SetA\�ve("SalX#A"S�rue���Label_H
Text("TxtCoinX���#��m)2 At@�@�$�'u(�p(�	+�priteiS�("YMrol�ll�'@��	'�
x��P2�faD\�l��JX>��化等级D,�
nStrenghLeveld3�/H���Player��"p:�m�OPL)p )X@��+t|%�t�K'4 �) llM�J�Posy\eH+�Juexue���M	.�SXuep`VXiuLianLv(��
`%��*@3�	0�En�'LH"+" ..  + �1+
)�\O)� t�V|d+�(�,� /�	X=��标HU%nx5�h�Y�0'l�AszlO�M`Pp�TX6l&�']�(�	;DyL`G\!�P,��_**� �����=\* /T^--�`限制与描述D*�0��TLimitP	string.formaF�%dDjX��.nRequire�)p�p���(�szCU�sl�L,�����)4 @�6tb�Di.�[)� ]�z(�Ù)'��\� �["default"��ǨszRan"&!""XYKt�|�dDesc'|'� �|H�.'l�/�阶)��,L�+�	-d@�\}L�Custom�= 1D(~ In"�*)d(h X')|(\ �'�$|��0�)D
LostKnowledgeT�h�4Ŀ-|.� sz(,���x�H�,�'x �"d�K%	sz'\ X)�'X x28T�REQUIPTYPE#90[�]#P$q])T'LH � D0<-�|�#66yph*)@*yb�edD��D�DtbA#�3�i��'��p��H)!o"�/p%/bNotShowAll@(�4; @� ��自己背包里的装备比较时是不带����，但\看别人3� *� Td�$�734�>	,��"��-t�!.nT�"�6�5
emITEMPOS_BAG'�� pCu$� ^meh��.ByD��	z�		�'� and '� .dwIdp�H)3		)hgx&P2�`�:, n.�4@)�H~�, �<, )T�n#�6@�!��%�Ct�"�@�'�s(��nFightPower(4(L H
pPj($&RefineSton%D<d+,)hX`(4H��:F`		�h.�[��4]3]#!8w == 04P`�)�(J		,�*6 + $$&lQpƔ(�(�)%2.n�) dW!Mgr|Inset � Q+	@ �D) ]t(|#�+�	p�4t�.;$�x- #H5�,�0�T+�0(��DL8"战力：".. tP�"u"(),));	�s4�0.Ttf��!d�Sh�(x<p}hEqipdColor�e�^ed or �5xu(q)H7���],nt�'d&�>@b*� x��Wnot1�J(�	0@K\
g.tb�imentyC#` ��.d�4 By&�<*5,1��!'It#@.�p�1(@'�@�`"�@(x *�H(bHas*dO\��q� /p "�L��0值\�
则以随机�#X+	进行计算if\>_, v in pairs(1�L{}) dode�vp�(j2		/= tS�ubreak�e# 7�3t	HA 9� h/$'�;�3h
(pFrom"�V�T�E#b,, 0�l"QI.��"�%FB		�&		 �)� )���2� `&"�FT�`A�bh�X?#t4a.%l+)��YpedX���x�@<�`szIntroDW��@A@t(��y�l'0��#X4(����h$(�0T�D�
-���"<;Frame'4 Anima"P`h'1 A%�It?pТ�(0�"]h0t+/�=��(pvSsz'���*< ~= "$0^)T ���Y1�'W("L"h#'< �'4 0��%�(nEffect\4-<�(��h q �+�C+pd��0`�, 1�
�?��+�e'�Q/t����DR--名�x�QSs#4_(,
)h0h	Titl$�2"(@�
�#��;0|�(/�)do"White"��*L'��By`#�T,��(x星�,nQar��)fSt�\�,&, ��l.�{nBrlFhDXdh.ceil(nd�/ 2|u�iL1, 10 ��L,* >= i'�,,(Sprl"..i%�X]6	mJ(*-=l	"82)'% 2"~#1)(�,�/<+�"|_02"z		�M	 1���ls#�c,$5��Vp�:��X--按�"�`\*#�*��m#7xrInBag(�Ct#���v[Op}�[�]'�*�	)�BtnGroup\�`��"�BIndexp=�Wh?	_,tbButton iH $�!�+�)�C�gfnVisibl#�c\d]	, fnCallbacklSowRedPoin{�unp\DW��_	uCf�	h@|dl'Q (i)'�	�sz�I"X#�Xn���		+��"�T#�b�d�Pl�$,� (@(� x*� (ppH3�]If'�,�bd�H"�*tz<fn)D �NG		+ (LwNew)�, ���!P�+ 1X�
�T'�
	aAi'� , 4,�� D|�i�	t3��(p�, �bZ		�5�%(x�'4th�[�H�_ Ui:"`�	Window("BgBl[NAllPa 0.7, Ui.LAYER_NORMALL%�0�@+�%#e�itbHe|�F"{}x�Q8e#�w\'ł(L�mObj, �1H�Btb"�OQt%�Ls[�#�X�]n'��	#4("nt�XXH��jt��H�L#�0ScrollView:Upd"Ǆtem�Ts��	�"5� (#t�, '���6 �.� GoTop(' :CheckdgDown(P'�'|$�0� �0`,@C"�p"dE-�'$'�IsBoO�m()8�Us$	m(H`�'`#�0)yMr#��tE��<bRed�$A?:'8���!T�l�&�(0L"$�lose�`�%(�t�.�Unus ���= '8=`�" ���TP��7@
RemoteServer.)|�$�ST �Get#4Pos(�2D�sz#H3b�"R2�P�. h+�CSX�#�t�B'�BId�+��dF&�"�
�n�D�6� 0��ment �	 �lVT#tO� 5��
'�X�x?"6�� al#ܓ'TZMm#D$�$P[' |@(� �X?*�(<#u�"��.�O, ' Z0Id~a		HClos6���6X�Enhance �]:l�pHL &�t*@#�Wgt%�""(H -x�!=7end"�%.�I"�X �� )�Sell �#�Confirm�pe�UH^PD ;ExcTRge( ... D	 \fnAgre"<�'�'�2
 � +��w'��n|Jp�Gh �7�X�CenterMsg("$�o"�o��在！#�	%}� ye�Wؔ`�A�zX@p|pP�+:Can'4��\�&,Z"کme)p|	'd@7*MessageBoxtNh,{{}},	{"确定"}x$�6�nCos"� 3�P�x��+�6�re"�XL�#h3;�trin(�收藏�/��变为外D ，需要[FFFE0D]消耗%d银两[-]D\	备上所有�$T\将会[失X。您�%�此�吗？\*�#),�S{ {�XP<elf.�Q},{} }'� "同意X"取\�1P"D!:`�&'l%*TrainA#�{��T* ���-�t� �DoUpgrade2��ZmentEvolu"A�""[_�\ 2	6NDo'�Hors X, ue�}.t#�KUpSKiĶ-{Vit#J�Sk@�%pgT7\7�=�	�3�vZhenYuan:RequestR$�)`#�?�T|�5UG]mpo�+Co�.'T :DoR�Unc�,d7�Can,��i$4�*|'��� # >'���p�ON�me"�~~In"�K*$x+� �3p@r�!�ٮ.n�Pos � hP��Rl][.!];$X�|.Gold����lTaru(�*Ķ(,K*�T
��"�I:�U)��*L3 Et��*�\?1D�tbSetting\p&)H@���(*\)�("�+H���R\�+��3X'� .�D�tb" x"�]X+h.|#���"�� < (� .+@�3TH� ���rri Tjor�t`zo!Int#Ɏ(�7E"�� _VALUE_TRAIN_ATTRI_LEVEL) == (�z�,�PY`Yti�?(�f"����在"����4个�#X]	，能进化%����示精炼%��3��?�s `D-(\;)�Lp�=0$?d� (9 �R��men$�@�^b@(` T^�2\��y2.%%<$�
#�,\+�/@H)��  '���.Is��XEUL1'�'� H�'D H3"�E"\A�W?�G'� L	�tbR',<�G �*�#]6e"�"�,(|;	@�,C9D�'4Ȕ#�F'� ;��V/�xr(�('5E,�, li9�"NLSe%�%X.+H	"d�s)0�'P $�� 'X�|t@�(X"��W�.(X�S#�%|#��'�&-� "`Ō�`D8�I*LDme.n�ÄEMgr.Min�Rol$Ȼ.x�X�&X%tHP +dT1�TnHP$(�p//Q <>X�)p3:#(!J(@)p`,�"t�xT.OPEN�� Y��n'L*���Po%$Y3�=� < 0"|s(>=$Y��"�Mw�NUM3�'�&�#>�)�\�,x�*-�X7�M-�	E3G$ikI:/�E6D X'�E`X�/�=  *�'l+V= �+D�ko.tb�9�t��+�*, m"|H�)3���U)4:,�*���#�*<�%���l  L �XL�l�'-$�"L�!�KnAreaIdHi�.n�ӼT�
�p�T�_+t�
�$H
(��T
� Lv�'�	yKr#L (� D	lianConsume(��D�
0"dr%`Redp"���- �tz��!<��(�|O(4 ��9TtInset+�'gone]�:#�u�U$�9Flag $AeD&\J+� @d�t+`>�(h+t(x.� �,DDL E�0' + ��S. CanUPY#|H��Lse(<T-�	@l�	�j�I\i *��wC$hJ)�J+�� �Xv"X� �U,��\]atsOpera*�T*�, "�#��:\PTz�)
$fX.O#� =
{P,{;Boxy	~	{q.t %�9
, 		"穿上",�&��"[	+� R'42, 	"洗练(� (t 0� ��,	\#X_(� �1� &�KHorse,	"升$���D-%X,�5d},  --坐骑的�	�	��H 面黄金$�_不一样T)+"�1,		X��售($b},.� �"��,	"技能4��}A;	+�'�,	\��分(�'p `Hy 	$��#!5 '?�, 	@ D+�下*X&���
+<(3, "$��(� ��,*$�R�� 0H��,H"镶嵌(<�	*8�90(K,	"$�F(<��}, @&+hĹ\�C(� D��,*('T �1L'X m#%#U$q(,h@�S\$���l*� }l[� 
InDifferBattl"w@) ��
J� @�2@ɣ,\D		"修炼(���	,P,�"�;��R��#(=50�ment]"4@t�	+<x��.�(`�p 00B(On$ �Click(szWnJ"seP�+ �L(�a4y (y)R-enp"Scree�(sz�Uix@�'< "��,!#�,x ��"أH=�$���24l	Close\\'LL"<X,<or sd&�)(+\ �>x
$|n"<=(� x�l '���D!$Y�V$��(+�#}[1�*0� (0�,03�<.x*�8�*OnResponsedT(bSucces#��\?� �T��(dL�)L=?Dell,)$�"�F%@L|6�	� �ߚtbO�Y %�$Btn1H}�O*�x�Y2<y 3<y 48x �}.l-	RegisterEven*&]tbD�e	Ԯ 
UiNotify.emNOTIFY_WND_CLOSED\�$��O��3d�		{ 0�  SHOP_SELL_RESULT,   �.O+8 DEL_"��h���: pHQ�&�.(>;&�7tb�ZA#��xBL(tK,7(� #T�)�//x�pParH,hS��H�D$R9sz"��, n#��, sh| #��`a2`��"�p�(h�,szExt'� LR= '�Desc)"��$<$有的T 2条$ �P(G在%8�里设�"<ȴnStyl�2Pu�6s���"�6\|PM3"*%�b"�E�'��
\"ѿ	ht	Lib:Utf8Len(�> 20 '� (q4d换�(文本uep�#~�if�+'� '�2p�"�`���s#8�(�(�5i�$$.'(�h'��!`X�*$�V26x$�F�+line1",$�bP9� 2X#�I*
193 � 4)� -�C#�Posi":("dVTQV0"DGd)�= 1'�--类别\O@
��0�Txt#l�@
"�X�
+� '�x#����F|)+� \Z(-lD�%/� 'hGradient�tOextT"Blue��	6~ic�/(|�_�h == 2)= �,'�r�#�Dsz�,TX(�@Fp�"��,���%z+� <)L #�"(< p1�eq#2#v sz'� '�6��T�t	:� |T�;�B	pE�6#�')�	�=@ (4.. "\n#�ϼ�t,�3� �e�o)�2:�p!�/,�2�F$ "�
*D'�l�Ft�xr		-- *� 2$h64, �i	+,'��=B&��XSus�F"�)% �B+��"�٦("�	"��)�)$��" w,�*� |QI0s,8x�$�KPԀ��L'8 $��",oJUxt�(� ��&�& P�"L�tiP�u	@ *@)�'\h�V�?&��,Ye'��+� �b�'	
n'�74�`'*4'�(@	�4x�*� )�dH)�9� @"L*�6� xt�6� 2DQ3 @P <(�Я6�/���1�
	�|&!(54'45�009� l�qds#H%@�$�!.gsub%$,L�P�z n"��*P1�`�	���tbwBSiz"�E0 GetPrint`��3��(�
 (.y�W|VT{(�5 ,�""(�elf'�/4#�Slo�G�Cp})�0�@fj"("�"�-�l�&>� #dKH%�(t8�-t(l9)�Widget_�UL0���y+�.y `�h,j--+� T.#�*�<"l!.(.6�`X�+e	:� ���`+� 1�	H�[1]�	�"�z= x/#�2�3���*���-� ���3'���<�4'� )�'8�*���-�	��/�\S-�*�0		+-� �6�'�x@�}�(x5��M�\�M����d3T�� I	��`%*$*�3�5� ��(�&�(5� Ma0a'*� �{Hjw("�392, �{� r$@�&�Btb#�?At"Xa|(.tbOnDrag %tI`
D�'�G(tj�Wn}yXYYt��#}Dt7OEnd X"�."?tr�re0h.O .Ch)8�'0%�Fg7endx * $ $�m$�	end
}
  �_  