 Require("CommonScript/Help/StrongerDefine.lua")
'� �Ui/Ui�Player.� = .D 	or {}
local 8� �tbUiLUi:CreateClass("�DetailsPanel");

| .pfnPartnerLevelDescLfunction (n�)
	�sz��.tbQuality�Q[�] L""
	if versP	_tx then
		'�.. "级X	end
	return �
h'�ZCYua�X5�� tring.format("%d阶", �)4d�0l�L!Mn� >= 6��"稀有wlse-� 4.� 传承�L#�普通|H"+JOMai�. 周天:%d6��:�s,�	经脉技能��	-�SkillBook=|'�i-5.�高�G�-'� 0���(� )�初�+�tbTypeCfg =
{
	[�h.xsvengyY]\e{szName="强化L+bEquiptdXtrue},1one+� 镶嵌 � R��+� 	装备基础 Hors,坐骑 � dP�+同伴.faF4, @��4�K61��Card+�门客3�1��+真元37��	'4��]-t�)t 1h�o,d�i d� `�<\vFa+X阵法3X1`'�+秘笈3�)'�dhL�l�'$'p 1�JueXu,L绝学3�1 �Point+�修为6}��tbOnClick�(@ J�{}D�'x�_' :BtDose(L�y�lL Window(self.UI_NAMEP���9Goml#� szA��= �tbQ�.�
|�'� andP� ~= "" g�
		<4`��=  ��gsub(�, "\"E'""�!		load�("��" ..'�)(M	pm 
+�:O"�%eeH%Q,( �DOpen(�!\f�ot'�%	:CheckVisiblI1 �  me.CenterMsg("少侠已@� 
不再需要这里的指引"\%?#
	eB�
	(�DP1&u%nh�P+�[�.f�]
y5nL��3�(+xD� nel:Label_SetText("TitleT0�tU[�	].��@/�:\�reshCoOnt(���,@4� %�(nRank, _, tbData)x:GetRecomm@#nByh��ldT\3�;(Ld"�)`$�3��bE�F#`(h+X'Q(HAvg, nFP,LValueInfo p9VEtbY te�.nLvl�D	tb'� H*f= JMUiPh�'��0` T\�
))`�e'+等级$q%th�D!�L	pD���	ȼ5�� ��`'��3�品质+��+�\-5~FP@4-[FFCA09FF]%s:%s[-]H["战力Fto�(t
F�0)I[	�$]M
�ntb�\ListTd�'�	MyTotalD(bAMy$5�nMy�(�ZYMy/DHFLib:CountTBD&q.]ae"H6T	) <= 0� --没有分部件显示
	'X�Q=A{M 	�wH�^XN"5*,mtC ={u�	NSMy\�B�		+(eO]fr*��n�FPG,tbpPP�+.%M)��%P0�hFightPower+�`-�MyDT	table.insertMC��L\5�\	elseQfXnPosh�5 in pairs`{�)� ) doX0m	�+6t .. (�	])�-H,@"'�YM(�		��D0� �ldH��P��}tHI�<)�1th#Y=	X�''D
Item.EQUIPPOS#� [}]RR		�`	�nH�L�QFqm0�ypeL.�)) == "�1"�U	0	�Z(�.Dpt�t`Rz5		V!ec)��|t�:	-�nilt	�d \�
��	��My�D6�"(L|,�/� 4-�tb/� h/P l`�Me^	@ '�-\�M.�3Lh	X hH+�> '�		�:?�	�F� DE'fnStoneHH��& ,(ObutGObjl��t��X\'l X�`!TP���z.n��*@ Pf'�Ui:Open%�,.�K"�N$�K'��	(4 L	lx���Net`iD(=iDkT, nIdx|-Mt*Y[q]U%	�.4�&Ii"�MTxtd؜#Թ" #�,P#�sz\Vh�)D ~Bsc@'�H*XP"$"��'� It�t|r�Xp X 0��'�*$��'�"%s%s" , "0vg`#<"'� .."\n")�+<X�`+7,\�2@ +FP5MyP,IMLr#�Tt�*M�D)1��)=M�8�basz�51Md�:&FP <F+�g5	AverageGrade�`s�\�E��i;My+� M�*or �h-� Set"�:ve("Btn�p",n"82h�&�"&�OH�+)� �	.OnTouchEven"T)P�X�-�\B�*�G'hM�e�� self.ScrollView:UpdateR�Co#�6$B$fnXx�D�'�tbj�nEPrMap �<Register�d��tb@� =
#�$ {UiNotify.emNOTIFY_MAP_ENTER, �O'("v*};\�$); (8;
end
  v  