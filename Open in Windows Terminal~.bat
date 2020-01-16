@echo off & pushd %~dp0
powershell -noprofile -c "$f=[io.file]::ReadAllText('%~f0') -split ':bat2file\:.*';iex ($f[1]);X 1;"
exit/b

:bat2file: Compressed2TXT v5.3
Add-Type -Language CSharp -TypeDefinition @"
 using System.IO; public class BAT85{ public static void Decode(string tmp, string s) { MemoryStream ms=new MemoryStream(); n=0;
 byte[] b85=new byte[255]; string a85="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$&()+,-./;=?@[]^_{|}~";
 int[] p85={52200625,614125,7225,85,1}; for(byte i=0;i<85;i++){b85[(byte)a85[i]]=i;} bool k=false;int p=0; foreach(char c in s){
 switch(c){ case'\0':case'\n':case'\r':case'\b':case'\t':case'\xA0':case' ':case':': k=false;break; default: k=true;break; }
 if(k){ n+= b85[(byte)c] * p85[p++]; if(p == 5){ ms.Write(n4b(), 0, 4); n=0; p=0; } } }         if(p>0){ for(int i=0;i<5-p;i++){
 n += 84 * p85[p+i]; } ms.Write(n4b(), 0, p-1); } File.WriteAllBytes(tmp, ms.ToArray()); ms.SetLength(0); }
 private static byte[] n4b(){ return new byte[4]{(byte)(n>>24),(byte)(n>>16),(byte)(n>>8),(byte)n}; } private static long n=0; }
"@; function X([int]$r=1){ $tmp="$r._"; echo "`n$r.."; [BAT85]::Decode($tmp, $f[$r+1]); expand -R $tmp -F:* .; del $tmp -force }

:bat2file: Open in Windows Terminal~
::O/bZg00000g9HEo00000EC2ui000000|5a50ssI2/28h^lK=n!0RRIPy#+XO00000001yh/ZYy}Tu,RiZXjuHAXjN^WN(wKAXH]@ZE0?{Y-Pw?b97/BY&XwfF#u+/
::006xO00000Fi]EoAOKuXaAj]FX?K4^X?Me1cXJ@AWpZt4ZeeU)cXTdtWoH00Opw{=10xJufPjqv5Hi9505bqJGXMY&MS[a1@Wpsym00YNBx4;A38!{kg^]Vsl9_(f
::?$$aW(D,kOY5x#W{=Wcqp#Xva0BB|apv)XgA4?cv6tA^v!VDAII-PmUzV!l|&~Ra1d.lw4s,!fox]]$8TO]^GxjB,yx{?Hbg#Z8l|Ns9WyZ_^I0BQybfZbudS5WaO
::J]WTk5u1eh_}FB0Oi#-}yLkJ@/M5N+x({PApI/gT6opWQ#!!.7PF6(TU}$QQbJR[8h|kV76-wK}&^N7@[J3sSP3RNR3c{+do{;Y6$ZeKkEFC1tt@Gy]DKn=uK);{~
::Q4M8ESlJBqK_][oJ8CQri.]~&/1j5VYP6!00uE@eVDW,YMQu;ab?_!?Yz5R@N;@&4=EI1rkI17A)$J8VWmFiNXr;?_xCk0&W]Oxdo&GVHqI2nXb&)k+Q.YePldlDX
::;]m7Lr^OE8QQ.g)9?]j}KyP=ARlpJ(qJm3(g,jHJ]?FV+d,uoZ#pN/SPUeK{frWDK+lzN+PysV+P$p;i1)w=Z1KM[{BEfpHXk^9rOy#Id6jH2)B;;Y,kI4PJA]AE/
::.G58I1#lhH#=pIr,7Y3wr|f7~;VO(R=K.E8nkzuTBs#T??,9V5aWzdiWZHxJqMQg-&_HeixXi;,!loR2C,g/kPUBE&MX-vWN7+V)B#IR!psd[,cU$46M[)JH](hG_
::U?wO#L(iO40N$P?6D9Odmn87F#oh{GnyBc9MxUZ4m6$LjL7,l#[tL](]+6dJarmn7079;zW;;G$iY+Gr9Uj]9!k;uWBMv5R6OIkO|1wFui20j9oorLAh{eQ_CgMIh
::K4s0,TSfaKSdK^8,Sodc8I}dVAH0Vk=Nw9U9T{&-o,4Mpf8.rrYN;5I1oVzvi-h|mV|Behn&YbLSt6N#o.e++u.H.N@m[UA{-z#FPwx{j9p@zZqX(F&@t]S1;~STV
::5LAvdO9_w|aI9XPg7[Tu?28,Mb&HP@?HP&02xYBtDiF56FI$bF+xv&F/$o8woeki9s-k4qS52971z2UgMrC~iE1xIF]qJ]P8n04}l=,iHQ;vmN{lb[1(tYIj]P807
::atn0~pw3RJ2BI.v7NiCZ^3fjnR0w/i/P9!u#xOF$h$FUxmuYODnaV#3XD/X/&MbrhdEMNEtle3}e}S+nL/QaNs]7-5dUOq4$)y|IL09!z?W{Cu9~|#1(iFg;vOn3K
::t2q8$,Z]jq=Wp^?/G{{CDp8L+$5|H3(t9/tA[y9l1YM/r]cB^kyHxl2pL!v#uMPaKzW_t
:bat2file: end
