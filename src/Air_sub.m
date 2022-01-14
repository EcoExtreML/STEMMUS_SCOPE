function Air_sub
global Cah CaT Caa Kah KaT Kaa Vah VaT Vaa Cag Xah XaT Xaa RHODA Hc
global POR D_V D_Ta D_Vg KL_T Gamma_w V_A RHOL
global QL Theta_LL hh TT DeltZ DTheta_LLT QL_h QL_T
global NL DTheta_LLh P_gg Beta_g  
global KLhBAR KLTBAR DhDZ DTDZ DPgDZ DTDBAR KLa_Switch
global C1 C2 C3 C4 C5 C6 C7 C4_a C5_a C6_a NN
global Delt_t RHS T h P_g SAVE Thmrlefc
global BtmPg TopPg KT 
global NBCPB BCPB NBCP BCP QL_a DRHOVZ hh_frez RHOV KfL_h


[Cah,CaT,Caa,Kah,KaT,Kaa,Vah,VaT,Vaa,Cag,QL,QL_h,QL_T,QL_a,KLhBAR,KLTBAR,DhDZ,DTDZ,DPgDZ,DTDBAR,DRHOVZ]=AirPARM(NL,hh,hh_frez,TT,Theta_LL,DeltZ,DTheta_LLh,DTheta_LLT,POR,RHOL,RHOV,V_A,KfL_h,D_Ta,KL_T,D_V,D_Vg,P_gg,Beta_g,Gamma_w,KLa_Switch,Xah,XaT,Xaa,RHODA,Hc,KLhBAR,KLTBAR,DhDZ,DTDZ,DPgDZ,DTDBAR,DRHOVZ);

[C1,C2,C3,C4,C4_a,C5,C5_a,C6,C6_a,C7]=Air_MAT(Cah,CaT,Caa,Kah,KaT,Kaa,Vah,VaT,Vaa,Cag,DeltZ,NL,NN);

[RHS,C6,SAVE]=Air_EQ(C1,C2,C3,C4,C4_a,C5,C5_a,C6,C7,NL,NN,Delt_t,T,TT,h,hh,P_g,Thmrlefc);

[RHS,C6,C6_a]=Air_BC(RHS,KT,NN,BtmPg,TopPg,NBCPB,BCPB,NBCP,BCP,C6,C6_a);

[C6,P_gg,RHS]=Air_Solve(C6,NN,NL,C6_a,RHS);