 -Require("CommonScript/Activity/BeautyPageant.lua");

local tbC = T �.+� +� UiSetting)� :Get'^ ("+� ")
�'� .szUiNameD�SeleGon"1� Title p 武林第一美女评选0� nShowLevel\�	.LEVEL_LIMIT/��PriorL%E2h#� REFRESH_SIGNUP_FRIEND_INTERVALN30p '--这里的奖励只用来做界面显示
--本服排行��.tbL`2WinnerAwardD
{
	[1]M V��L� \l 	{"Item", 4872, 1}, D雕像L*| 38, 2�5级家具摆设-� 63'$ 坐骑外装（紫色）-� 2(�头1�0'D	聊天前缀-46'� 称号.| (��特效-� 3(� �框-� 5(�世T4红包.� ) ��族'� },Kh	[2+dO十P.dd/�3=�2)�247=�(�  �( @E)�Xu}` --全7@Final;@决赛7B39'�4@P!�Z6=@($.B��CZ带�I1e1'�I@ *U2Tj�;:e4'�2-4(|��-� 3.,1d(8:e5'8,u	l;T'd�48dH0�>(3 �(P:�(��+T*�4(L� �((9�7(�1��j怽Hc投票参�P�t�O�199P�%��
tbParticipate,�)y4(d�@!)y 2)|�)y 5)x ,/{"EJ�gyL�15000dH��G38000.�� ()<地毯-()�/+525)X��'�525(�)�'�30@ l(	L(�	�,<*`6�%
fun#($$P&:OnLogout()T self.nSignUpTimeOut = 0'd LastSync�Frien"!0;�tb*k Lis}{D@h�-�Is"%MainButton�if not l :IsInProcess() thenD
	return false_endm	�me or me.n$�&<�	*|&> �truYe�-�";,est*�(d($�+nNowC'Getu(("*,	s�+59p L�+U(�
-�n2() >=�=\)�)9�= xh;
	RemoteServer,�.* L"��&� /�	vGIs�(,�	x'��h'�P,� 
8h��SwO(tbx 'it6~
	f\,_,nPlayerId in C�irs� doLM�80['� "�&1D�		UiNotify.On�('D emNOTIFY_BEAUTY&�/LIST\�/�DJ/�P�b�'0p|a;�~(. ,� and ]T_�() �j,� 7hT	Msg(nType, nV�amx�eChanneltXf�I(iD��=�� .MSG_CHANNEL_TYPE.PRIVATE'En,(TtMgr.\ �.PrivD�\d��EShipP�	HeInMyBlack(�)'e	D�Centerd 
"对方在您的黑名单中"H:			r��zenA�	� Xwot Hh:CheckSPx
*�, "1Tݔ�(�
��lsA"�0t
 ��/szA,\+LinkDataD0|H"�=�mep5	Cha�ache�(P�%, /(T@�+h+ ?Ph4�	a,�DT�-ChD'�v~(p�P4� m�FA�iU�e# #Frame(sz� ]	c.sz1� u"z�
4xLc1� (x
�68t6LOnRefreshVoted��
�7bHav�TNewInT�mation.tbCustomCp$RP.fn�-Re"�?�p�	EGb( ��&�F�SRedPoint(��	,�2� �$	--最新消息Xd次级�"�B 
需要带上EventId做参数TF'�OnNotify('D .�	VOTE_AWARD,  � (�U3ets/�Ope̛"QK(\	Ui.H\�	rTextHandle:� (string.�/("[url=o@�.Url:��, %s][-]Xz�A�E)f+en@�3(Main $ �	0(dEntry=5n\hMiniMappN�#�RtbLg$PoshDS@p�X )\ (me.n�mplateIdh,D( i,v i)��xt�	)��if v.Index == %�Od$ant_diaoxiang"(�v.u L"tK��冠军" Y�	��	end
end
  �  