  local tbUi = Ui:CreateClass("WeddingBookPanel");
l.tbSettLT
{
	[�.Level_1]D|	szBtnNameA"HTab1"]	DContente @  静谧的庄园，邀请三五好友P在漫天飘落\ 樱花中\n许下对你D誓言P这一世l��不辜负有�	美景。\n @ 「青枝连理栽C晚H	悄自开」�婚礼流�@ +�[00FF00][url=openwnd:迎宾, AttributeDescription, '', falseH�)	Welcome']、+$山盟海P 
<Promis1<拜堂 
$Ceremony1h��心爆竹 
@Firecracker1L��席 
4DLleFood0,派喜糖 
8CandK[-]�V tbTxtScrollViewResedX{20, 100}�[nRowYZ4p�-}2:}2�sz-寻OX方DS翠怡然P\KA岛\S�e��朋�e齐聚TD<B\nPg	琳琅满目T	红灯笼与DjH
若舞�鸾装饰Tj@�k此生永\n@i更改X\QPmHhPgT
H比翼飞H侠少揽月归  G���食同Xr果, 	�MOcL�ricFurit0-� h\Ұ��_�后LM夫妻双pe��外获得[aa62fc,d新郎·��蜽, ItemTips@�h\�nil, 6156/DG娘 	7 )56)3:)35+觅p���乘风破浪hx��舟f(��W�四P�之内T有缘人@��	极尽奢华\金龙W 凤X環繞T��八方d��见�A��\	F�\nH�] ��情DG�系��@T
\�和鳴D琴瑟f��L @��轿游襄阳, 	\TourMap0=�  �  w�[-��ff5785�����, |�4�8�	*8,� 9]  &'�}
func"�-#�3
:OnOpen()
	W$�3 :RequestSynSchedulexend
