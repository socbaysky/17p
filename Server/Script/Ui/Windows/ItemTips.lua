local tbUi @  ,= Ui:CreateClass("ItemTips");

--目前只是魂石，水晶` ��鉴定装备用这个页面D�`�Setting =
{
S ["p "] = function (self, nfId@Templ\�Fa�[SexT Count)�	d
q:@u( endXd	["Digit3rsz�alType9��4� �*�Skill3�n�� �Level1���4� 1�Partner4��Id1��(n�'� *Ip <t	ComposeValue4Seq'\l;�SnIcon, szTitle�psX9QualityTR�.��:GetShowInfo(n��*(nszrAtLk`pSprite= `3llHTLdnhl �X
Other({szNameD)�Intro�|bHideEffectWtruMn(�}, X	�X-��'\ �}�*,AddTime�&4�� ��\+�Des(n�P	 \��(\#�, 0� &��?3jtbqN,T�pG14�(3� *CollUEC7�lT(�1�)l]XtX�'���}t�'|d�:InitPosu(��rtbXLabel1P-xA.pPaneldfIin�("�"��POS_LB1_X\).x��+� Y-� ydto.2@�7212-212_,2.'�HEIGHT_FROML 
106  --背景最低起始值)|�PART_'116T 第一段tip的高度H�5� 3|40 ;H	按钮区域'� 0� TIP_BT^40t底部$x �)� ��-Siz��L��=Widget_T�p("Bgh,��#WIDTH_BG^tblx+HMp8-- ltG2 是T	定会显示H�
1手动控制K不T B
,�
OnOpen(H���...�Nif not �(�	E�n�hIq:1���q.�T�ĝ�$FuncSe��bhm*)%[�]�	assertT�P���XH	Active@+tnGroup", false\��1)� TipBottom � HaveDt�*\fnCenterWnil��fnLefx/\ Righ1` ���_@H�orBy~�("t ["WhL�%H+rtb�#%�)..l:�$�.bl�"0#`h��Is�'�1tRh
PA)� the-�)Change-2P��HE�,*X	T��'e@4�l�� \X�+_1_Y�
nd|fp
�tbhj\3*��hrPrint`̰'��nPrt2He�6�	.y + 25T�25是�	2��x���外��, nTotalHe�?�ܛ��+ )��#:$*4P*9 +�.����
ep#h#D��.()B�h) ,�*�= *4 1�3l�dT'x/�(.�h*�,�-+���(�'�p*�.t	'�, 0, 330 -*tTJ�
'@�	7X�T�����Lz�MF�, ��,+�HK没 "h8ve 不h���行碰撞体GM自T�调整所以放��	End 里了
�4$X&�"� 
��)\$3�LMain#�/@Ϝ L�2z�RWstTpg.gsub�, "\\n"x n") *`�D+�d���L�0��s"=LinkText�&00�}�{p)��x��6�D�'�@[�L�< 60-�+{ = 2.| -�!..MnPXdl t�-54 5"*-nD�p
l  ��;� .$	 lB@y�n(`.  and �"j Id-@return��t�8pl�lx/�Y<Kt.Get Obj$�/I*H@oot �,4p+0`�`l *U=�.dw(����U�$�3.�BaseProp()X�h��,�+�1�%� T[tem+,&Hnfo.sz�%L&Ut&�!�3L� 是"�L\���义L��| '� %�"2K�x�����U)�L)4 *� b:Id|�
��+�"<%H,�*� tb�Lu.�[)� ]H8�--图标�nSexXPlayer:%�O2R(n� or me.�, ��@,d$�D, _� &�>D+"�'#�9)T@:�2�#�)Lp"�:%�E�(�)`%(*P |6\B2��)<Disp@#y/(�@�#HH�@�>�
�.���`vDefined�P�.h'��|(� �e{*L.h	*�H�T�,|��ѐ�"�.��&�.��-�/|H��+-�/����#��Details_�5X~ By��*�JAilP �AD|L�cp	:Upd"TZx�"Z(nCx \2�--描述��i��1(�/.�Tip/��\/�x5\ ���5�n� s��1 ~= "".),Y'A% 9�91", #<!�7��='� �\&hl t+&�4�tD�:�>�`2�lse42�*�;)�+�"H'��%�+� $l<@;�\*�4 ,(` ls�	�-� �!�1�= �
`?)� ()�_t)8x1�l ,lx+P,�	�l*�P�dB��*�h	D�;�[�2`	xl �d.�D*`� �/0 'T hG"�*H=Buttonf�By���8\L'���+x_,D 2�d�ST�`@q� *� +�Tp�'���-��5"J^Ou"�Dl��D"CVimeT���
|
�3�0�t0&�/2`� 	"").."\n有效期：\n"..sz�	� @ �]  ��l't3/�32L�,ND,H 8(`� #�!��deh>\��H���=4�d(�(*T/�%(��sDf`06�#|X"�.�,��$  �+� tbUseX%"�u(�t$`&t�(x -	t)� Et�tH(� #=*.)�4��8�t*`?�*� L7Firsth5"�c(#.fn�-T szSecond3� �-� bForce" (XO`'�8�D.OnSAll��t�"�-�1�
"全部使用L�i.�	, "/X lF9po( ClientP	 ;�nd4�CPH:�z#4t�n�PF�or 0PO*\
��XE��Tp-�"%,(\�%�X*\�.�&7|\�\lL;p:IsMoney"�~T��u).�#`-H�Get�|I-� ���.� Desc4� lL*l���经验值"����货币的数P道具��`\"未知*�Bs'0%�Hformat("%s x%dxP�, �5*hU%s*V� =[�Exp.()p'�*�#� L-,获得%d点角色�Pme.True$�QI(�*�x'3�BasicP2���nIeDHDX;|AwardP+�|� P�* �)�es6� ���=Q"�$@B*�74%�2Honor2D � 门派荣誉\n[FFFE0D]（$ U兑换�竞技宝箱）[-]X9�&*�-H�� TBattle�or s/�
)� 2 �战场�7�� ��� �VipPS $T�F 4'�  �	Domain�1,l�= 城H"�!+�每800i��"�^�M� ��� �Cross "p跨服*� �*�  �*�  
�HSLJ ��山论剑�.�%s.$)� 3� , HuaShanLunJian.tbDef.n'�Box9e�)|� �DXZ '雪48+��� �� 
,Indiffer @	心魔幻境�+h*X� X0�+�nd$�#e`�#0(%�(#H"pH$LIl�E�s#�#�C*� )�)�"I.�)"�7/}:)8�,>���$"$BT�"�/"t5'� Dting(;����#7-con$���#p��"��, & ZHunpack(��#�
#pMP|Hm*[['C�0] T �DEFAULT_COLOR;;`TT'��"�H�7\&�/ $%�%*X� *1'Gp"T�t�)$ �Layer�I"����*H.�,�(� \�,�
�d�C8et�$l.�#�U*3�(� L"8�Anima"�D�^D�j/�E"��ner0P��FhmXK# �_ Npc&]#$iGetOne�Base"4F*4LhB�	#�UOKX"�BY S'|�P(hl&(� -�(�L	X`lFace(�h(�/�^'�8�szDesc\�l	�`*()PTZ*�d\
`�< 
��S:hiq"#h�'�=  	 p�"�)$$0V= �()<#�@By(�0p�ؒT2`h%0?x�("�X\��0��F�p6�5���93�/��}D�D6�9ܮ��G48��.sztr�B	什麽鬼！,��	DU䋌
Dᰂ)�0� +lF�xx,�'9IpМ&��q.3�e �/�h;'�b|�P#�XP�@ (d�%SuffixL:*�if"H�nfo.b),�,L4 �8�HV*$](�'x,� �H!l�;�`8//�|�_� -��\QD&L�}7()�Y@gx�)X @�)4 )�
%<j,|  --强$į示�#d�)� *X
`Zp(X18�,�(H+t�l�5����k�J"�!+ +�
DT|y|�'��T%:��L\T ivity.�,AndRob"述�nl{Num FtbLx�i C"P{7�sz�= -�O
[92d2ff]拥�"HH %d �件Hh�=�hT/�#�!-�'dPG�`/c;Mai%}�t#8�@-4�pH-()fB- q6((� (��1,#|�X �2�X $bM @ Tznot �#�ax}.�Z,�/<j�D] ��果原来没有或只@1个�_�"!��	能出售则$X7添加����� and t")2��$ ��"�d�SellnK" #^ � @ P#�]CanpWare(me, *, 1.�^E �XszOl#h�-L" x#$���T�(�is+l E`"�, "x�2� @8x	"�ts3�(� LEhl �@&�4Ti(s��"�t��]S(0)�����jre4؟\type(lL(== "�v"-��\ m[�"�h�`*.2)#�`8,�$elf�	2+,�`&�+4���H(�2-�8$"x�X��%�	`8� R"�4 � $l�H)�'�fn�\*�*4��(L\<�T
�Dԅ`�=�	�3�8L� )|8� � � '�*|�fnp,����20�1,h	/$�	�d1� �'� 2X'�%x0"I< #O�Use`}&��m:'�ut%|iI"ܫ�VQme"�:|��InAllPos�(d3) > 1 2�wen%�K"p�loseWindow�	UI_NAMEp�.%\
ChuangGongDan+ GetCl#��+� "):/� �)��L% 6��
 �%�Entityp.� H1�(�-�local bRet"7GMsgPOT7 CheckNeedArrangeBag+@p@l-0`ppenterL	P�T |3d� *�nen�<p)>szPX�.��:�Is�MaGial�C),*�Px� <�IsE�,�,nTargetID?an�l�.�2� 1�
RemoteServer.��.�J6d�8� 1H�Q�0�f
Id-�C.�+XXsH
t�=iIx�6Inset�:��p�PnEquipI��#�"��D:StoneMgr"\0L>�3��
L(� and next('I )- �n@
Hd.EQUIPTYPE_POS['� [1]%d�(�p�@Pq\��ByM	(`
H�hl P�the)��l� X�.dwI)�en�'  H+Openȴ"Streng`#��^�St�&XWryst2�#d,)� "#�D�+D�Me|1�	XVbine�=�)NT-)= ',@$p#�V��J(� �pT%}�nx(t -�re"�)�>�t)�fnYes@*'�( D|l �y�,��@�MPLDL�meH�"�`n(, 1) �d	-txT�h3�x� me.$�"T���, true)|iex/`� *�l�(x+O|��4s1 *���#tbBase"�\D#5tA,l��D`=�n3� D&'� ,�for iD�
ype in ipairs*Zdo�h"l ��X\D1unx)X`P(� ,xl ��u@D9P[*��T�"l� X�p�(�.n�c > �.n�q�x  --因为现在是每件� 只对应一个位置#X��* -	MessageBox",,(� s$��\0mat("你�的%sT能镶嵌%d级�，\nf�����合成)� 吗",f.E|�"0�NAME['
],0<"9�B�T.�&)6�{ {��},{} }7� "�P"取消"'p�(�. �  �q�| +@ '0 ��,�`��'�#[0Sel#�B`x	DGx��yrYId-�*d�
x$XConfirmh
خ�h��/�d�t �P�v.U�	
:DoRequestUnc ,F
�
x .tbOnClickEm{H,[ .BtH@# �'��
�oX&�&f�hi�/p#,p ���$ == .�4dJhCl5�4(|�x�� .X}R"�?\= �6� X�� �6� F'�dJ:OnScree�ME�CrNUi)	z� ~= "g[are�2#1%s+x xG+� ,�:�*_end"�N.�ResponseFbi'&l#�9&p[L1�ӨuntI8|@X�"��HU�e%LC5�[,(&h]拥�=�]�   Xnh�'�T', \m.��:��m�$� -|g7��T��%�A�9l�(�'-���$)�PH�*(Jar.�*p-�Z5nC"�c T! �' Zp"Ge= s ��P*�55z�l;3OnDe���,)H#X*`TP�D?�-�:���� 8#�{Data��p"�e|��.���(�, I2n%t�\=�/�.
p%p@�(p /��Ds$��"9a"&���$$iLG4�.z.n(Dt�s$��"�o@�	.��j�Jt$�L`%@�#@O.��(]pxWnil�`m�dD=,,�+Obj+H��.hȈ�}	 �l;(&H�$�-�.GetP�-�	s(��"�A\%�*�	�'� p'0 i�".pt\0��i1", -�7�%��(P^�h��"h�:9ColT��?%���(�=&�})`�,��x	3� B0�<.$�7tle|>�L�#��CO790d9 -- 称号默认"���	LFu�n�? dK�t	�L ���h�sz�M"�"�(u p"\B"领取�#D�1� �3 l�(vtb����TX"�|�B�H�,4(��.hG�p|�-*�&t�%s[-]�T�� )p
'F= ��R(�(�.`2 > 0 ,�t�/@,�h('<'  *�'d�K�&�1,�%
RegisterEvent�ƶ9tbP�dYhtY�  UiNotify.emNOTIFY_COMBINE_RESULT,x� �mOnR,M'})�:{14SYNC_ITEM( (4(Dd�>+DEL2% ��� >WND_CLOSED,H�P�sClose�}P��7�4(DEe4�+��1�ĥ$���3MainL�0, 0p�58'P(szWn"t[s(if � ==-�/T�(d t�Comp'0/t x.4 
4#  ;Y  