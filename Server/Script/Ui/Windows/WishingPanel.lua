 local tbUi = Ui:CreateClass("WishingPanel")
{.tbxListD ,{
	"希望能够早日遇见那尚未谋面的一世情缘",	(� 我等生死相交T	弟兄，此L不改��	执子之手_与X偕老�心中无他求P惟愿君安好��X��K
人T�平t��乐+� 帮派�蒸H W上D越来T � �t	称霸武林_指L可待+l	这个江湖DD	�	热闹D'D 鼎盛+� 族\''� 帅D姐妹'S 美�D照香炉T1紫烟@�先不说D�在哪？",��纷乱P	谁拔了剑[成O侠O动LX:O结LLB�	�BH4P1掌中青�|;斩�TL	�下恶徒��=���@双锤C扫'� 狂2� �冷���X	雪峰之名�p7*�长���化愚昧宵小�/机簧��@世家)�*� ��握F�@+�伴@	傲笑红尘4�铜�TA�'�邪魔.� �U*�G弓HT诛不义h(W}
'�OnClickN~
U~ B BtOoseLfunction (selfH�X� i�lLWindow�.UI_NAME�end,|xf
he�3E	X	Open�	��e�Cp��, dT�Data4�|�6� 	if me.GetUserValue(AHvity.`P.GROUP, Ii+\  WISH_COUNT) > 0 then
b		P

CenterMsg("�Xs�角色只x{���\2�次许TMd��retur�	end�
50� 't�	DD-P:for |�1, 10 doX[Ȼ�<[�Bar" .. i]2�		`-:Show~"CoPnt(iM.	F
� '`:Reg\�erEveHD|*t�Kx {UiNotify.emNOTIFY_|+ACT_DATA_CHANGED�=On|=UpadteD`Y en%
,OniH(Tp=not Kin:HasZ ()�6.�	请先加入�ª��n+		� 0@)�� 4�End�p'�TT+/*	tb} @5*� Y{X�/TryUpdT�x/t'\:CleanSelectedItem'j .p�C:Set�e("PndD�T^TimeQ <0pnTrueTdl'�34�q 83�4�Dtp6�dwR6Id'��~=tx�X&'� nLast�&dd(�-��.� >= 60'`
RemoteServer.HCall`(])FZ�("LH
d2�C+�=)`XE�9..�= @x�6�#� .H	4�1x�0�|Name�|, falset;��:�%d�I�.,0� 	2 local bx�\^�#�][X�@5�'`4�'a,�	`ly�
��			�tbInfo/�h�szPortraitP�zAltasXPlayer�:@2SmallIcon(�
[D>, HEADID]��''�prite_UnS�	("SpRoleHead�/1�	�szFac��= �p;=FW�ION @�
(<�T)�nLikh�6LIKE]��;�8Label|Text("Txt��	I	�ƴ 3�	lFxP��(�dx`| �t	'�*;, tT��
�8-��, t��[*e ]0�CONTENT�4x:StartClosehna�rd�3T'� QtL�H/�4li.$�&�
C]nil��.HD
2�[@-X�h�-`�'�(Env.GAME_FPS * 5Pmelf.,��@/8��
�D�/<���$�))�Y	2��!9 
"t$P�`��l3�*`"\�t�xx�CH0���70$�l��tb\�PT ԏomanT

�LiT�"�'U1L?p# |�"�/bUi\@�tingT#�/	$ (y""(E{O 	tbhT"T'Xdae;p
szDefaultInpu"�@ "点击输入愿望（30字）"�EmptyTipU
"�	不能为空�Buttonp�|%�,�Desc1x	需消耗%s H 元宝�n�Pay\H&�(ishR.n\hCost�
fnDonp�')�I,sz��`9��bReX�nErr1e:#H$�$�,+\X"|"h'�!	,�0X,�tbHMsg[h��	&*p0�XH�BnoTypl�O*D == 0 and0�'y_}_H#"�$/(� Free��f�P!(��%d��|
l9Lt�zPA%m#q6MX2y("Gold") 2�*Dhh9)L-U"�C�BM��paLH $8/�	' (! R  (m"P��E, '�� �zD�%sz�^  "尊敬的侠士，您当前O]下H�c 是：\n[FFFE0D]「��s�"�6 "」[-]\n%�9#Z9�"�9�D��法修�"4I	是否确定"F�@.'� ��_d �5Emo%�"U�p"�"�p��8�	s�!strD�.format( je(X�花费%s%s)T</ * ., XYPxBox(�, {{"�0\
�h}P"取K�"}}�XG}�}r ["��x�6�\P�|s`H,-�-���描述%s（最多7޵, ��.sz\
Y�)�
E( -C%s�Dl'(6 +l-添加%sT"4�@ ��`5�'|��e	2\�.��有量产%s签;)3@"*%s"�
nm
3".'Id@�Impression��D�fnD@�D(�t�,�nsot$�:tbParam (�)TE�k�rnAccept�p
DC�[1$�.�
(� (L,K你要送给谁L�H �8����4�#@��"tΤ`X�)4l�, szPhX%���Common(me, '(Ht|��i��\(d	)�+���&�G��+��+�0= {7�"�F	%�9f@ Z�= (��.�SH�(��T"�'		�pt�� .' + @%��,u ������%d��Hȸo自订%s\ �'x+�,.�, ,�`1�	els$u!	 h���jszIconAtl#p?"UI/�/tn( 7.Krfab�v�Sprit"�$"Mark1�}L
@9'�$@,"@V#sQEnd|�ype,A�.l5�mL�L@U�DG�F(�-�tb�[�hs�s'i  �:'��A�Kx"�O|�@yt"h/X}hH)<'� h
" g)��
X'\'� 	= Lib:CopyTBYRS#�Qp'�tzSe�\-� �)� ��X{...\+�ydt`5D'�(P2mObj, nI$�?	�9�>"�>,���a[h$--Toggl#�F#/ed(V@inR[faDRh-�.OnTouch#�[+�btn�%�9S�%edTXdT,%�)�.�ScrollView%&N(#/*, '�DX�4�E"d*� ` �/D�+@ or "请$�6��*8��((G'�X*<�#�6t	%D#(l:RefM�h^�Ui4�<|2@j.� 	 �elfHp� �t]�-\a*Jc1��S�WP
q22Q 3'4� �+*�\Active("`NodeANt%DJh�0�dw@?%\C�?-!1*�K�La+xNtP,$/�,L�Dting.n�H�q#0Ilz#/Emo"�/)u"�I( 9�M (|�3"�t2�2'�+D@*2 �P.�2 H (�:3 p<�3/�&|*and m#�=h�
CountInAllPos�����>��;0�  
�l �(�d*`d��4���h��("� d)��Pz(*L��#� ]�	7`(H�se@�:('� .��9d́'� �c� +�VЧ.�RPx�x�"�W�Md*p�l4d Lip|.p ��n(.nS,Pd�&�$.tbUiI"hPThang"h%"TQ��T(�d!�/a.-t%�u$L{+SD%�� a	W�Clo4��	"8��%<��(t�l�Pll4`T�"�O�+|\�'a tTUi4S��(�,�2e@�-� G>Emp$`UE
"+ >�+%�'`V�5	��sz��|L0|#�P(��L��ʘ<_Get"$ $<�"�!�e'�,� �yQ[�	*Xd�|*�":)Is�Str(�(,U�	��) �il#&^fn%�>3`�t\'h9�(�'�.��0�YUi$�a8�	
}"8'��m'�e#4*"�%"d��l=ą	OMAN_SYNDATAU�eELR)�&TpX �G'�a#�,7P�l;�'btb�Ui.n��Pa��5+\�:$�"�5t#��dJ�0"�eXP�T/�nCur�
1'O Max�math.ceil('p-�- 0.1)/���h)�HadL$@t#�!)��"�S�`/��&/@�&)��$�g'� @��X>��SnBeginIndexL�J\*� - 1)*/HT")�~/x $��˃nId|
*�+ iD�t2�}p�w���Pp�e��Chak"�!#%[iu�I"�~&X�U&	$(�'��s  	,#��_L0��lbRole"H^,�0�z"��$�<�Z4�=,�)"�%d_"f/i)�;0eC)(|:�3p"�-:p#h�PHdU�Un$��Id\d�V0LPLAYERID�W+�H'�W	ThumbsUpMark�'p��]tb�x['��'��ؿ�XbShowl�@�nMٔ>#|��0�ds", '� X6�BtnLeft 	� Righ;� - 	�-�%d/%dT�����).�-hTime|-h 剩余点赞次数：��3-TLasts�())X�03�Try�h�@�FChooseI�� n +#�JXN�<nTar)�	�!��[n'p1��* 
�	bRet, "xXE/��ʆmeT)�t%T"h'L"+<).<@�/�y&(!�XER pth\@*@8 9ب��}$@�X �
t'>"tb,41 &D0dpL6'��IU 	`܅Bn&�"<= 1'�.�.H.�|'� =$|S'< \��)�!`6%p2�{ ->���''$d"0*ط'��+ "(&�0\L1Hr@�"�1, t'=n*|(%첂]Ui@T�5["����"��1�},:�|
i)
	end
end  3  