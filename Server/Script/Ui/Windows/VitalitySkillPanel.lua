 $local tbUi = Ui:CreateClass("VitalitySkillPanel");

�
ITEM_PER_LINEY4L�MIN�_Right4k Lefe3Ph
function�	:OnOpen()
	�
pCurEquipP	me.Get� ByPos(Item.EQUIPPOS_ZHEN_YUANtif not (� thenU
	P CenterMsg("您当前未装备真元"l	return 0H	endXself:Resetl�
,'t  7�P��tb�5InfoD%a#:L%�9ZLYuan")p�AttribTip('�h�.n�ID, �LevelX
unpack()�L@�tbIcon, sz�NameMFdA�'�Showa(�IDpK	-- ��Setting5�'+��	sF5.p�W:Sprite_D
�("�z",@Oc.szx �-R At\b�
�nSRMax�"w-.tb�,|�TH��(�.n�I'	*�LabellText("�Us\4ng.formaX等级：%d/%d\�(�P )a)@'lfExph'�liIntValue�i(
.nlKeySKD�@L	�MnNeedD\2l-�(�Up��4�x�)�pl�P��Txy�	 > 0 �y�/�FPPercenG&BarX$P'h.min(�
 / �, 1m%	:4\P-,�0�floor'v* -p�*�-ToT	Param), *� � �  ))	H#elseX +��XpI1)1t0+� -�	XP"已满TM��e|�\l��AtbAll�^s@BL�FindhInBa\����gtb��sLisj�{}\
@\ i, p| in ipairsL�*�) doM	XA�mXSR�le�+()+p
	table.insertD	+���!�)�PZ+� H-� -; --由于都是不可叠加的，就直接诶按道具id来了�(�WtbL\�p'0@aLt:UpdT�gAnd�7�4� �<�]t�x*l h*l �"t,l�/ �;fnClickP%'� (X�mObj�,P6�.bCanAdd'�J'lLLI@؜�?�	�l{Q�L��`H9�P 
\�
)�H|	qCW�s("�
 T�	�� ^		x\��>= +�tX�GE			P%)P#$D#,�		%4#��;		heM.� == (y	6d�]��升�		/�		(�ֺ+ �TotalE� T���6X"�& ��经放入足够多\m$�&@k��		2 p:OnSel}8(xQCR"x"`yo,�,N, �V��Index�Y�(��P*�`Se�lXE�`D�`GridL	'� �nStarq�(@�ex -Q� @�*�-U	��S
1, ,�-���`��T2q[�+ i]J�		�tbdRtb�p\r(i�l8�(h�' = truet�
MathRandom(10}�5�	�:�#(�
.dwId #f%		���,P(�+.)���.x LongPres|Ҩ.DefaultCt�,� &!etActive("MainP�tL d0'|0� CDLaye"�!"�1�̜���'(0	vil+@:Clear(��#0��falseZ		�Q� �TL�AScrollView2��( #�!max(�ceil(#�-� /,�	), MI*�7AfHk�_); @  -- 至少显示5行
��c "�9)LZ�crqPs".Ta�(�p�gpMovelX'(� [(� ]@H�d2(� �X,5Et#� remT
@vP%l\(@l�'D!(�'�TX	p(�,L\�(�X<� .�8��tdy�(L	�tf�\L'�(ؒp��/p*1,�-��)�`
�\8%Q6f�;)\$hf�, ��h(� �w= (� -4l`<xdl �?pXm,.,�[�̜ll �(�sD6�ll XF��&|"ll �q1�uhl �)HL(dI@	xl �f(|�4�  P �dl �?��� 
h�.Tcɉ1�\;(*
:$|  ��A"d! �H�n'""= `KDJ&c':Ca#� s�&� `lqt,(�IT_'�̵-d5"h?PutIh�-09"�&#\#'8#	，总经验#�?\ќ�%�9�"� "!Lt'B�O#H4)�9 "�;'�*�', 8�ynce(L��%�K\T�C'`к@P�9� |U-O�^Hd"8-T( :BtCose�
"�RlQWF�ow�2UI_NAMED2D,%L"�0Up�	T}�Z',,,l-"*��未$*任何$�)!$�),h'�v'Id"6"{}P&$B',v)�;�,<&�;-��	, v# %D��local bRet"NMs"�LpP(PheckCa)`1^ med�hL|	P"d�i	 ��+&szXd(�-�.	RL�teServer.�*\H��`@!�8��"`N�5�(�� �S+A'�Smed�
�"Id, ��DSMax��TT'T+L"<S(,tbSubh\5TTipa(�=���L^"p\�^$S"(UX�'�`2D
:RegisterEven#�Z @ �tQ<g� =�� {
		{ UiNotify.emNOTIFY_SYNC_"�1,	%�LOnSy�� },6� DEL � '<__MAKED�dOn���N }QH�ӥo (<;
end
  �  