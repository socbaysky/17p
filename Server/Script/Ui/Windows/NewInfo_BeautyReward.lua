 =local tbUi = Ui:CreateClass("NewInfo_BeautyReward")
-- 好声音评选和美�� 活动共用最新消息奖励界面
t.szContent\ 	[[
[FFFE0D]「武林第一*t」[-]� 期间（%s~%s），累计赠送X	 69B4][url=openwnd:红粉佳人, ItemTips, "h
", nil, 4692]| ��到以下数量可X领取�：
    �剑侠多�`��者颜如玉。 tl&��倾O城T
再�'F ��T
T ]]
'(GoodVoice7L��?  (桃�EB�87537 7p�`�\PageantAc|QT ivity.+o ;
�'�D\WT �'\ 
function�l:OnOLP(tbDataEi	�	H@self:GetRunningQ((� b'T�At(P P:IsInProceTw(� szOKey\(� �and "'d" or "+�"
�_,PH	lL	D�`LUiSettU(�*StartTime@Lib:hDesc17P!T.STATE_TIME[tb)@ 
YPE.LOCAL][1]*GEndp5<n.n�(� tbFinal�+�3�FIND''�Tx|C44p8X�'L�iD+��0XSstrL(.formatH)�@, sz', /'d[2])HX�Details�::P4LinkTex)u)LZ�:UpdE�Al�q�(oendt�,,6�
�*Ftb�(HH�]0�=HK'�X?/+if 0� thenQ
	(�*D�	returdpB
�0` 	SubPanelNotify(nEvent, pPar�bHave�"M+	ZUi� .emNOTIFY_BEAUTY_VODYAWARD == �	 �@not (4'e 	��0�/			L�l
CheckRedPoint�elseZ		d=���7iem7	� � .�/�P�4�*�-�@F�.PkELisfb{}TLW nIndex,�t in ipairs�~tbVoted�) doD���C�Can@@GotCou`2bIsShow�LL#t�((meP�}V	|4��0		table.inserO`elf*, 		{� hK|�e,�n�@�'` �h��tb�!x]�t�n�t�,�}xM�7� X�3'8fnSort(a,b�ILaHh.nMax�' < 0q�b4d 'p�e3 1� Q	pP��! > 0 ~�b.*D 8�Need�b'|'T 3�<=/��'�D(a.n�0 ��+Q )x"+� )�'� M)(��(�'� < 5�%q	(� )|X'4 ��u	(� 'h(Ub�,`�� X�\s`C`xX*�Nbu, �FTE@�In�h�0�Sct'h�Hk*� Fet"�,\U' 
(itemObj,P}X]	�z0�p*�/��s)�00a:"*�/%d张$#,[ 朵"(#.U2\5[每$11H
获得T��气�(� P-� @+�tb�/xqL..[ia�](� �di#�(= "�LY)H9p	)lPS(l
, 5=!,\�'X'@'�7|z}	 G2, 2L�"L"l	�S	i�E.P�P�:Label_Set#`""MarkTxt""�#Con�!ĺ�`frame"H#Generic|Qt�|��$�5� .fnClickX2t	AW.| �
.Default�T�p-n����*���� (+�.@ L�ive("BtnH�F faP����*un'|,@�$�+*barT
true�
9Already1$.� -Bar�8+@+"%d/%d"�=(�>,
7�prX5pF
FillPercent("D\	math.min(1, )m/*�t��.n(��^	(� +t.L)�+ *�endlK)�Pp��c)�+�8� +� � '�	*�-�Buttonx.EnabledH.2�
�'-*X�)�-� :�8� *�at^*-�)� 4��4��%�4.OnTouch#�0P�(<�I��0� @P:�3			RemoteServer.'@�k��Req+In#p)�j't- +�6 0�Y� �@� L'��ScrollView�$LQ%�2(�t��'�"$�!|�	#�PtbOn��X--@ or {}��,a .l6H�D(�hp4�4L#�Gt"�#%�DH�$�5�nCompetik�Typ"JCUix%�T�)� #\9").TYPE&�8COMPETITIONP#� �H�0� �� �GOODVOICE_,��0	�D#Q6_S*me.X�j�CoPInAllPossOct.#P<ITEMd9"X6� +��
szqNH�U
Kl�"�7x�.N, SnFa#�M�Sex)"`/$ %�MsgL
,O$"%s$\W不足"�T 	��通过储值任意金额�#(\�(��	@S(szT 'D CenterD*\ LE"PWindow('CommonD
p','Recharge'lR�s,� %tNYp�P�KX�)L |R	)
	end
end  �  