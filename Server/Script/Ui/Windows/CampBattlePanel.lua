 +
local tbUi = Ui:CreateClass("CampBattlePanel");

function�	:OnOpen()
	�:RequetlTeamInfot\self:Upd@gend08(x 	if not �
.nWin|	 thenQ		v	.p�:SetAL ve("Failure", false|6� Victory*� eH p�hIndex ~=.� �0%=3$�%	lo�6Playerz+s,H1AllBuildHpPercent\9� :GetServerSyncData("�*�"vtb��
@,< or {}V#tb2�2T ��F'�a&sH{{},{}}R	fX
k,v in pairs(+�) doP	v.dwIDEkl	table.insert(\�
[v.�D�2] , vvenAM	L�'UiPrefixP	{ "Md@"Enemy" '@j=1,2��lNtb`s[j]L
�sz)Pxi�+� 
nTotalKillNum]0xqiM6��	tbl0P�[i�lb��`	5t)@.. (i - 1)BEru�b7� tring.Xmat("%sLight%dTd(H, i-v	me�2=D0`�o.		 @ �'Hono�U@�L.tb�LevelYwtQ[�.n(d �E	 �	h�A	s.�Rank`p�/�x,�D��l'$�ms@�0Hx	�*�xl +� prite_AniH'A�()� \#�`.Img�);l� '�eԐ 	`(���^�0*�Label_X-Text(/ Name2 @�Q.szh(| 
mFxHValu<�nxcCount(�.�,= +H+�*(� '  
|�Q;�n� Ti"级|�|�7�SBigIcon, sz�AtT�\U�_Portraitt���\���(*!S�LT8�0HeadhL���a)T)( �(��SpFaH�Z�= �hl'��(�  ��5�' �'L �)`�bX l�+,]"lPTxt"o=j, +�	Tx> --建筑物的hp更新d�']�py�t0�M� E�{�͐�}�3,�n��r��\�h.floor( W/Hps@�p1) * 100 )�+P@D%P$/�TowerMar0�H�+�= 0F		��szOutPutLb@Z4X�p:x���TO"�(X*�,�(hD.)�}m%#�)XD�-xp4,'{Col@'*|200,255,�4l	:� M1(� #}!	@K\?� \ � �.�,'&szTyp��@� == 2x&'�d('-"($�� 0l.Close)�-
"l"P�OnClickT8�P" .,d .BtnCtH'�(p|A"�0pWindow�.UI_NAMEX30
RegisterEventhd�return
m{� � 
 UiNotify.emNOTIFY_SYNC_DATAD�~�On�(�},�};
end
  �  