 local PrayPanel = Ui:CreateClass("'l ");

'4 .tbOnClickL
{
 C Btn|@function (self)�@ if not� :IsLevelEnough(me) then'� x�szTipP
 string.format("您需要%d级才能参与祈福",�.PRAY_OPEN_LEVELTh� 
me.CenterMsg(�-� return;'\end
'0 \`.bPlayP0'� StopGAniTh#/�h+8"请等待�结果|0h� else'@�u:h'�(-\|�| >�d;L6EndWuxA(1�/�先领取奖励"($?��?nDegreeT?�Ctrl:Get�VF, �T*PH.�> 00HRemoteServer.O�VRequesRJDo|U	 +H�)art7<�'(� /^QuTeBuy:Notify�(TimesL'��4] ,�NHlReceivh"9�t>�:GainReward5<
}

'�t��INa+��t'(�= true�j�p�
Button_SetTexH1H|
Xx"停止�4� Enabled("(� faHc�^*� ruUi($�H�ConstanceT�,�, {}\X0

--校正到0度2'dAdapH�(nSpeed, nTarAngleJStD%Fram'0 ��dn(t H_*4 or 0�'�drotL�P*�AdR�Z�oit��o�nCu�X�� Lt|k��8'�|�v36+Mn�R(((�-(�) / H) * �#�'� B�h.R\l(�H/x��sz�#T-<{0,0,%d}H7'�-� P�<� �+� tbXBtrolsP��zto�(0 +\':),�%+� �7� �(� szH�\lh	a3.�e8�
�NH �W� (��� �;
�[18M�iP�|pResult(�S*4(�1h}H6|-��'�bdT�'(H/l	�E��!(�/�继续 (�h>�Lt5�Ur�pD*�=ltbPaP�R{}�!�	'D@t	7����Ph7pLast��z��^Lc.tb���[n�]�.-- 旋转若干圈*�TYl�L	\{Y{4h^� -(�--tl�.insert(�, �j'�'*`)�* 1t�)�S�CountY1��fM�i|D��do�	 @��- it�(: 1)1px`xC��-�X8EDT�lera"4-1X�EPNd3@XM�/�w�$ l
*
�.eule��s.z�D"�%� <. &*nD+ 'D �e&|-��	8�SetP��+��WT> ,*�Change.�LL�Rv�0)7~On@�H���'.1= ���"�h�-T-� :Updatep|�)1POnOpen*��P((8$xWl.� --由上级ui调用，非Main#o%回\2�$""9osL�b\G`(�(+�4��t!?@�
'�/��(��.�h(d'Lh+  p+H��le:9|/�.�p+�>��MTrL`{ "金H�"木� ��{ 火x 土"};1� �
{62, 350, 278P 06, 1343� Radians"HLK�JinmHnMu�eShui'3 Huo'. Tul10WordCom��
�	'(��x~�O'P|SpriteN"A"�C{"jin1jmu� sT�huo� t\3�(4Lighx͑	2�	� p	�P	� tu2�1\H��6Desc(sz��D��nLet*��len(� ;�U�szdR$""�F0 iY1@�d��pN�Elet*�sub'g, iH H�xl �n�tonumber\d)� Lf�+�d'|�.. p_'�eV[�%�!pt[� ��ì8p����s�+H"hD"x$�-t�l�tbUqtT})� �T�\�--按钮�D�'$+�Ę(�/�*,�;+0A\�IsNull�(18F ���始�$�L);9C A�+�-`*l 4� 1�"�P�b.��ap	*4|��*L4Active#/@Rec"�DLr�&X��&�	8� d@`h,@E��>P���盘��G �!)^5 1P'�tb��[i)l�/�sz�Xw == ��Vt&�XaX�����lPLL�'�  +`*� Dd��-d+�+( 	 ��,$&�(t*,��/DX+� ��&��"�I�!d|T"J, *�X't|O�=@��字提示�*XLabelt
�{Txt$=TJx(�d�l#mU)"�("无2�:-HArrangementR
tbU_tO�.sz)d �	 0Explaip�* �'�	--技能buff$tW��0nSkiillI"�KJll#�_Xϐ"�SDF�jQ�BD$�Qs(p"&4er�,LP'$, 
q'.X�mframe1"�$�('� ���	d7-� .f'c.d Default#�c�b+�
-� :Clear��e�SH���品/�tb�)$Item��	�)�L�s[1Ā�'3ObjXv["'R 2"�H*�,D�szTyp"GRTemJAte�8C#�;= �PK�'A n*� (T ��'l/P)�  ~=.t8�te�:@|:r"By�() H<�, me.nFa#�i)�+�2hDigitald"�g��
*H9pm i)l)�+X =�*� 0��F1o(DoA&�hEvent("�Vte��y*S$X= 1,X|@/T^�2x#+� 21� Rec.P(� �~|"Log("Err"�En `{#�-:.�. Unknow sx\���
E-eL 4�8SyncRespon*�8l�l(�6+�h)�:    end
end  �  