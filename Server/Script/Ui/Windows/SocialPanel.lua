 9Require("Script/Ui/Windows/FriendGrid.lua");

local tbUi = Ui:CreateClassLocialPanel+�  emPLAYER_STATE_NORMAL\ 2 --正常在线状态*��	sH{
	"��",`Wanted)@ Master)@ �sRank'U }dfunction�:OnOpen()
I\2x End(sz�, ...TSif � == +� thenH	self:UpdH%SideBtn("P ��%	�.tbOnClick.(} (xP	else-�Enemy�">��s*�p�:Toggle_SetChecked��2", truex1��'�7� 2�T!1* .� �<�9(�	>$)� *T2p
�Tp2*�>��"5H���\�E7	pOIY.,�G,��")'1X����B?x�N<t�(p1 ��R			x �$<�( p�#h><�)� ,�l�,�-��*l�2
)�nd@ݤ	D� ��新界面定时器Dt�.nTimer��Cd@��:Regid�(Env.GAME_FPS, ��Dd���	�Ship:��WT�z�Ui`��nSel�IndexA0x�dWX� ent:IsCloseIOSEntry((�
��&SetA]�vD�( �2, fa\�l*_SdkHMsdk)D� Hnot �LoginByGuest()�'� 8h	HasET�l'ng7	lon�bHD�\#/�QQ�)h&�and�3���4�|/�
,� L+�7�͹5s 
 Hx��*ed!LT�!szL<NameX!j'Is�0i! x "QQ好友" or "微信�d�.+��FB\nDP �'� �elf��Labelx�Text("TxtX�$1T$'� �*�
9� |�+� '�bShow��XTeacherStudent:CanxDeerance�C*�L9)��L)Pt�\Ɯ/l	�'l*0�KL
*|�P
�nAe+�bIsHouseh�D���g(me/�@)�HelpT*=� Rela"�(sH�1� D@*<+��PlantCurH*|?�� 
TvH�&h*�!)� T
RemoteServer.�yerT5(D�+n��j�rI= * 5P�&|,�>p�DegreeCtrl:H�W+, "�x(tS> 0'�gUi:$P1VisiblL�+� #*X~= 1(� 	 �		�&@�return#�*`*|���A�:Clear�RedPoinP��<�niltLXYT lʮ�tb#D/utton'�2'�s$�2\$�!'8 �ZT9)$0��,
1�2��tn(((AfI�_E�z��in ipairs(+h) doL+�0�s�',== s죌b�� .�
ST��9&�4A%	di, v *P�s2<(]vp��o		--+(� "Light" .. PT,� �� .��*C#�!�\Xv�@dhe��+@ *d+` @%f�nC� -IY D 
这里改了Cd 时间和 下"�$��K会G到LXx4.$*�+-�CDtimeP�Lib:lDesc3#�&.�)�)"8*` 2"0$�0�(	hz+�>= 60X�P &�;+X)�btnEliminatt'h9+� 'LColor("'P255 , 100� 88�'%�=%d"<��P �p�v�
\'��bRF�ve`��l��tb$�8DataPӴ�"	+.*d @	�eE#*\ X, -1 �w,D"`F\�1ScrollView�.p	["Item"..(i ZQ)]Th7�l(��AtP
*� %�B�eJr�e�@��Ret(	ta@�.removeD��w, i�'		Ptt%|?p%'�L� XT`'� �K`:Refresh�s��)64G#0�D`
.�2��_�ose�h���d�2� = D�@�'�4<8�3� ���fn3� H8\`+�"�NlT��("Rh�Popupd{�,�!�,Al%@5(bModifyp\l?��hIs&L%�\��T���2,L�
�G	 --不排序P�	，领体力S�种H�tb'L@�hj"X"'d iN(xKx��Y�Li"x5h
/]l#x4 	�`--按$SP�	亲密度值�U �的》 �\�fnSortT'(a, bhhv
a.nState ~= 0��b+D �,�Imity"4RT�'� 	� D
Level > P�P[plse�)� �����F�PAX	)�'��x0pl�P@9� ���|  RP(�ݙsV3( )N, �6H4P�a)x D9)4 �3 
�&�7)�BtnQQ�U\�/\:p��04T#��\T�M)TL.�X\3d{*� �9�9�4�%:Afn%�ZX
(itemC"p`X$��0�F'� .indexP,ip(xP�(D �s
  '$P(�X1., �hP)t$d6"$+l�Max('h(� Y	'Y :H��(M[�], 0H p(� �T�+$�@	.OnTouchEven���*p�) Ю0/"Main\E�$/�='�Ren"8H*���()�,~\et�), 7,$.BackTop)4 BottompRD��'h%	Text("Number`tring.forma\%d / %dA#+����Max�X(me.n��, HGetVip�()A "x&�V���.���$y6(x5�`*(l�7U	)��"D8��@Ԅ�Fx���d)4 P)�
fn8��P�Hate��dP�*)m,o;ortp6 	--去掉超仇人上限X�"�n ��因为客户端之前保留下来DT�服务@
最后已设0@U*#)�P(^.n\:�X:#0 A	FC iLe*� , 6� + 1 , -T $�,�re"�)�Z�sm.	�"� H�,) T�2(��'� R1et�D<�	)X }	(�,t�sԋt�*�*�,t<�,.2,(<�x2D'�nNowDHk"�+�c�"4hRevegedVxDe6�Hzng"�7y)\#{&.nC$�<=)�"H'�CDTiem(�@\I��<= 0'���D�&`*-�9��x��Labe)�UC&@=&<*l'� Co1�:2"�:P h�5� 5 *(3Ll�*�I't-�7H#(�:C"�KN&X8Msg(p}L*�nReq"�a�Time or '�Pj�1� >)�.�set��9&� Remot&�R+���; X�TODO 目D�只�P���了(���U��#E间隔G�制\�8�es��=( X�0T� 次数L�nCathch�8�
Zch"�4�4�� l	Da)deAs"�H�)l
BtnPlus�,�  <=0D'�tb�d'Ts(�.LAQ<#,� = -�(��
%�*(a	%0@�&D�%B�or#|"'�X,�2bSHed and nYb.��B�$4m@#�kDua'� a\8� ��$2h�:��击杀KE在LI面 #|6��余�G短*| Dל\a.szCacYr#=UaDmb-\ @#l��$( ,$04?$��	�@� (�En��<" 7��@/| � � Xtable.#3*F, �9Ԃ'p�xXK=x2(,�IxS1��_6�	/l�\_�--同步`�#HnWx据X:.d��cp* Ct&IA/�C"�-*� ��(t$�~��s��'�"����"t_(�(d�:Ini$0b:$Teache&}n($��.$Ha#�E&<��3<"llHelpC"��er(]ntStepM?0' �)h�DJ�EWser\�VUix�Play�tin�͸ɞB#�d"ts#�J#��Voic"< '0.bMuteGuide�`/��_tbl =
"f�{"t�Q�"�s1"}"��8� 2>� 3>� 4>� 5�}(�p]%{)H LPvWn"TT`"�+n\*
pId, tbInfo i'hg�%et�![�]�# -#\ht
(� t�	�	t,� [szThp�x?D(p0x �2� 4�t4p	al.(�	+ 1xD��,} ]'p'for �, _h"&�k(��+�	L)%(�4��\�X�#�<"�J\]�)� �$�)l*2�(I`i(��9D-h(� :x+�^'���hl3d"x�#\H'�#�[d-�X�1UI_NAME)(,�d
��Apply6\|�&Z)� ��"X%7��"x<0�a:"�F�(+�|�R$�`XD�	��7�t' Z�ntp"�{�$,� �y7�Rela&��3�#PA%4-`+�Ui"pDdwIDT7���3tChatMgrX�SwitchNpc���)L	'$hA�N��"_Jgle,�z��tbBt$�|"�{��h�'�|D�Xmv|i,,�xIs�{h:%�L1 �(�xL"'\ �m74� x	��=LL�DfGetRe$L�#z[("�)�6p2�)$`��+��	'��:@�2pj%�U+D�(Hp�=u23�p�1(�"�D;`�t5� �\��X)`&�$�$�%"`3�NG_�)��UX�Notify�%,<(A (�l�.:hh�y&L$H�=�� X+�1��\"*��"�]"&�sdp@%^p�$<()h�=,%交)��(P*3�)7���#d+)� �p-�)�)� �|.�R���$�,L4�*tG3���fnAgree+� t,��ЪClearReveng#`Kl��B%�Wn%�C=)$D",�CDT"�J|�n�Gol"�'������CDMoney(�pG�me.H�"xZ]< +<&H:HCenter"�G"您"�;��宝不足了��Xil^��CommonE3pXN"Recharg"`.(, p%�>Euem�	-MessageBox#�� s,�_"XG ��花费 [FFFE0D]%d� [-]，清除冷却�#�>？H*�)"X/ { {�9}, {}  }�""�8��L"取消"};�"SZ<ch�1+dtPl-�Add��V9P'TG3`O5Buy"�Hs("CaP�Q1H�+
0\&Pp38-��#H&�(
\J"lCversion_tx&�-0�ReunMOnea4�.(�$Recal&Z�
�g�,!R%X�#�k�m�ftbD� =@"�7	{ Ui�� 	.emNoTIFY_SYNC_FRIEND_DATA,$t[$�:�"!@ �D-O�BUY_DEGREE_SUCCES,T� UPLE_PLAT�INFO�R.HpR	{*<�TS_REFRESH_MAIN_I(h�	MainInfo�u		=,	TEACHER_LIST�.(8FindTe#�A� DSTUDENT8FSt#@� 	DAPPLY4<�YList 	6OT|"��U�:(�O]�r"�&us+D+�	O�C�;RECALL*t4�	}LmH;%�N(X3�T\=,Q($G��.)�&  �?�=T)l�7`0�  mS�< l,� =l'�>d.� ]
	" x,�(�)�>h0� end
  A9  