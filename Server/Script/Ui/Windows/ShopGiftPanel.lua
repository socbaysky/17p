 local tbUi = Ui:CreateClass("ShopGiftPanel");
� emPLAYER_STATE_NORMALX 2 --正常在线状态

function� :OnOpen(tbSelectItem)
 @ if notP(c  or/L .nTemplTId then�\ return 0;�end� self.*�D*: 

��tbAllFriPXh:Get�List(�`L
(� P)� ,D�GridTH,@
�+(d p+h�n@ Index_nil��dwRoleIdS�P*�fnOnClick\'�(iC,Obj�l\,�	nLockTimer,l�)�#xX', �	.p�B :Toggle_SetChecked("Main", true(��Sel�H�	ih�x��1f@!�CP/>, �(��tb�$nfoP)I[�]�d+�H�'t �	szSpr@X"Btn|?	FourthOwn"; '� 'CFac|\Limit and �+[ ~= (�.n�07�Normal"'�p&dl QmL=�3Buttonl3�'h�, 1)�Ht�Sp�= �o`Icopv�+'�.  szPortrait, szAltas\'Player�}	SQl/P�(T-H�*H'�IN '0 P�hl X3*�StH� == e3+D��g�*2 p"Headd1�),;@Gray'�false)� eX'�;��	Sp 3l�{��d9
Labelt5Text("lbLevH�P�'�.n�/
tbHonorI�y�HL���Setting[*p(t )�fDn��	?�etAXxve("�TitleH;-�d4p
Anima`�.*.ImgPrefix �6l/���1�-HCNam�(Nszl(��nVip�/Dz*��'|
Hnh�(� ]� (4 Qo00�.0(�VIP\/�'�?@.� �7'� 1eS��_)�� Recharge.\	_SHOW_LEVEL['E]*H/'��&X�hapea�S`l+H(xLonInter@�p�ܭ�(*��,�Se*�-�-�Typh<�`(rtb(!".WjUiIA�y&� *�)�,�
.OnTouchEventL',"��e�"��ScrollView:UpdZ�(#)�, '�X�'�"�*�%#�&d�%D&�-*i(=��*�'.)| �4�r;tI"|&"8*T�
EquipExchangeaT�M�())tH*$�4# ��ha�-�*�tbBaseDQ&K�Ge#�#xProp(nQgMd(�P
'� '$� > 1h&�!�""t\
,� �hp.* s"-.+< �<�A)-�KShip|('d Data+�@5ortKeyB!{}�fX�
i,v in ipairsLb' ) do�`�nSD[v.n�X�0|@&+�#t&X�5"8 ,| /��� + 10� '�&x',[v.dwID]P��d��T]�'�(a, b'�$,.L�t^#[a�
>)M b��
`�able.sT*�,|kL�'t'a
x/�6Close�6zA:U#�0$�)()X4� BuyScuess( bSuccD, nGoodsI�Zp3�`1tIpS'y8.�,�|-+�z
ot'�,� �2� x
P)|�%�5+,me.CenH� Msg("未选中角色"�*P!%0:/��~3x�9�商品已切换<�loca"t?#�#= ",?ppMaillx�i(�PV)�(�=��)�nM3I"�6,L5h8��#��.$�'�)E[�'�]�	RemoteServerV�nde(q .p b�.M�,t(h#q,1,�
7�;20Lock�] �"l1
y.�c$v== � :RegisDG (Env.GAME_FPS * 2, (��dH0n%2@enDgP .hE,H�$X6.+p	��{-� �`��+@"�Ahpl -��	WindowȆ>,�请稍候8�wUi:*��UI_NJ+) �8"� P�(`D{};

,T .Btn�T�( t	� d+�)2l�ancel4 	Sure4  4P
"�.a.'� +�,x'�8x�O h�(�;0��效 $@�%�Q@,�*)�| �I"\(*� .)()� tb|�|�Lh3�+`�K'�p�9� 该外装不可赠送 �fnYe",F(��di --注册购买成功的回调�ta&:)(� d,�= (�FID'R*�On"�Y Request("Buy", "Dress@,���, 1"H2((.nPrice, j	.n�	��)P}dl�| �RszMoney"4H5t�5�+mZ.�|ɼ�t��`7hhY	wz(n(�Id, Hh&�)�Sex}R"DW\�'(.,P T,�w�Tip@string.f"@PL' 确认花费%d%s将[FFFE0D]%s[-]�E给+T 吗？/��*�|"�:|�)rszh�PMsgBox(sz�,�?{� j0{"C定"E?neR}��取消"�})

��'�
h�'$#�9�̸2^eg� =�)� UiNotify.emNOTIFY"0?
P_BUY_RESULT,p( �ZOnPR$+��
};$�3$)l]	egEvent;
end  V  