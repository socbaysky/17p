 local tbUi = Ui:CreateClass("DP mlandLevelUpPanel");

function� :OnOpen(szType, nItemId)
	self.nSelect�CnilP��P�'� Cost�P�e	�View�
s , szMsg= |:GetV(q (|if notT)`  thenA	P�'@ 	me.CenterP
XT p	end|return 0p��UpdP'hList(tb)�X�.�1��p|DDLpInBag(f.n)tD`t�t��P-, "无效道具1"'�T�dwTempl}dT�	.*P Dx$x9�5
 == "Enhance"'���E :Label_SetText("Title"L
装备强化"x'KCang
cneLInDifferBat@.tbDefine@lTScroll[*�]X�!tb)8�"	7U"h�4	'<EquipPosT*4h�p�(tbAll�x�6�(hf(P)T^
{}p1	for i,n�`in ipairsXH�) do|�nStrength�sH	�end`(4 �(m`s'(��%�� <Hd(�.nMax�-'�	��i+� i�7]2 L-r>=.\(� 'h		table.insert@)�,\'}['�])	�"�s� �8DV}bn|O,8(4*@L5HT� "已有*�

等级不足"|P��前\m可以�\的��]��+dXelseD�i)�HorseUpgrad �	坐骑进阶��V*LDH8�*� H�PpCur�L)�ByIX(l�.EQUIPPOS_HORSE�}Hp2(� t��,m�'����;H'� +� ~`M��%[1]4�"(����#T4�%+��4{ *�Id }\ 5�Book� h秘笈�,�),P-Ԇ�8SkillpHx.|��'h ��	��nIndex_�Nee�� *�'� \�', Hole��.H@�T� + x(�SKILL_BOOK - 1A'	�H�@/�n)`��}�p�'�	--只显示初PqP8��tb|"InfoRtb'<h$�(�
+$	�l(	.�:p > 0 x�D��	."�#M�I5�x�'�( ;�'�$U%	@ �*�D*8 � ̍�g�Dhpp d+�X��TL-�V*��e/Tnd
�.$=�$�9fnClick�/= '�)(goodp����.�)�.')		'L %�"Toggle"�"Checked("Main"_�rue�A�':Se#D+P.(0itemObjJkInHl���T1, 2-|D�l�)[ (�hOe) *[+ i#h#��T
�["l	"..i](hhX(�	�.�HActive,��G-� 
.OnTouchEvent@)<�(L�,P�3B:T7�2='X1���#�*D���#�,��0�sz~Na#($Icon\4|.X�.%�-Showe�(S
nFaD$hsSex�A\oDh�)�%�$(�X-:Set�.&�%en���M�%	�-%= (� d�(4 �#�'�'�$�(x�?-x.-("�.+" .. ,�*`�� �false�n#4500-d`6X(��'�n`frX:t+h<\g&:�(�'� � )8�})�e�� \� �>$�1uG:��	(math.ceil(#+� / 2),  f\���d2�	'�">:OnRefresh(szUit�LUI_NAME"x#h'D#����F,� L<"0@loseWindow$�9�`%�&'�l"�!`0: <h.tbO��Lo#0#-P(� :BtDD#?<X2T,$Sure�	D+`�}.@3)|B��\}(@
"请选择要.�2@\�:x--检�%�0上限D*	RemoteServer.I+,!	RequestInst(&�=#H$`d"p>+-,#<D/�@xa1|*�,(R 0+� �S)�G�-�B50"H%%�%(,local ��\F@4��*hD*��3Dd=�"j:ot�^"ur�'Pos'H,�G>先$�6%�#�
( &d% �*d�"*��)�, �+�t�]� -�:Register��a^ @ �'tbP� =
Z {� �  UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,H�[O�},�"4C��� (�;
end
  t  