 local tbUi = Ui:CreateClass("LockScreenPanel");
�fSpeedH0.1 	@  -- 每帧移动的距离�
nTimeInterval\tL定时器执行XK数�f2CloseC0.7`L	超过这个�滑向右边自\解锁

function�:OnOpen()
	Ui.n(�StXXtruePself.p� :SliderBar_SetValue("�", 0m"	+� etAEvWTipHh
Cend0?TryFrtu#r�locA$f�\+d'!G. �if �<= 0 thenH p	else(� >= 1+� :�0ST"�th)� Cand' �7���@r\�:RegisMB(��C, �UpdL22Left��0��+�(� �Righ,�e8	�8� 	.t	)��$ 6,�%s(nilt0�%�U5�			return faD=T��Nex�[D3�H- �|H+|'
S.
, f(<�A0 or)\ �8�~b
�5 �0 )$/U.2$-� �+ �>@oaY1 �,�4��Fi�lD�Window(�<UI_NAME6���v�2 P��(�} � ��)��L��|�TN�h�A� .ROn��`��l5� LeaveMaphL��4�	P� 主要为了清掉拖@�D�	状态（不�切地图Tz؀��	有问题）\g\0 UiManager.DestroyUi�"/�h�.tbOnDragED�=
{RBt��H%'D�E*	��:0,H"F�}X�+XP P�.'��'`.���`)�'�d'�Eventi2 A l��tbT�� HY Xx l  {UiNotify.emNOTIFY_MAP_LEAVE,	�On�=},
y}X��'�;
end  �  