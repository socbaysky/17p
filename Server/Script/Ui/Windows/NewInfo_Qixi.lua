 local tbUi = Ui:CreateClass("NewInfo_Qixi")

`.szContentH [[
[FFFE0D]七夕节日活动开始了！[-]
 @ �，原名为乞巧C。��L这个HL
起源於汉代T 东晋葛洪的《西京杂记》有“\	彩女常以K月t ��穿@孔针于@襟楼p��俱习之”\O
载Ht��是我们K古H文献中所见到T最早C关D�X�	。后被�A%�T牛郎织@� 传说使其成为极具浪漫色T@
�爱情X�&S一Tx7�5�3时间\2：%s~%s((	参加条件�等级达P�%dHX0h介绍HH
1、花酒诗剑�@	通过领取�
每@=目标T奖励@.或进行�帮派贡\-@H	能获得道L#@)C;菱@T(D�味\*G 言T7DS及���小LPP分别合X/0�K与�
�T	D��/亲密度��'�Q�X5�男@?L好�X(�队h��当面\@ 	用将礼物赠送给对方d�相应-H�「�」'�LTH-H 3� ����D_7程\]'L�(�-]�8� �?�注意T	�D @ �?�C*�Oh多��5个L�Y�>�Y d"��和收@次数没有限制'� �结�U��P�	还可T3�>@�-@但无法�'�+�2DN	玄香拜星�G8拥T)�-��H�' 	DS3（�*��@_也K）@�XL)��]H�W找�纳兰真z��\p)Xvg���\PL&'��/�W�W�单独�DhL�X*�r��H�L随机H地点燃\��)S完LqD'�		大量经验P(�8+M @ GL天L#H;,J%dXDD-��D期L�@\H�W�直�累计TP$�=*��协助T他人�� /���*`*�X�失效H)�Y�2�]D�
function#t :OnOpen(tbData)�$� szActKeyP+  = Pivity:GetL@Name�[1]+� _,TTp
0� UiSetting(�+� szStartTime`Lib:lDesc10@�
.n'� -� End`b= 8� �+� ^ ef`m ='�."�$.Def,�&�$P= strH	.format(self(F%, )Pp�,X$T
.OPEN_LEVEL�IMITY=D CHANGE_ITEM_TIMES�HELP_AWARD����2:L0LinkTexT&�'#4(Y �@tbxSizeT8�
pPanel:Label_IAPQtb("�"H)*t-� Widget|p("datagroup2");�,*��D/� hp.x, 50 +@*�.y2, DragScrollViewGoTop?�UpAe,� /� )�nLast|j�PICePA,P or 1�if (@)h() - �,� > 60) J(LPaPLocalDayB~=�\*P 0)) then�l3RemoteServer.Try�t\iv(X@tl 00L9T��
end
� -xCMsg�C�
�KszDM	"��*x��：%d/%d\n��'���,� "��Hk@\���.x.��D)\0m-/hD
.ACTIVITY�k_BEGIN)@O�9�nGrTYP
`SAVE_GROUP*pnBaixingSme.@%UserValue(�, qC.�_KEY�3�Help=H-D)�0s,�v3, �D|YA%*3P\tX *� .��return �
epG%:tbOnClickY{�%BtnNi�lH'����	pT�!�
Xselfy�M/�	oUi:l Window("MessageBox",�, {{�() ^}}L"确定"OnilDp true�end,
}  z  