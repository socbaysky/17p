 local tbUi = Ui:CreateClass("BuyLevelUp")

{.sz�TextP [[武林公告：
 @ � 	急需人才，老朽得万l��相助H 以罕见灵药制成丹LT我虽不小气G但�极少Dx
��有两种方法�1、家财~���  若侠士D富过Df	��X6000元宝购买@[FFFE0D]限l��枚[-]。�剑h
��享6H\上的t��可'� ��费领取@O
2@	义薄云天/�交游广�p [	找'D-�及�且� 亲密度达到15级T�赠送\�	与接受均�只�d,�次机�|DT<慎重�]])�Send L���湖纷乱D还望借\L诸位�TD���D/�此[H；�-如今����"T回�
@
�Z�L
长实力HC%为�*��,�1HA好友X��tM�中�,挑�TX|fL3进行�2PH其快�H��级P早日��q！
]�0function�|:OnOpen(Az @ h~ learRedPointNotify("ADvity_,E ��nCanNIDH�Direct؂:Get�tem�if not (� then�.l
retur�YEP�xself.yT�'� ��iPframe:SetGenericIO({"{ ", ��, 1}��'� .fnClickT-` Default�+]b��szT!FailMsgP,HCheck�(me��*8bFree\'Cme.CVip�*() >= +R.np�(E:�|nx/(h .pPaneld%�;eI�tx�$� or�&|x*�3InQEe.and�>�*�=,'�Help@
tF�\' ,`�9� �W�*Q,KhD|,| ExtPaEI(�x"TN@F1�Label_@Nz("�	Num`� � Up|T��- x&�sz`l'D+�*�B�9�<-�HS7Txt3�"��"h��5�"�)��"h���")X�u,�. 
dy�/h|:H/+,'�
pDdD(� tbLis"�!,� TcAsk4d|DdVV{})�t`(Thd�next(�
@�tbUi.tbO'{�	�*H'��$@dl H��5l�t+hj--'�ounl�{yNCdInAllPos(+�.n4`
tHQ)��
En� > 0 3�dL�h�Window("GiftSysL�",nil,{ndTypeTi.p ~.M\�r,nnId@9��ll Telse�(`l Px  RemoteServer.TryCall+iFR�("Dd l"*d� @	�7�| -����Q_"k@Fri\.4* d	H�xd-X�'�@j1�T�+,0X`
\?CenterXŁJ.*� -�end, ��' 0 	�Hp?X'�
ܢ-�=@�nPL�pL �2)��
fnGotoRechargx(D)� p+-CommonSho}�"�@(, ) �-(��X T_7�H?H:L�MoneyPlold") < �0`H(D�"�1 不足，请先储值.�
p,<d�t* .Tl�`� (�eR \@"<\�(t�)HzH:,�szNamx<+�T8wInfo�f�Q, @)nFac"�+�Sex)LdHLm Box(string.format("是否要花费%d�)�7%s？HE�8, �), {{��, f|
}, {"取消"}*(-\�PE#�%
ity.Regressiodvilege:IsxButton\�0�7,尊敬�&�9 ，直升丹仅能�#*;�"�6"�0��W到$�:V%d$�2可��获得f��K$去�R"V5��S接�&0�<|&1x.LvUp_"�*v�(前往�
I-f+��*���EH}*�P*3�fn�M*tl�M3,�T\�$++d
h�)	-`/|&@"�uend,
}  e  