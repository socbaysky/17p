 (local tbUi = Ui:CreateClass("EquipmentEvolutionPanel");


l.tbOnClick =
{
 B BtCoseX	funcp (self)�D�lHWindow�.UI_NAME�endE}'�UiTextSettingAllL�Type_'p'X pTitlp"打造";'�ShowTipT"*可� 6阶黄金装备，*; 的H镶嵌等级和D强化�	会随主角�提升而�)W$Nam4|szCost,x 消耗@�}��Upgradd	�"+�T\Xtl )�低L*�Lj��\	为更高一X\*� 。若�-k 不L当前最DXD�所需HX'氏璧数量将Y'�a�PH\差越多�得z��)<)�)l ,��	P/'	Hor�W 8坐骑与��H08Dt2� Th4l  XpUC
Lg'�`u:OnOpen(szpF, nItemId�m�\a�or "x(d" --��M�'qz.�= �(` t)�tP�@�.1[�]�if not �.then�preturn 0�aA�
�`:Init��List(��`� +<`.nSelec�IdH��else�x4� t:GetAutok	lctm(�,plh�-�+H me.CenterMsg("您身上没有符合条件@J�M"� @ 0|Q )�|�$Info��,1),�/4@}[[以��该7 �&end� v$.p��:Label_SetjE("��",3�.���'�50'| P�6Lܡ:TButton(�Ls'd6XL|�:X-�tx���6X(E)@�`:`!:UpdL��9s(L�-c Mai@po-�L���(D1Active("jinhuacPnggongNfaH`)L�8)� swjie:� '�1�ModelkAure@true)=./� NpcView_��"p9Role"|"'`7� t]((� , 1124)�8� etScalT$t�, 0.9 � ChangeDir,�80, �,;
ee
,�4L(>tb�?|� = {h�t\~dE'�=0�+�--直接传P�图谱@道具i�x|
�	就取对应^10T�(D%@� 列表是包里Ҙ��*T!�x
&P*AllTari�sP�| .Gold�|�\�"&t*���-(�InRolex	@�Findt
InPlayer("e"�+))$*� ��{}'�fK�i,pl	
 in ipairs(tb@*� ) do'� t/� Id[�.dwTempl_zId]Q1��p�C`l en�, nSrc�)�s/�\Bx�2�
],ll �#vBa#�$Km.X�| lProp(��ch� �szxt�T+hk���, O6nFaB�on�Sex6`tbDataP
( '� nPot@p.EQUIPTYPE_POS[tbpa.��"�#](�p� '| X2� 4� sz�(�4� '9='d5� �<X�%5� h�W'�  --��@witemid 是 目标M L�Qi(��} b�UP`�4��d� �@tb�p|1D<�'T� 0�WextDm�M\tP�+�,�nh�d�!)[1]EoI4��J.��,09�b%�,, szMsgL%e1.(;Can'�(meLy+�)p3|��D�/� +�`
l 	table.insert$(��, ���pl t| l �+p,�:nKin"-<�#�5" aJ1 U�0'��t's|N = LDT���s(�D-� 'P	�4��(`
��\P,�LT�)��HI-�xM�B==&54�, 0`�'D� �Жt&hܘ"3xEn(n�&�6�P H�544 $�Y \h8$!)@��H%p;x�*H/� 	�d! N�d�L�62�&LR4�7�&�j,��FirstTw�+�@��`YtH(t/�%�7�.�/'� �| l -p)D�J9�	�#l"L�p�1nBag(L
�lD|=�+���|x�'8�@� $i@ Mm"t�*@B+X�Hp5YT$-)(�\����Ip�?��[+�P'�.�sT�x�x�tb�lH%�''� 1�%)�t$�%l )��-?H��?�nd$F�!'�+�)\l��@@#@8�3'h)� ��, �	dwd<) ' &�X_|2'�)U[n%�)@�x#� ,$)#)tL P�U,�X� �pxVV= �'L ,� �A D �,� &�!h�	d)�0-� �yeve"�\�Lx-� |D�,VId-� �?��:,� �3��+� }2�,�B�'�Afn%]a '!<($+FObj($(��,\CD('� .�.Id��p(h %�BToggle"|GChecked(""�D(�A�hl%�Ed(8�TE�`[`+$h-H(4"�-frame(4�('h .parent�e�l�
Se#|Q/TD$, nInde)t4�%� =&�M�Es[�)�3dX&�F8�p"/�T=%�(.`p"-d)�HStoneIconGroup@0#�&P*xl 8� TxtStD%)� �11� -�MD"46@�#.�o)�-- -�0�k(���) \��(�4+l*�h�C:D$nGBy��(��[�Cl`�'�`pt8| +0.	;t'� `M`l 'P l+,�STO�9� �[L�d(P��E|' .,	0� �y	.OnTouchEven"%�6� x*&�S��Fla"�S�+��8enTۄ�^'�6.ScrollView�Pgd:�jʅ(#�&G', fX��vD�
'HtbUi'�/$�C|$t�x!"�2i,v i'�I+d+tGMMv':==8�2��v(�lx| l 0�(d�Attrib\H�Src�P��Rep0%�Lf_,C+esc)�tb(�  )�5i%hDng.find]DL [1], "上马启动"),4-`�_,_,"� agicd|,szVay�s5X(.*)[ ]+(\+%d+%%?)) P|
[szM�	0�l+�5tbW , {)� ,HY}�%dl x,| l �� �4�	��-@���+D� cur#�eHo�E'�
�>L"�*�,L�.�YdQ2:Clear&�ax'� �p*XConsump"��c\����hp��|��PE$�Nt4P���.5d'�')1��X���l(0�0� 28� t"�b�|0� 3 � 0_SprA�19�6� 2L5�6� 3 � Rightx�$P0492|EdK-�v5� .f'T(0h2.Default#�(:�1H%�+H�hl 0�3;30+\0<9(
�(xl 0� 28:	fa'�n4� 3 � 6�(�hl '�6� hQ6�6� lQ � '0
6� (D Y1;Y11Znd�c-- �'@\�'4d�Base#Deĝȶ).tbh���/<TZ <Pdq2@��D	|m�C$��%�l���P
]t$trh(�l�J�.nL`
, nil, &<4�\�"$!��1�!\����Src, tbX D{}, {}� �t(l"Yt; H1 y`t�9�P�' �nextL$} "P)0D6��^-�4?��(����,nMaxLin"�5�*�" �$_"�'ii,L0",++�'q:)*�'�)�$1,$�$1T/unpack�![ii]"eM{)%/� 2�2*� p�-d3#4(p�or ""�tpi + )�u.D08'h%"�)" .. P)I2(�'� T\A(WVal)<� _,_,\1,szPercent�tri&-�, "[^%d]*(%d+)(-�++-2(,p)*�,�	2 -npH1tonumber(|(0�ph*� )�Pb
Lib:IsEmptySt�#�h"+Ԣ5�'m: X�如果$�	前阶属性�百分比�而�"���新增-� 显示+0%'DhPl-�'U21�2x�*i6"A
"+D+�ll ?@"����34*� �+�x44L86p*,,(ue%,�ll *< *,  
{Cur+u1(�	.)�/$.-Up�t+�.d]1�LE2)& > iV1,lp.�9�Extent��kormat("+%d%s",�2 -� 1,X��{)(�|C�2�ot� '8  � �"n=2 ,<+ 	 j"")X2x94-�'eTN'P.@)' Widge'x/li >= '+�`break��xt* ��2Y�ia�,( )$D �X�)�d�--r�er�	套装描述���
tbSuitAttirs,T�$X<NeedNum\"�#)kmGet�ribP�"tz)0'&'TR*`,�9|l/�9�szTxrisY"(x�*+�L*�) )dd1,*4 .. v[1]o�"\n)d�h*hl .�-�`@'L)d�dtu�/2) 
h\.H�--bottom�.()1F�Y��*tb�e\ting�VD7"�*?�+��
pSelxE[3me.%�mInBag'�?�|.�Li.(l�\'H,�(me, �(l?�",
  #�2ܫ&�n(8 �%4Z-�4p���.tbHideIDD({  }�H!"("�5x$�[%Q9]E1�+�
-pS,�, M�{�� P}) ; --d  只是材料之一�XdA9DiscouJ�, �a��~=1,2 )h�!"�/At-s[i]�d�Gri"���[""(�uP"i�i*alfD��+�(1nKumer, RnsUCm,Uu'7 OrgP'h3h
�Fh	n tbt8�F�xd� �1� x*X2 � V�Co��!, �'`�1ETpd)XM(� )�D�0�Dpl �5n	Ba:ԩ(,P.�-�`+�(.�sz`,4�nExistCh<E:m'����s()T'�t,0�uD,�/�	d!=0�strA�.@f#l)%d/%dH�)�,,�
)-�+$hl .SetAc$��Di'�t+P-|l .� -()� H"�O�*,�   ,+/8̖`l 74ColorByrG("0,,� > )E "�"Red" "xBWhit"p�x'�/X�h0dG4tcp	.�).@Яt� 9� 0�-� "8%�'  T`3�!��",�loca"��EtX[Xo`,� ��'�*Sr#��(8	',�"h)me.Fin,��tb�	.(�1)D�$l�掉的T7 稀有� @ �pOri�LH	�d=(; [1]'� @"*� /4�/(�1"]��()� .dw&$y] d.� $Z�	.Btn'�%��/t}'l� ...)�6X3�'@#�"`Z<� ",�hc:Do'()��/��?*�r*�l-8u*|�L"%h
.��+8XE)��请选择&\�$T-`.�sl�>�DpX�H�7$��)+#��\K' a	Obj$z�nS*��Լ+��$('X`"�^#�_"�"3�`Ht%�@�(4 T'�^Id0t,��$�(��足-~�''�L8x'< 7��)�H����+D l��6P�
�)$�szM 俜)��p,�@�
+�p!+��(��|��x�
RemoteServer.Ta"H�(�)p*��'� ݅:$��"Z�En"��d("*Z",&/x Timer:Register(math.floor(Env.GAME_FPS * 1.6) H'�(XuT. (p"E )$��,F�Do'�$X.hZ�,0,ym+ � 
8�l��p�nPp 
,��+l�=(�
)�zK, �EXe�.(>Can� m"�=�HT&H����l	,,@�+8m?m*��(LD2�|���R*�
Reques$���� \|t-�OnResponse(h��:0�$ji 0<�<fnQH``T.$T�/N%��PlayAniXcion(*��"qhDj0.1, %�[@.'c> 004#@�rQH,t t-�:C�Խ�QH�$h|)| m l�UnDeD`LT5'\* 2 - 5(H�/n`r= �(\)|5l� st�(2't	l �
)[nil̟tl T-`H0��71�#|l � 0
(x� +X�| 5\shengjiec| %���l�o`� *�+� *� M)$�)h7���-Refreshl8$+ 5, '�(%�&l� 5H�8�� l	%� �| �$ܝ��s)$*|l )� "�5**x�!`l P�&| l /��q�ea.-�= '4�t$��"3,` /]S(�>-��$�6�Ő
/� ���(<�&L<�.4+�;�2� �p$2t \�'|`'l -�R%T!#\��4��tIvg� =�/(|� { UiNotify.emNOTIFY_E"��_EVOLUTION,l� �(2},�]&��� (�;
end
  |I  