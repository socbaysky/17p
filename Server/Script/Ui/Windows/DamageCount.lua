 &
local tbDamageCount = Ui:CreateClass("BattleLabel");
� emNPC_FLYCHAR_TYPE_HIT_NORMAL]1Nlod5� DEADLYE2>� MISS]3;� UR)�4?� '�5?� �6:� CUREI75� POTENCY_VITALITu94 �STRENGTHR
10<� DEXTER�
11<� ENERGz12h9function,	:OnOpen()
 @ self:Start)�(oAend90� )<ResetInfo�	V sX.bDmg�Q�PtrueP*)� Show� "开始伤害统计\nP 	时:0分0秒�V'un��Time]0P|if (not�n�pr) then�h�,� @	� :Register(Env.GAME_FPS,�
OnFlyChar��t(l
�)� 
7P*� +sUpd@v�'@returH;�(.p-�)<��Hi�>p� = �&�u�B�P /� Leadly�/2� l+� 1MissL� /� L,� /� itMax'@	/� l+� -� -x
H' = falslUh�#�Shgl>@�	�,HN��^mr-�	�:Close(1� �GH�L/_
nil�\�@� 9�	�� T�
<�-��)lof�szx%�Q(�&��(or 0) >p ,h�ntSpan[zGett() -�,,0��0�PLib:tDesc('4�5eXD�+� XT("6��"t��szMsgTstring.format(X[[造成��:%P�受到)@ ��心)X �-X 丢失�	闪避��最大//X �%s
]]),�l�Z'�0d Tr�i0h ,h0| h)`0� L�\�0\ @t�0` @�0p t2t �C(��Ae:'<�9);I"k` 
9�,
nType, nValue(�'@-�,����XDM@�| Ph� == 5'%�',Lf.n'LtTx�)E +�\�#xb �%�&6�)�+�*\  �# (5�pE*��+ ", 	yU(+3�XK�a(�(I + @d8XP�=ɟH�+ `:�]
D*�*�+a +/�$* �
\�>T3�xS�lL�'�(L!,�h1� =(dl -�  |6�o>0h 4\0 8+� 6<t�)p*D5TH�T�,�(�^(�= 'XX���i:,x��ya�8\)/Txt��`
.pPanel:#<_SetText("�", szxh�Up\ �7&�0Event&4/��tbP� =��{� p
{UiNotify.\�OTIFY_SYN#%>_")>,pl �On+%}��}X&�
�� (�;
end    