3� End(n�#�3t	self.n� = +x  or �&�4
	`:SwitchP�tainer(p�P
3.� �U	�t�X)<IfD+d	, v in pairs�'�7) doK	if-1=T�thenh��t��'| X,freshUi0�	�		$X:nNow�M	(�@)(p�p#�: :Toggle_SetChecked(v.':,1 �d	�x�Titl8Re7 +pX,< ,D#�"h=(\=|(�=[+])� P�(� �.\��'(� 0z:ot�b�Yn�(�  �<returp=(�.�/YAClve("�?	Apply", truep+��prit�4Gray+� #<.� Labelp:Text("�TxtT"申请�#>".� Button`EnablTA dBIekH+ P_�,�y �46~=.\.4,p ~'ur�/�("Scene^tb(�LfOrderUi�Path�["x�ent"]:XLinkt(string.L�mat(tbUiT"�HT	�)�1�(H=p�F�c�/Cos"�=tb)�nCPXa+	etA�Q\�X	'T	�	@ySchei� '�:GetM|xd���My"LTime\\e+� and nxR*U )'��bDueT�x�rXbbPlayerhInfoXe:D;ckOverdue(�'� Mx�`)h�d'�+(P/,t�*	|�|onumberL5.@(	+P-$�+"＊$M�p已逾�"1	需要缴纳"�1��的费用重新�x�w		elsn,		 L�nC�			�-`JX1^9apP(�XnMiss�	@ -- 过@差价TB(�\C�+-}.#�!mH �F|>�: E�nȉ�theni
	+S-�MainD[(P+� -�*��T3��定�.+� <�'			nM'T = t/�`x�e�,� � for i=1,3%y!s"�$��e'�"L)" ..i,$|T|^�5� p4�%T#'�9� *� �7�c�3p
(H�ztblL�7x�|tdz'�py	�h� in i$�%�	)�!Əszd#m^"d�!�*4<�L'��nzIdT�b[1"!	�]�u#(^)� 2] '�[���Genericw
({"Q�mX(�, �	}��K(� .fnClickDl)` Default���Hav"�`me.GetbCo@InAllPos(�3��I-0�SuffixPstri(�"%d/%dYnx�)"�c		.(�L��,it�0�V�|1�Cost'�
'� 9� T3� �"�#Tx�R�stJst-�L+xd(�5�tyP>LxSelect'� �9Now|T?P9d��xn�h��L��&t%'�5pFull��'��51�x]t�3*D-��"��时间：��后立刻开始"`(�n�\"3xIZe�� @ *�Se'�0M 5� p
(.�   '85+	--p6)'�-- �		L*� 4�-�
-"%sf bM(�fn@KDateStr()�))�3--�\�+zilP4��{-VSe`["8s@"选择日期"��]tbCa�D@�Y�ðSchdul-|'+� )� ntx'=)#� tLW"0A�]��bShowxH\""'and `)H�*	S((
uKS�@+(-�+5 p�s'l�*� -�(� -�近L-�@ 预约已满，请%s再来吧！At*jszx
lCh'"晚点"=�Btn#�$P	|+�I 	-- vip等级不够时处理D,Td+nNeedVip a2m��T��() < 4� �ks4�$|�,`C�+*�  p [FFFE0D]提示：剑#�n	�享%s才可T.定该�0"UN,4��+*!S(|	)\�Xp�)�Yt�-AwardHYp|gt[�,�2)� |�fnX"� \&�O("�"ObjC�Idxl%�#tb�
I$%6t(�[n@#�$�9(� �2	�
1�M.�.�["`frame$=Gen'5%t($��+� )%h	D,x .-%e��		�	8�'1	�1� }/.l)Group:UpdG�(#t(�, '�#�$�0nHeight@1, nWidthH\1unpackP8(�@2X}` �бResize(�@Bound"C&0~Ut-+T#~* ()) `�-tWRefreshTi%�O	"�.nܸ�u,$�Tipa8�T*�X&�(Mark" /-<(��'* D&� 
aO	�VM'j t&\9t"�5 2&�1$�"�,,�- Txt%d_%#�,��"iH+*�.sz�x�i9	�J	.j.b"�$(�'QM'�C(|����
�
(� and n��eq)��L'� .n`� == +H�l�+� t/�;"aTime)��szML=". = "��"
	` �<#�F=#�' �GHX;�'XL-�#F��]M	+tdt/D
�4�_�rue�0:	� , �|!��� � � � -[Get* ', t	�)t��P{}
�v_,�t(�)�_B)me"p9+ v[1](It'cv[2��	break"Q~	't0� �	� re"�\ �
�-� �O�M(�= �n 
��#|J@'+��
�Ft-�.� .| '� *�\(D)�(� No"�\'XX�L?"�&(l=@6*E=2�r> �) ,�U.�+��4^Z, (�,/�KX�7	���>� �-�OnSelectxFinish(�|t�3*8\.?��v$�lxUH&+���p�x@'�
	t�'=  �9�"�|�D�*�("\6,�$�(e&�"�p$8o,(,y"0�5�+�m�-�
RegisterEvent�I�+D� =
	#ܪ { UiNotify.emNOTIFY_SYNC_WEDDING_SCHEDULE, �S, w� },]		2,�DATE_SELECT_FINISH�.0\��
"P�H�Otb�@�end
-�Try-�(+�)
	"��loseWindow'��`S�1"pself:>(�tbUiA�O'�Of+BtXW = &Z. (t
t .� t.UI_NAMEtX] 	%��4�m:1T�k#R _1/92 92/93 93,8M�e"`U1Zif"t��;Visible2| == 1(�me.Cen@fMsg("请先0�Ƞ@H�o��s"�:��p
'X�*(��X)� TP"H%�'�h�Detail�Q�a.�,#�> =2t	loca"��MapS' ��>tb��(� [),l���o"�|(� 9<H/%)'�.-�+���DayH�"�+Startb"(t)0Cd�,*P (�() ~= 'At&�/	,D暂未"�R���{		)0�9��I�tU.zLA)�NNckx}�('Xd`(\,�sx�1�enE�	|,PA�A A�
�0Engaged)�Get�(X'dwID��:n�(�P*���"X���系的$L�才能$D0W礼�//4��Pp`|,7� �7�> 5h -or 0) 'l	,�没有'�HE�)�T)��=`��0szBoxPL(D XySche"7,\#$)x�OP%+� 58'���d\
*� .�i	�t �+	�#%��/�`:�+�t)j= ؁H���(� [(����No$$-,@*��-- �#8{�Q(na>�� �,		H	WZ订�
档�
hy�G���p�'<"Lа?F%st+�j你G定HI�f&�R%s[-]已�#�;，TN以补交9ρ。H6464FF]若�其他�需$�全额�#؂"污�@"\���续预XM	F"�T���？&pTh(�.sz�8"�,, \N(d+l ��	'e&�,T,]k�(�.<= (I )|+�0�当前O)经�了+`V�p�"�Ǎh�p�p:�$�/		)�		'8=� S��� V\nE6�>(�[\G�8�?PL�=P退还 /,��ԟ��f�6H_0' � �szTip]"(���在举行T�Q$�,T�T��T�!�( #(� 时长大約为25分钀Z@z� �Sur"�~"��$�IP�*�== �_%]w2)p
�-X
�将_
期DmD�)�", Lib:Tim#j�11#Q1.�*p�Psz��\X
hXX�R>�3)�� nWe#�-xGetL"�)h. �ͳsO�ek1P8t|"<�PxPfBy��, 1, 0� ���	2 
%7�T �	s�J � ~ ,�s�, �#�3	t{9��`	r:R%�>(P(y� )  me.MsgB�(s|#�=		"l9S	{s�<,)�/`h		RemoteServer.OE+d"��R$�("Tr#Q�W$@�DJ)�
, �|�t"�`	c end"4>h	{"取消"�}��HlxH|AtM%�#'\	x*�D\, {{�~�WX��,�}, {'�}x(��(`�n"�-H%�<Selec"h�(�'� D0.MessageG") Uz1'�	D*�+#H*完成��操作"�)<P|!H"41$�/'�7Date;�7}  �<  