$wnd.jsme.runAsyncCallback1('var R3="Assignment of aromatic double bonds failed";function S3(a,b){var c;c=a.x[b];return 3<=c&&4>=c||11<=c&&13>=c||19<=c&&31>=c||37<=c&&51>=c||55<=c&&84>=c||87<=c&&103>=c}function $(a,b){var c,d;c=b;for(d=0;0!=b;)0==a.c&&(a.e=(a.a[++a.d]&63)<<11,a.c=6),d|=(65536&a.e)>>16-c+b,a.e<<=1,--b,--a.c;return d}function T3(a,b,c){a.c=6;a.d=c;a.a=b;a.e=(b[a.d]&63)<<11}function U3(a,b){var c,d;c=~~(b/2);(d=a>=c)&&(a-=c);c=~~(b/32)*a/(c-a);return d?-c:c}function V3(){this.b=!0}w(24,1,{},V3);_.a=null;_.b=!1;\n_.c=0;_.d=0;_.e=0;_.f=null;function W3(a,b){var c,d,e;1==a.b.B[b]&&In(a.b,b,2);for(d=0;2>d;++d){c=D(a.b,d,b);Tq(a.b,c,!1);for(e=0;e<a.b.f[c];++e)a.a[Kn(a.b,c,e)]=!1}}function X3(a){var b,c,d,e,f,g,h;do{h=!1;for(c=0;c<a.b.d;++c)if(a.a[c]){f=!1;for(e=0;2>e;++e){b=!1;d=D(a.b,e,c);for(g=0;g<a.b.f[d];++g)if(c!=Kn(a.b,d,g)&&a.a[Kn(a.b,d,g)]){b=!0;break}if(!b){f=!0;break}}f&&(h=!0,W3(a,c))}}while(h)}function Y3(){}w(29,1,{},Y3);_.a=null;_.b=null;\nfunction Z3(a,b,c,d){a.b||(4==a.i||3==a.i&&-1!=a.c?a.b=!0:(a.j[a.i]=d,a.f[a.i]=b,a.k[a.i]=c,++a.i))}\nfunction $3(a,b){var c,d,e,f;if(a.b)return 3;-1!=a.c&&(a.c=b[a.c]);for(e=0;e<a.i;++e)2147483647!=a.f[e]&&(a.f[e]=b[a.f[e]]);if(-1==a.c&&0==a.d){d=2147483647;f=-1;for(e=0;e<a.i;++e)d>a.k[e]&&(d=a.k[e],f=e);a.c=a.f[f];for(e=f+1;e<a.i;++e)a.f[e-1]=a.f[e],a.k[e-1]=a.k[e],a.j[e-1]=a.j[e];--a.i}f=(-1==a.c?0:1)+a.d+a.i;if(4<f||3>f)return 3;c=-1==a.c&&1==a.d||-1!=a.c&&mr(a.n.b,a.c);d=-1;for(e=0;e<a.i;++e)if(a.j[e]){if(-1!=d||c)return 3;d=e}f=!1;if(-1!=d)for(e=0;e<a.i;++e)!a.j[e]&&a.f[d]<a.f[e]&&(f=!f);d=\n!1;if(-1!=a.c&&!c)for(e=0;e<a.i;++e)a.c<a.f[e]&&(d=!d);e=a.f;c=a.k;var g,h,j;h=!1;for(g=1;g<a.i;++g)for(j=0;j<g;++j)e[j]>e[g]&&(h=!h),c[j]>c[g]&&(h=!h);return a.e^h^d^f?2:1}function a4(a,b,c,d,e,f){this.n=a;0!=d&&1!=d?this.b=!0:(this.a=b,this.c=c,this.d=d,this.e=f,this.i=0,this.j=C(Hn,Am,-1,4,2),this.f=C(B,v,-1,4,1),this.k=C(B,v,-1,4,1),-1!=c&&1==d&&(Z3(this,2147483647,e,!0),this.d=0))}w(30,1,{},a4);_.a=0;_.b=!1;_.c=0;_.d=0;_.e=!1;_.f=null;_.i=0;_.j=null;_.k=null;_.n=null;\nfunction b4(a){Gn(a,15);if(a.b){var a=a.b,b;for(b=0;b<a.H.c;++b)if(0==(a.H.s[b]&67108864)&&3==a.S[b]){var c=a.H;c.s[b]|=67108864;c.K&=3}for(b=0;b<a.H.d;++b)3==a.k[b]&&2==On(a.H,b)&&In(a.H,b,26)}}function c4(){this.e=1}w(33,1,{},c4);\nfunction d4(a){var b,c;if(null==a||0==a.length||0==Lr(a).length)return zM(new ZK,n,!0);c=new Zr;var d=new Y3,e=bS(Lr(a)),f,g,h,j,l,m,q,r,s,A,u,x,F,H,I,t,ba,aa,P,da,ob,wb,Na,$a,U,pa,qa,ea,Fa,Ja,Ca,Ob,T,ua,mb,Jb,ab;d.b=c;Cq(d.b);Na=null;j=C(B,v,-1,64,1);j[0]=-1;pa=C(B,v,-1,64,1);qa=C(B,v,-1,64,1);for(F=0;64>F;++F)pa[F]=-1;g=U=0;ea=$a=Ja=!1;m=0;Fa=e.length;for(l=1;32>=e[U];)++U;for(;U<Fa;)if(Ca=e[U++]&65535,e4(Ca)||42==Ca){h=0;u=-1;H=wb=I=!1;if(Ja)82==Ca&&lK(e[U]&65535)?(aa=null!=String.fromCharCode(e[U+\n1]&65535).match(/\\d/)?2:1,h=er(Dq(e,U-1,1+aa)),U+=aa):(t=String.fromCharCode(e[U]&65535).toLowerCase().charCodeAt(0)==(e[U]&65535)&&e4(e[U]&65535)?2:1,h=er(Dq(e,U-1,t)),U+=t-1,u=0),64==e[U]&&(++U,64==e[U]&&(H=!0,++U),wb=!0),72==e[U]&&(++U,u=1,lK(e[U]&65535)&&(u=e[U]-48,++U));else if(42==Ca)h=6,I=!0;else switch(String.fromCharCode(Ca).toUpperCase().charCodeAt(0)){case 66:U<Fa&&114==e[U]?(h=35,++U):h=5;break;case 67:U<Fa&&108==e[U]?(h=17,++U):h=6;break;case 70:h=9;break;case 73:h=53;break;case 78:h=\n7;break;case 79:h=8;break;case 80:h=15;break;case 83:h=16}if(0==h)throw new Jo("SmilesParser: unknown element label found");f=xq(d.b,h);I?(ea=!0,Wq(d.b,f,1)):Tq(d.b,f,String.fromCharCode(Ca).toLowerCase().charCodeAt(0)==Ca&&e4(Ca));if(-1!=u&&1!=h){q=C(jp,Tm,-1,1,1);q[0]=u<<24>>24;var Ua=d.b,Pb=f,Zb=q;null!=Zb&&0==Zb.length&&(Zb=null);null==Zb?null!=Ua.r&&(Ua.r[Pb]=null):(null==Ua.r&&(Ua.r=C(vq,o,3,Ua.G,0)),Ua.r[Pb]=Zb)}x=j[m];-1!=j[m]&&128!=l&&Bq(d.b,f,j[m],l);l=1;j[m]=f;0!=g&&(Uq(d.b,f,g),g=0);(da=\n!Na?null:Br(Na,wN(x)))&&Z3(da,f,U,1==h);wb&&(!Na&&(Na=new Tr),Ur(Na,wN(f),new a4(d,f,x,u,U,H)))}else if(46==Ca)l=128;else if(61==Ca)l=2;else if(35==Ca)l=4;else if(lK(Ca))if(P=Ca-48,Ja){for(;U<Fa&&lK(e[U]&65535);)P=10*P+e[U]-48,++U;g=P}else{$a&&U<Fa&&lK(e[U]&65535)&&(P=10*P+e[U]-48,++U);$a=!1;if(64<=P)throw new Jo("SmilesParser: ringClosureAtom number out of range");if(-1==pa[P])pa[P]=j[m],qa[P]=U-1;else{if(pa[P]==j[m])throw new Jo("SmilesParser: ring closure to same atom");Na&&((da=Br(Na,wN(pa[P])))&&\nZ3(da,j[m],qa[P],!1),(da=Br(Na,wN(j[m])))&&Z3(da,pa[P],U-1,!1));Bq(d.b,j[m],pa[P],l);pa[P]=-1}l=1}else if(43==Ca){if(!Ja)throw new Jo("SmilesParser: \'+\' found outside brackets");for(r=1;43==e[U];)++r,++U;1==r&&lK(e[U]&65535)&&(r=e[U]-48,++U);Nq(d.b,j[m],r)}else if(45==Ca){if(Ja){for(r=-1;45==e[U];)--r,++U;-1==r&&lK(e[U]&65535)&&(r=48-e[U],++U);Nq(d.b,j[m],r)}}else if(40==Ca){if(-1==j[m])throw new Jo("Smiles with leading parenthesis are not supported");j[m+1]=j[m];++m}else if(41==Ca)--m;else if(91==\nCa){if(Ja)throw new Jo("SmilesParser: nested square brackets found");Ja=!0}else if(93==Ca){if(!Ja)throw new Jo("SmilesParser: closing bracket without opening one");Ja=!1}else if(37==Ca)$a=!0;else if(58==Ca)if(Ja){for(ba=0;lK(e[U]&65535);)ba=10*ba+e[U]-48,++U;d.b.u[j[m]]=ba}else l=64;else if(47==Ca)l=17;else if(92==Ca)l=9;else throw new Jo("SmilesParser: unexpected character found: \'"+String.fromCharCode(Ca)+Mb);if(1!=l)throw new Jo("SmilesParser: dangling open bond");for(F=0;64>F;++F)if(-1!=pa[F])throw new Jo("SmilesParser: dangling ring closure");\nvar fa=d.b,ra,ca,Hb,na,ic,G;G=C(B,v,-1,fa.o,1);na=C(Hn,Am,-1,fa.o,2);for(ca=0;ca<fa.p;++ca)for(Hb=0;2>Hb;++Hb)mr(fa,fa.y[Hb][ca])&&!mr(fa,fa.y[1-Hb][ca])&&(na[fa.y[Hb][ca]]=!0);for(ic=fa.o-1;0<=ic&&na[ic];)G[ic]=ic,--ic;for(ra=0;ra<=ic;++ra)if(na[ra]){G[ra]=ic;G[ic]=ra;for(--ic;0<=ic&&na[ic];)G[ic]=ic,--ic}else G[ra]=ra;d.b.J=!0;Gn(d.b,1);for(f=0;f<d.b.o;++f)if(null!=(null==c.r?null:null==c.r[f]?null:Dq(c.r[f],0,c.r[f].length))&&!Kq(d.b,f))if(A=(null==d.b.r?null:d.b.r[f])[0],d.b.x[f]<(Fo(),uq).length&&\nnull!=uq[d.b.x[f]]){s=!1;Ob=qp(d.b,f);Ob-=sp(d.b,f,Ob);for(ua=uq[d.b.x[f]],mb=0,Jb=ua.length;mb<Jb;++mb)if(T=ua[mb],Ob<=T){s=!0;T!=Ob+A&&Mq(d.b,f,Ob+A);break}s||Mq(d.b,f,Ob+A)}var N,Qb,Kb,Wc;for(N=0;N<d.b.c;++N)if(7==d.b.x[N]&&0==d.b.q[N]&&3<qp(d.b,N)&&0<d.b.k[N])for(Wc=0;Wc<d.b.f[N];++Wc)if(Qb=Ln(d.b,N,Wc),Kb=Kn(d.b,N,Wc),1<On(d.b,Kb)&&gr(d.b.x[Qb])){4==d.b.B[Kb]?In(d.b,Kb,2):In(d.b,Kb,1);Nq(d.b,N,d.b.q[N]+1);Nq(d.b,Qb,d.b.q[Qb]-1);break}var Rb,xb,la,nb,ya,Gc,cc,O,Ya,dc,Ec,Hc,eb,pc,yb,jb;Gn(d.b,\n1);d.a=C(Hn,Am,-1,d.b.d,2);for(la=0;la<d.b.d;++la)64==d.b.B[la]&&(In(d.b,la,1),d.a[la]=!0);jb=new Jn(d.b,3);O=C(Hn,Am,-1,jb.i.c,2);for(eb=0;eb<jb.i.c;++eb){pc=Rn(jb.i,eb);O[eb]=!0;for(cc=0;cc<pc.length;++cc)if(!Kq(d.b,pc[cc])){O[eb]=!1;break}if(O[eb]){yb=Rn(jb.j,eb);for(cc=0;cc<yb.length;++cc)d.a[yb[cc]]=!0}}for(la=0;la<d.b.d;++la)if(!d.a[la]&&0!=jb.b[la]&&Kq(d.b,D(d.b,0,la))&&Kq(d.b,D(d.b,1,la)))a:{var Lb=d,gb=la,sc=void 0,M=void 0,pb=void 0,gd=void 0,Ic=void 0,jc=void 0,Sb=void 0,qb=void 0,Cc=void 0,\nhd=void 0,Pc=void 0,ja=void 0,Qc=void 0,qb=C(B,v,-1,Lb.b.c,1),jc=C(B,v,-1,Lb.b.c,1),Sb=C(B,v,-1,Lb.b.c,1),Cc=C(B,v,-1,Lb.b.c,1),sc=D(Lb.b,0,gb),M=D(Lb.b,1,gb);jc[0]=sc;jc[1]=M;Sb[0]=-1;Sb[1]=gb;qb[sc]=1;qb[M]=2;Cc[sc]=-1;Cc[M]=sc;for(hd=Ic=1;Ic<=hd&&15>qb[jc[Ic]];){Qc=jc[Ic];for(Pc=0;Pc<Lb.b.f[Qc];++Pc)if(pb=Ln(Lb.b,Qc,Pc),pb!=Cc[Qc]){gd=Kn(Lb.b,Qc,Pc);if(pb==sc){Sb[0]=gd;for(ja=0;ja<=hd;++ja)Lb.a[Sb[Pc]]=!0;break a}Kq(Lb.b,pb)&&0==qb[pb]&&(++hd,jc[hd]=pb,Sb[hd]=gd,qb[pb]=qb[Qc]+1,Cc[pb]=Qc)}++Ic}}Gn(d.b,\n3);for(eb=0;eb<jb.i.c;++eb)if(O[eb]){pc=Rn(jb.i,eb);for(cc=0;cc<pc.length;++cc){var xe;var Va=d,Oa=pc[cc],$e=void 0;16==Va.b.x[Oa]&&0>=Va.b.q[Oa]||6==Va.b.x[Oa]&&0!=Va.b.q[Oa]||!Kq(Va.b,Oa)?xe=!1:($e=null==yp(Va.b,Oa)?0:(null==Va.b.r?null:Va.b.r[Oa])[0],xe=1>Iq(Va.b,Oa)-qp(Va.b,Oa)-$e||5!=Va.b.x[Oa]&&6!=Va.b.x[Oa]&&7!=Va.b.x[Oa]&&8!=Va.b.x[Oa]&&15!=Va.b.x[Oa]&&16!=Va.b.x[Oa]&&33!=Va.b.x[Oa]&&34!=Va.b.x[Oa]?!1:!0);if(!xe){Tq(d.b,pc[cc],!1);for(dc=0;dc<d.b.f[pc[cc]];++dc)d.a[Kn(d.b,pc[cc],dc)]=!1}}}X3(d);\nfor(eb=0;eb<jb.i.c;++eb)if(O[eb]&&6==Rn(jb.j,eb).length){yb=Rn(jb.j,eb);Ya=!0;for(nb=0,ya=yb.length;nb<ya;++nb)if(la=yb[nb],!d.a[la]){Ya=!1;break}Ya&&(W3(d,yb[0]),W3(d,yb[2]),W3(d,yb[4]),X3(d))}for(Hc=5;4<=Hc;--Hc){do{Ec=!1;for(la=0;la<d.b.d;++la)if(d.a[la]){for(cc=Rb=0;2>cc;++cc){Gc=D(d.b,cc,la);for(dc=0;dc<d.b.f[Gc];++dc)d.a[Kn(d.b,Gc,dc)]&&++Rb}if(Rb==Hc){W3(d,la);X3(d);Ec=!0;break}}}while(Ec)}for(la=0;la<d.b.d;++la)if(d.a[la])throw new Jo(R3);for(xb=0;xb<d.b.c;++xb)if(Kq(d.b,xb))throw new Jo(R3);\nd.b.r=null;d.b.J=!1;var rb,Bb,Lc,fc,ad,$d,Tb,Ad,xc,kc,yc;Gn(d.b,3);xc=!1;kc=C(B,v,-1,2,1);yc=C(B,v,-1,2,1);Ad=C(B,v,-1,2,1);for(Bb=0;Bb<d.b.d;++Bb)if(!uo(d.b,Bb)&&2==d.b.B[Bb]){for(fc=0;2>fc;++fc){kc[fc]=-1;Ad[fc]=-1;rb=D(d.b,fc,Bb);for(Tb=0;Tb<d.b.f[rb];++Tb)Lc=Kn(d.b,rb,Tb),Lc!=Bb&&(17==d.b.B[Lc]||9==d.b.B[Lc]?(kc[fc]=Ln(d.b,rb,Tb),yc[fc]=Lc):Ad[fc]=Ln(d.b,rb,Tb));if(-1==kc[fc])break}if(-1!=kc[0]&&-1!=kc[1]){$d=d.b.B[yc[0]]!=d.b.B[yc[1]];ad=!1;for(fc=0;2>fc;++fc)-1!=Ad[fc]&&Ad[fc]<kc[fc]&&(ad=!ad);\nar(d.b,Bb,$d^ad?2:1,!1);xc=!0}}for(Bb=0;Bb<d.b.d;++Bb)(17==d.b.B[Bb]||9==d.b.B[Bb])&&In(d.b,Bb,1);xc&&(d.b.K|=4);ts(new c4,d.b);if(Na){for(ob=f4((ab=new cT(Na),new g4(Na,ab)));wS(ob.a.a);)da=(ob.a.b=Rp(ob.a.a)).si(),Vq(d.b,da.a,$3(da,G),!1);d.b.K|=4}nr(d.b);b4(d.b);ea&&cr(d.b,!0);b=new vr(c);return cx(b.a.a)}function e4(a){return null!=String.fromCharCode(a).match(/[A-Z]/i)}function f4(a){a=new fT(a.b.a);return new h4(a)}function g4(a,b){this.a=a;this.b=b}w(632,620,{},g4);\n_.pi=function(a){a:{var b,c;for(c=new fT((new cT(this.a)).a);wS(c.a);)if(b=c.b=Rp(c.a),b=b.si(),null==a?null==b:Vv(a,b)){a=!0;break a}a=!1}return a};_.Re=function(){return f4(this)};_.kg=function(){return this.b.a.c};_.a=null;_.b=null;function h4(a){this.a=a}w(633,1,{},h4);_.qe=function(){return wS(this.a.a)};_.re=function(){return(this.a.b=Rp(this.a.a)).si()};_.se=function(){eT(this.a)};_.a=null;function i4(){KS();this.a=6122;this.b=12230397}w(649,1,{},i4);w(697,592,bn);\n_.Wd=function(){var a,b,c,d,e;a=b=d=null;if(this.b.a==(GN(),HN)&&this.b.i==(IN(),JN))try{var f=this.b.b,g,h,j;j=null;h=new Zr;Gr(new Wr,h,new uJ(new zJ(f)))&&(g=new vr(h),j=cx(g.a.a));b=j;if(null==b)throw new Jo("V3000 read failed.");a=Ck;this.a.Ec.a="V3000 conversion provided by OpenChemLib"}catch(l){if(l=wo(l),E(l,101))c=l,d=c.Ud();else throw l;}else if(this.b.a==XT)try{var m=this.b.b,q,r,s,A,u,x,F;b=-1!=m.indexOf(Od)?(q=$R(m,Od),r=3<=q.length&&0<q[2].length,s=2<=q.length&&0<q[1].length,A=d4(q[0]),\nu=r?d4(q[2]):d4(n),x=s?d4(q[1]):d4(n),F=n,F+=Cb,F+=wO(1,3)+wO(1,3),s&&(F+=wO(1,3)),F+=ga,F+=ub+A,F+=ub+u,s&&(F+=ub+x),F):d4(m);this.b.f==(DN(),MN)?a="readSMIRKS":this.b.f==UT&&(a="readSMILES");this.a.Ec.a="SMILES conversion provided by OpenChemLib"}catch(H){if(H=wo(H),E(H,101))c=H,d="SMILES parsing error:"+c.Ud();else throw H;}else if(d="Invalid or unsupported input",this.a.Vc&&!this.b.d)try{var I,t=new V3,ba=Lr(this.b.b),aa;if(null==ba||0==ba.length)aa=null;else{var P=bS(ba),da,ob,wb,Na,$a;if(null==\nP)aa=null;else{T3(t,P,0);da=$(t,4);Na=$(t,4);8<da&&(da=Na);ob=$(t,da);wb=$(t,Na);$a=new Nr(ob,wb);var U=null,pa,qa,ea,Fa,Ja,Ca,Ob,T,ua,mb,Jb,ab,Ua,Pb,Zb,fa,ra,ca,Hb,na,ic,G,N,Qb,Kb,Wc,Rb,xb,la,nb,ya,Gc,cc,O,Ya,dc,Ec,Hc,eb,pc,yb,jb,Lb,gb,sc,M,pb,gd,Ic,jc,Sb,qb,Cc,hd,Pc,ja,Qc,xe,Va,Oa,$e,rb,Bb,Lc,fc,ad,$d,Tb,Ad,xc,kc,yc;ad=8;t.f=$a;Cq(t.f);if(!(null==P||0==P.length))if(null!=U&&0==U.length&&(U=null),T3(t,P,0),ea=$(t,4),fa=$(t,4),8<ea&&(ad=ea,ea=fa),0==ea)cr(t.f,1==$(t,1));else{Fa=$(t,ea);Ja=$(t,fa);\nPc=$(t,ea);Va=$(t,ea);xe=$(t,ea);Kb=$(t,ea);for(T=0;T<Fa;++T)xq(t.f,6);for(M=0;M<Pc;++M)Aq(t.f,$(t,ea),7);for(M=0;M<Va;++M)Aq(t.f,$(t,ea),8);for(M=0;M<xe;++M)Aq(t.f,$(t,ea),$(t,8));for(M=0;M<Kb;++M)Nq(t.f,$(t,ea),$(t,4)-8);Wc=1+Ja-Fa;cc=$(t,4);Zb=0;Xq(t.f,0,0);Yq(t.f,0,0);Zq(t.f,0,0);O=null!=U&&39<=U[0];yc=xc=Tb=fc=0;nb=la=!1;O&&(U.length>2*Fa-2&&39==U[2*Fa-2]||U.length>3*Fa-3&&39==U[3*Fa-3]?(nb=!0,pb=(la=U.length==3*Fa-3+9)?3*Fa-3:2*Fa-2,Pb=86*(U[pb+1]-40)+U[pb+2]-40,fc=Math.pow(10,Pb/2E3-1),pb+=\n2,$d=86*(U[pb+1]-40)+U[pb+2]-40,Tb=Math.pow(10,$d/1500-1),pb+=2,Ad=86*(U[pb+1]-40)+U[pb+2]-40,xc=Math.pow(10,Ad/1500-1),la&&(pb+=2,kc=86*(U[pb+1]-40)+U[pb+2]-40,yc=Math.pow(10,kc/1500-1))):la=U.length==3*Fa-3);t.b&&la&&(U=null,O=!1);for(M=1;M<Fa;++M)Ya=$(t,cc),0==Ya?(O&&(Xq(t.f,M,t.f.D[0].a+8*(U[2*M-2]-83)),Yq(t.f,M,t.f.D[0].b+8*(U[2*M-1]-83)),la&&Zq(t.f,M,t.f.D[0].c+8*(U[2*Fa-3+M]-83))),++Wc):(Zb+=Ya-1,O&&(Xq(t.f,M,co(t.f,Zb)+U[2*M-2]-83),Yq(t.f,M,eo(t.f,Zb)+U[2*M-1]-83),la&&Zq(t.f,M,fo(t.f,Zb)+\n(U[2*Fa-3+M]-83))),Bq(t.f,Zb,M,1));for(M=0;M<Wc;++M)Bq(t.f,$(t,ea),$(t,ea),1);Ic=C(Hn,Am,-1,Ja,2);for(ca=0;ca<Ja;++ca)switch(ic=$(t,2),ic){case 0:S3(t.f,D(t.f,0,ca))||S3(t.f,D(t.f,1,ca))?In(t.f,ca,32):Ic[ca]=!0;break;case 2:In(t.f,ca,2);break;case 3:In(t.f,ca,4)}qa=$(t,ea);for(M=0;M<qa;++M)if(T=$(t,ea),8==ad)Oa=$(t,2),3==Oa?(Pq(t.f,T,1,0),Vq(t.f,T,1,!1)):Vq(t.f,T,Oa,!1);else switch(Oa=$(t,3),Oa){case 4:Vq(t.f,T,1,!1);Pq(t.f,T,1,$(t,3));break;case 5:Vq(t.f,T,2,!1);Pq(t.f,T,1,$(t,3));break;case 6:Vq(t.f,\nT,1,!1);Pq(t.f,T,2,$(t,3));break;case 7:Vq(t.f,T,2,!1);Pq(t.f,T,2,$(t,3));break;default:Vq(t.f,T,Oa,!1)}8==ad&&0==$(t,1)&&(t.f.F=!0);pa=$(t,fa);for(M=0;M<pa;++M)if(ca=$(t,fa),1==t.f.B[ca])switch(Oa=$(t,3),Oa){case 4:ar(t.f,ca,1,!1);$q(t.f,ca,1,$(t,3));break;case 5:ar(t.f,ca,2,!1);$q(t.f,ca,1,$(t,3));break;case 6:ar(t.f,ca,1,!1);$q(t.f,ca,2,$(t,3));break;case 7:ar(t.f,ca,2,!1);$q(t.f,ca,2,$(t,3));break;default:ar(t.f,ca,Oa,!1)}else ar(t.f,ca,$(t,2),!1);cr(t.f,1==$(t,1));Ob=null;for(Qc=0;1==$(t,1);)switch(Gc=\nQc+$(t,4),Gc){case 0:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Wq(t.f,T,2048);break;case 1:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Cc=$(t,8),Uq(t.f,T,Cc);break;case 2:ja=$(t,fa);for(M=0;M<ja;++M)ca=$(t,fa),In(t.f,ca,64);break;case 3:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Wq(t.f,T,4096);break;case 4:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Lc=$(t,4)<<3,Wq(t.f,T,Lc);break;case 5:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Ca=$(t,2)<<1,Wq(t.f,T,Ca);break;case 6:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Wq(t.f,T,1);break;\ncase 7:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),gb=$(t,4)<<7,Wq(t.f,T,gb);break;case 8:ja=$(t,ea);for(M=0;M<ja;++M){T=$(t,ea);Jb=$(t,4);ua=C(B,v,-1,Jb,1);for(jc=0;jc<Jb;++jc)mb=$(t,8),ua[jc]=mb;var ae=t.f,vd=T,zb=ua;null==ae.t&&(ae.t=C(ko,Jm,91,ae.G,0));null!=zb&&To(zb);ae.t[vd]=zb;ae.K=0;ae.E=!0}break;case 9:ja=$(t,fa);for(M=0;M<ja;++M)ca=$(t,fa),Lc=$(t,2)<<4,br(t.f,ca,Lc);break;case 10:ja=$(t,fa);for(M=0;M<ja;++M)ca=$(t,fa),G=$(t,4),br(t.f,ca,G);break;case 11:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),\nWq(t.f,T,8192);break;case 12:ja=$(t,fa);for(M=0;M<ja;++M)ca=$(t,fa),N=$(t,8)<<6,br(t.f,ca,N);break;case 13:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),$e=$(t,3)<<14,Wq(t.f,T,$e);break;case 14:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),hd=$(t,5)<<17,Wq(t.f,T,hd);break;case 15:Qc=16;break;case 16:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Bb=$(t,3)<<22,Wq(t.f,T,Bb);break;case 17:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Mq(t.f,T,$(t,4));break;case 18:ja=$(t,ea);qb=$(t,4);for(M=0;M<ja;++M){T=$(t,ea);ya=$(t,qb);Sb=C(jp,\nTm,-1,ya,1);for(jc=0;jc<ya;++jc)Sb[jc]=$(t,7)<<24>>24;var Rc=t.f,Bd=T,Aa=Dq(Sb,0,Sb.length),Xc=void 0;if(null!=Aa)if(0==Aa.length)Aa=null;else if(Xc=er(Aa),0!=Xc&&S(Aa,rq[Xc])||S(Aa,Pd))Aq(Rc,Bd,Xc),Aa=null;null==Aa?null!=Rc.r&&(Rc.r[Bd]=null):(null==Rc.r&&(Rc.r=C(vq,o,3,Rc.G,0)),Rc.r[Bd]=bS(Aa))}break;case 19:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Qb=$(t,3)<<25,Wq(t.f,T,Qb);break;case 20:ja=$(t,fa);for(M=0;M<ja;++M)ca=$(t,fa),Bb=$(t,3)<<14,br(t.f,ca,Bb);break;case 21:ja=$(t,ea);for(M=0;M<ja;++M)T=\n$(t,ea),Rq(t.f,T,$(t,2)<<4);break;case 22:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Wq(t.f,T,268435456);break;case 23:ja=$(t,fa);for(M=0;M<ja;++M)ca=$(t,fa),br(t.f,ca,131072);break;case 24:ja=$(t,fa);for(M=0;M<ja;++M)ca=$(t,fa),Ca=$(t,2)<<18,br(t.f,ca,Ca);break;case 25:for(M=0;M<Fa;++M)if(1==$(t,1)){var Yc=t.f;Yc.s[M]|=512}break;case 26:ja=$(t,fa);Ob=C(B,v,-1,ja,1);for(M=0;M<ja;++M)Ob[M]=$(t,fa);break;case 27:ja=$(t,ea);for(M=0;M<ja;++M)T=$(t,ea),Wq(t.f,T,536870912)}Fn(new Sn(t.f),Ic);if(null!=Ob)for(Hb=\n0,na=Ob.length;Hb<na;++Hb)ca=Ob[Hb],In(t.f,ca,2==t.f.B[ca]?4:2);Rb=0;if(null==U&&P.length>t.d+1&&(32==P[t.d+1]||9==P[t.d+1]))U=P,Rb=t.d+2;if(null!=U)try{if(33==U[Rb]||35==U[Rb]){T3(t,U,Rb+1);la=1==$(t,1);nb=1==$(t,1);rb=2*$(t,4);ra=1<<rb;ca=0;for(T=1;T<Fa;++T)ca<Ja&&D(t.f,1,ca)==T?(jb=D(t.f,0,ca++),yb=1):(jb=0,yb=8),Xq(t.f,T,co(t.f,jb)+yb*($(t,rb)-~~(ra/2))),Yq(t.f,T,eo(t.f,jb)+yb*($(t,rb)-~~(ra/2))),la&&Zq(t.f,T,fo(t.f,jb)+yb*($(t,rb)-~~(ra/2)));Ua=la?1.5:(Fo(),24);ab=Eq(t.f,Fa,Ja,Ua);if(35==U[Rb]){sc=\n0;Lb=C(B,v,-1,Fa,1);for(T=0;T<Fa;++T)sc+=Lb[T]=So(t.f,T);for(T=0;T<Fa;++T)for(M=0;M<Lb[T];++M)gb=xq(t.f,1),Bq(t.f,T,gb,1),Xq(t.f,gb,co(t.f,T)+($(t,rb)-~~(ra/2))),Yq(t.f,gb,eo(t.f,T)+($(t,rb)-~~(ra/2))),la&&Zq(t.f,gb,fo(t.f,T)+($(t,rb)-~~(ra/2)));Fa+=sc}if(nb){var ye=$(t,rb),Ia=Math.log(2E3)*Math.LOG10E*ye/(ra-1)-1;fc=Math.pow(10,Ia);Tb=fc*U3($(t,rb),ra);xc=fc*U3($(t,rb),ra);la&&(yc=fc*U3($(t,rb),ra));yb=fc/ab;for(T=0;T<Fa;++T)Xq(t.f,T,Tb+yb*co(t.f,T)),Yq(t.f,T,xc+yb*eo(t.f,T)),la&&Zq(t.f,T,yc+yb*\nfo(t.f,T))}else{yb=1.5/ab;for(T=0;T<Fa;++T)Xq(t.f,T,yb*co(t.f,T)),Yq(t.f,T,yb*eo(t.f,T)),la&&Zq(t.f,T,yb*fo(t.f,T))}}else if(la&&!nb&&0==fc&&(fc=1.5),0!=fc&&0!=t.f.p){for(ca=ab=0;ca<t.f.p;++ca)dc=co(t.f,D(t.f,0,ca))-co(t.f,D(t.f,1,ca)),Ec=eo(t.f,D(t.f,0,ca))-eo(t.f,D(t.f,1,ca)),Hc=la?fo(t.f,D(t.f,0,ca))-fo(t.f,D(t.f,1,ca)):0,ab+=Math.sqrt(dc*dc+Ec*Ec+Hc*Hc);ab/=t.f.p;pc=fc/ab;for(T=0;T<t.f.o;++T)Xq(t.f,T,co(t.f,T)*pc+Tb),Yq(t.f,T,eo(t.f,T)*pc+xc),la&&Zq(t.f,T,fo(t.f,T)*pc+yc)}}catch(lc){if(lc=wo(lc),\nE(lc,101))eb=lc,eb.Ud(),U=null,la=!1;else throw lc;}if((xb=null!=U&&!la)||t.b){Gn(t.f,3);for(ca=0;ca<t.f.d;++ca)if(2==On(t.f,ca)&&!uo(t.f,ca)&&0==(t.f.z[ca]&3)){var gc=t.f;gc.z[ca]|=16777216}}!xb&&t.b&&(t.f.K|=4,gd=new c4,gd.i=new i4,ts(gd,t.f),xb=!0);xb?(nr(t.f),b4(t.f)):la||(t.f.K|=4)}aa=$a}}I=new vr(aa);b=cx(I.a.a);a="readOCLCode";d=null}catch(Le){if(Le=wo(Le),!E(Le,101))throw Le;}e=!1;if(null!=b&&null==d)try{if((e=KN(this.a,b,!1))&&this.c){var Ab=this.a;if(Ab.v){var Cd=Ab.v;Cd.a=a;UL(Cd,Ab.Tb,\n0,0,0)}Ab.Dc=!0}}catch(be){if(be=wo(be),E(be,101))d="Invalid converted molfile";else throw be;}this.a.ac=e;this.e?e?SN(this.e):TN(this.e,new Jo(d)):null!=d&&l0(this.a,d);this.d&&aH(this.a)};Z(632);Z(633);Z(24);Z(29);Z(30);V(MX)(1);\n//@ sourceURL=1.js\n')
