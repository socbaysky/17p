 #local tbUi = Ui:CreateClass("BossPanel");

function� :RegisterEvent()
	�	D� =Q{N 	{L Notify.emNOTIFY_SYNC_BOSS_DATA, self.Upd^Ui�},6� �ROB_BATTLE�.ChangeRobBattleStL	�8$MAP_LOADED�	.OnMapLoaded��}� 	retur` �[end0tOnOpen�"if not t):IsFightD(me.dTempl\Id) thendKCenL+ +Msg("本地图无法参加，请前往[FFFE0D]忘忧岛[-]或�野外安全区P再尝试�;	�0R	e�	TYn�ode ~= 0'��=f��DXG'x�	�AnX, nYXL:GetDefaultPos1p 	AutoPath:GotoAndCall0� T
�, .�	\Xp/Window.		hxU| b7		@G-BoxP-��否返回当`,�/'��/�+	武林盟主@+活动", {{"同意L)�}D"取消"}}tj4��abIn'(\'falsed4�I�ehData(h	�7'8uz:�PEnd�2�
 tbOnClick.BtnPlayerRank(p}	b.p�::Toggle_SetChecked\)*� \true|P7PF�nTimer'��:Close�.�p�0��H�Hl��(Env.GAME_FPS,��Schedule��	`:InitUi�!�
:�(���'�3��	Td�!Labelx!Text("Txtn0Hp] "�i<� Leftx � H4P@thQ��抢分 �D\�llenge|挑战�U�3�)��Floca`�t��ResXwP4d`z�p��/BAtbp��'8�
szLn\	string.formaD*b��*\获得%d},L�-X.nScor�P		--2�.�Die'--	6���功干掉*,  �+	)h��U�� .L@6T5@>)(*|��L*P P(*8 L�3p'(bForceh	P%07and�ָ'���T}D�vPcH)t�() 5l+��qԁWnilh. Message\�)��束^{{'��V	t��6�Q#}��确定"}d!��'�T�ðUnNow@\�pw'�(�+ @�dwID) % 5 =a�a4� ��'�'(��ft@l]pl| hL+or {"4"���T@hh.max(((.nP�q @0) - o, 0t�sz).8��剩余时间:%02d� U/n'� / 60, (= %\�]h8��L	(|HK�tbMyh\t t!�1-NP�Tg�=H��.n*\ x tL�sz\�HU"+�hl[b?< +&�&��D�+� �-h	X�'�-�/<�	)H�'T�S�g��1et" !�+�+\�����-�%(d 1�\���x&+`l-�($1�(q =�,(@ .�*�>()(P  '��)'@ �*'�
szHpP"Lib:x*Desc3(�Dxt>�oss#8!d	��LPeR�ntP2p|�<��)) / 3u-Xe|khmK�tar#�")e� �@*,ProgressBar"<$Value(#�8BloodE%n�t'�_, szRate"%ur"'z�Hdd|| HpStX�Info(*(+ Sprit#|*�("�.ImgQs�t=� IntegralZio�D��r%�7���p.*tTe:�hx+��H\d�*szCu#.h�"Kin"'�h�\"�.' '�4$`/3$�109<Ui(szTyp'� ��lDVpD"$ �'�W(�
-��l����z�= +���J@	(U.'� E + 	 $&`< " +�_hq�=$=�  (+ 0�MainTitl"�1dD:IsInCrT�\�p4"跨服*�-"}@"+D �n�R"LB�K== "���9�	�PE�@J�PP��N�p4My|dL�(t`�#5	:MyPoints\��floorX��X�"�2n	0)/�"9Ls0dh'�q�o؂-(,Il,��	else<�.�(� �(� ScrollView�(�Is)roadcastMsg-|/,IsD:P�tMgr|�HnnelY t�����3��#�5P	table.concatd1sgs, "\n�x%8�*lHp\9�	/�(>My@  x
t��$Н� ��
0��j'�4tbUi.���LL:HasX Xf,'tbMy\H(\�0)d[ �FamilyNamp��
.sz`h%`E<��lsD�n| Leader)M0a"�[ 8Participa"�\)JnJX�Member t��D	-8H./4L7+�
SetActive("No�%Cont]�ex#�;�Z6� 0� 'QMeT� �'�  	�(��W�dtbItemh��P\!h?.
��fnH!dTV'�(iHObj, nIndex"x<+xP�[�]"�3	�8�L�IpGX6"总堂主:" .. �
M]M'�	�0?X#�Kd
积分�	+Td�B�� �xRn
�H�人数�H��	h�WR�0 u�1pX�)h4�L/�PBt�D�bCa��
p�\8'�,anJId'Q.�H2xP�<szL`/(� ��U	"0!�XArverT	�	*� .�9s［%Q �\'� , Sdkn�Sel	"�1'��Id�!�W\�M8�dH"帮派名�1'�|!pT��R <= 3'�.�S)�O123H(9� |hL(�		for "�p1,^doq	9NO�]i,r= �t$,fx���n"�8nkX6-�第%sD!\#�= ransfer4LenDigit2CnNum(��i;���4� 1�*4-|)� �(�endT� \ #�!HT(�$��(#�Ss, '�h�'�tb'�4�%P�a�	D*�(�  @�T.t0�0�]�@�|m	 � �;�p�!' T!'�X0db�"" |�	Se�}P	 � vsz(��"�A t��pUfs�l(HtbHonorInfo\�C.�LevelSetting[t��.n����fHِ�and*< .ImgPrefix t�&�8(�. $�;_Ani@?ion("-� (P( }	#�3t/Ie'�$,,)�4��\$�("NFa#��\.�`�Icon'h���#�axҸ�  �4�F @"t~"�|"*L���%h|&|""-Yr5@}$8-�U�i#Lm�V� 
x�T{~ict�-B or$�i-dS(� :Bt"�%x�#�m��$�S\�x��T�Tl�sz'�S #�SL�%�EDg&Z(Fa"88xDg'��0� .�H(�5� List��Backgroun"�Z,� ��l(P#�>�)+,,�(� .�(d <����5$+�, &`))`4� �+� �%�? sCha$i�#��tb$\LHЄJ3�N� �j@iX	f() %<o(<h�jme.)��冷却$�s未到%�H%`�-|X�A��(��O# �'�,l本次$��已�#;{！=�-h�"|AnerArray#��T_"开始$Tn\h)"d��-u,#,�X��9Rob �&�r= �;.�7�@�#̙2p�4h�	间隔尚未�(=�@"T9s :Is<�#��'h=`-\`@|m� �d��-D	9��	�`$�c��d�"�>Lggrea,�'��p���v|5� )� �d�)L (�^tb4d H=#$P+L3� p�"�A�!@6��z�Id',@:Appl"�Q%D�JId#t'end
end
  �*  