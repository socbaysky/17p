 _function WuLinDaHui:OnBuyTicketScuccess()
	me.CenterMsg("恭喜阁下获得参与武林大会的资格！", true`	UiNotify.On�('D  emNOTIFY_SYNC_DATA, "WLDHRefreshMainUi"Tend

2 IsShowTopButton�local bIsAct = T ivity:__�InProdByType(self.szXNameYuGaoO	if�thenL"	return�, 1� ;P�	 �BaoMing �� �`. �p��4�GetPlayerTeamNuma5 @ �5nSN0Cu�Q60P)X  for i, v in ipairs((�
.tbGH6	Format) do
ll �
tbxInfoH
�:DServerSyncData(�NFight�" .. i) �`
XA)4and (8 TGiG �Et� 0`.G + 1)��(p'  �N-� 
�4�SRyys�mCah~t-cZnot 8y;)�	�`�=	--是取最短D�	一个时间T�0�TimeNodesL1{}; V��X	初赛和决`��始前\		才有通知\	 2		��;H :n(	D�& '@
)(� , nStateHl�|Rd`�(iDq   		�6�= 1 @b�= 3,9 5,9 7��	@ table.insert(tbN��'TM�b�[�]'	breakn6�D>p�X3�7肯定DA早于�8T�elseTg�
 == 9  -�C'nalCC= i�]	 ��c\'� '0 �m*#/m0�\(�p��so@(\/'�(a, bT'� a <  bLX^ )`
L't
P>X@os.d@B("*td�.�[1] - ��
tbDef.nPhoneS�}N�BeLdeSecLP Ui:�ic��M^�ag�ޮsz/�A.hour'0 min, fT4|�U5D\�*nd�|��*�NT�\(@p`Match�Q(.� �B�0�Cunce� �/tl ܧ}/b��Q +4nNow\D`
p�f--�[  1，2M 3M 4M 5M 6M 7M 8N   �^ 9p 10,  活动结束 11p%l
��aH�ĄW6 i,*�t'1)+`diz>=Q�t#d"`� 'ji -dTp�r� �z(L X"�'  �'(),͖:�X(5�rtt,@0|���意$L) 以后还要重新排序@epH�p��t		)I =*hRAc�t�-�'��X
�l�|�)$�*'�P�'� �8(DXF�d8nDay|eSche6�"lduleH�;	btb}.'�h�(0 �(82�) + 3600 * 24Q (|K�1))F`		`d�bFiP�'F		h:�%h�Ltart'��	��o�1, U�1L$string.ml{(v, "(%d+):� "��nX�Begin\I�tL({year\�/.tLonth(Q mx, day(L R, hHx �P|"/cL0});	D<L��'�dUt�fWec�`WD�G@ �End �"$ �,�h(D/�(N.t��sz�TS+�	5 	� [	t,�%4	 (*H	 � Th�i� � T#/�'�--预选赛的$�1范围4H4X�$"oePrel�\�Scope('�`{�GGNaysF�{}Ta|nZ, P� .d",9(-	QsD�X m	�$� '�Qs'�'<*(8"�%�!e�j\, ?��(..��`-L.��� 7XCLinetNow�l"�&��(DT&XehW:Act&@H\BT|1� *(H#�#r#@!#�2n�	�����`
T� %4%�Gg?if  a<&%8l&�"� "�'"�?�阶段Xv$y-�#�?Hx"�,�$�,\$X-�X%�-�\
�u0�.$+�tbAll|1x�,L�`pe, *�-"0>1`I&u"t'\.DIl`j'hp,8#4%_,v2)@(('�$-�*�Y2t>lb"�"�J%�"& 4,� '�&04'(+#4D'M l
p7Ng <L�*"�9,d�T |�.�2*� ��/nNex�f=.�i+1]\	#4*'� ��ow >=T3���(@'� %ZJ vt	t$| '�!�P�XL� � 4T$LYRedPoint��--没%vK��LW\U间节点L 如果客户端T看过就显示红HT�"�R)	4(h4"�3'� ��D
��Vie��\
Client|SFlag$�SxPane�b"l]�-|dl#I'3 < np|Z'�0� "�_"=1e"t^� 48Check+4H�g.�'�Ui:Set�N#�J("Ac��_"�`��<\Clear �  �ques#4X#�X1� szSynKe"�1't ��50Y(� or$�c(�Pnfo1"d)�CtH�%,ZP87�R�)D"L?�bRel@�3h\-*P�H`�F�tDela0D(� X�"�7nC�K�"hUu$I"�hval}G6"�930��	X(�hy(D	:IsInMap(me.| TemplateId)�A�	n��( L���U�
�&nNT�= Ge��t}pl )�.__�paQ+ 7l "xVD
�2xxF -8� Tl��0(�`l (\#N)x\`�P�P�(0,$)\ 	Remote$\d.DoR�Hzl("�t'�
", '4�O	�q  R�")"�=y	'��� 48	OnChangeTeam#�&(4L���oseWindow("uRYZtT�x���.� CreLNh����C)�T>7,1�..(\T5�/X�*@�0��P��r'�IDH)� .n)h TH="1*T �g5h),"�tT `:"..*�)4`�
5p-�.\"�o� 4���d�tTopd6h�,�%�7@�dataXUD|vVers"�{= <�GPre'�List#@p(@"`p�4MinI�=*l}9h, 	l� �'8�D-$P�'� - n-x >= n*x�:xum R?�2 X1(�--�|Id�@� 4MG@�singj@ID+ d)#�w?��	zI")|,#XWl	&�#b&�x['!]`>�
an�+��Gtx
3�
D%T��d?�2�"{n�-'0{x�(\,H��F�/|�)nAct'l;HX&<:�])�
'��%�8lpT�+pЗxl /L�--"�`��对应的*�8�%z|�D#d##�)xGameTyO|nalD+`(� $�6M/o+dn,�:�](( 3�S(un S�\�0D8\)x�() <@�'(2i	 "T*��K� 4�	IsCanSigUp(p��"�:�9TO &0
,XE��*p`|,�== &�x�� #L&	, "当前不"4|��名期"L��'�Uix�"<QHhHLD$PJ$HJUiSett@�*��')��"Las�s�`2W
tbU�.n2� @�SaveValD�-.XUserQu+�xSAVE_GROUP"�dlf�טKEY_$0�xx5�w  n�h�4(�$6+Has�"|. 	-- 因为服务端设H�U. ��$(�h��	，然后该��H"ܚ��上次"�I��'� @#\Z*<q ��/&�2'p��)5m"}	�D不在��EH就需要����L��P�8"�.�b�t0I:P#��"@$�/��("n2� "��H �a2� �� --�&�C还没�到T\先取上个月初l�x�l �5�XPt());l� ��t�nT�D �p -1, d��1}@Vd
l 3`@|(��+ TL�P)�9�$T2�'d�G|�kme,�)�t#�l�s�v4p -� > 3
end  J*  