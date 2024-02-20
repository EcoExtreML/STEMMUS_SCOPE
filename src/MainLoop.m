run Constants_StartInit1
% if IP0STm<=5 %
% BCh=-0.3/86400;    
%     
% end
% if IP0STm>=6 %
%     
% %     run Constants_StartInit2
% end
global i tS KT Delt_t TEND TIME MN NN NL ML ND hOLD TOLD h hh T TT P_gOLD P_g P_gg Delt_t0
global KIT NIT TimeStep Processing KTNUM
global SUMTIME hhh TTT P_ggg Theta_LLL DSTOR Thmrlefc CHK Theta_LL Theta_L XWILT
global NBCh AVAIL Evap DSTOR0 EXCESS QMT RS BCh hN hSAVE NBChh DSTMAX Soilairefc
global TSAVE IRPT1 IRPT2 AVAIL0 TIMEOLD TIMELAST Ts_Min Ts_Max
global DDEhBAR DEhBAR DDRHOVhDz DRHOVhDz EEtaBAR EtaBAR DD_Vg D_Vg DDRHOVTDz DRHOVTDz KKLhBAR KLhBAR KKLTBAR KLTBAR DDTDBAR DTDBAR QVV QLL CChh SAVEDTheta_LLT SAVEDTheta_LLh SAVEDTheta_UUh DSAVEDTheta_LLT DSAVEDTheta_LLh DSAVEDTheta_UUh
global CChT QVT QVH QVTT QVHH SSa Sa HRA HR QVAA QVa QLH QLT QLHH QLTT DVH DVHH DVT DVTT SSe Se QAA QAa QL_TT QL_HH QLAA QL_a DPgDZ DDPgDZ k_g kk_g VV_A V_A Theta_r Theta_s m n Alpha SAVETheta_UU  Gama_hh Theta_a Gama_h hm hd
global SAVEKfL_h KCHK FCHK TKCHK hCHK TSAVEhh SAVEhh_frez Precip SAVETT INDICATOR rwuef TSim_Theta TSim_Theta_I TSim_Theta_U TSim_Temp Gvc Tp_t DeltZ TTdps Rnnet HG QEG QvG Lphot GHT
global Precip_msr WS_msr Ta_msr RH_msr Pg_msr SAD1_msr RH_msr_sat SAD2_msr Rn_msr Rns_msr SAB1_msr SAB2_msr Rlatm Tdew_msr PARB_msr PARD_msr Tat COR U HR_a Rns TopPg Ta_EVAP LAI_EVAP Rnld LAI_EVAP_ALL
global TVXY TGXY TAHXY EAHXY FWETXY ALBOLDXY CANLIQXY CANICEXY SNOWHXY SNEQVOXY SNEQVXY ISNOWXY CHXY CMXY QSNOWXY
global TTS TTV TTG TSSOIL TFGEV TFCTR TSAV TSAG TFSA TFIRA TFSH TFCEV LAI1 TFSHA SAVETHETAII mL SAVETHETA
global TTTS TTTV TTTG TTSSOIL TTFGEV TTFCTR TTSAV TTSAG TTFSA TTFIRA TTFSH TTFCEV Vavail_mul%LAI1 TFSHA SAVETHETAII mL SAVETHETA
global QMTT Shh Sh STheta_LL STheta_L TSEC1 TSEC0 TQL IBOT TEND1 hBOT IBOTM%KTN TTEND TTIME% if TTIME==7200
global TimeStp SGWTIME XElemnt QQS DDW dMODQ RRrN STETEND ITCTRL1 ITCTRL0 itlevel1 itlevel2
global STMHPLR0 STMHPLR1N STMZTB0 STMZTB1 STMRrN STMRrO STMSY STMSS Q3DF ADAPTF RrNGG RrOGG
global TP_gg TP_gOLD TTTt TTOLD ThOLD THH h0 hh0 IBOTSTM KPILRSTM IPSTM BOT_NODES KPILLAR BOTm SYSTG SSSTG
global STMHPLR02 STMHPLR1N2 STMZTB02 STMZTB12 STMRrN2 STMRrO2 STMSY2 STMSS2 RrNGG2 RrOGG2 IPSTM2
global TP_gg2 TP_gOLD2 TTTt2 TTOLD2 ThOLD2 THH2 h02 hh02 IBOTSTM2 TSim_Theta2 TSim_Temp2 STETEND2 IP0STm1 iBOTNODEs HPUNIT
HPUNIT=100;

if IP0STm==1 || IP0STm==2%
BCh=-0.3/86400;      
end
if IP0STm==9 || IP0STm==8%
BCh=-0.5/86400;      
end
if IP0STm>=3 && IP0STm<=7%
BCh=-0/86400;          
end

if IP0STm<=9 %&& itlevel1==0      
    %% set constants for GW
    NLAY=2;
    NPILR=9;
    ITERQ3D=1;
    % IP=1;
    IGRID=1;
    Q3DF=1;
    RELAXF=0.8;
    % KPILLAR=ones(NN);
    ADAPTF=1;
    %%
%     if ~exist('KTNUM','var')
        if KT+1==0
            KT=0;
        else
            KT=KT;
        end
%     else
%         if length(KTNUM)>=IP0STm
%             if KTNUM(IP0STm)>0
%                 KT=KTNUM(IP0STm);
%             else
%                 if KT+1==0
%                     KT=0;
%                 else
%                     KT=KT;
%                 end
%             end
%         else
%             if KT+1==0
%                 KT=0;
%             else
%                 KT=KT;
%             end
%         end
%         
%     end
    
    %% IP parameter
    if IP0STm==1
        if (~exist('iBOTNODEs','var') || isempty(iBOTNODEs))
            BOTm=zeros(NLAY+1,NPILR);
            SYSTG=zeros(NLAY,NPILR);
            SSSTG=zeros(NLAY,NPILR);
        end
        file_path = 'BOT_NODES.txt';
        FID = fopen(file_path);
        s = dir(file_path);
        
        if FID>=0
            if (~exist('iBOTNODEs','var') || isempty(iBOTNODEs)) && s.bytes ~= 0 %KT==0
                iBOTNODEs=1;
                %% Check whether running on PC or MAC/UNIX machine
                %     if ispc, slash_dir = '\'; else slash_dir = '/'; end
                
                %% Store working directory and subdirectory containing the files needed to run this example
                %     EXAMPLE_dir = [pwd ,slash_dir,'grid1/HYDRUS1/']; %CONV_dir = [pwd ,slash_dir,'diagnostics'];
                EXAMPLE_dir = pwd ; %CONV_dir = [pwd ,slash_dir,'diagnostics'];
                addpath(EXAMPLE_dir);
                load BOT_NODES.txt;
                NNK=0;
                %     KPILLAR=BOT_NODES(1:NNK);%[1	1	1	1	1	2	2	2	2	2	3	3	3	3	3	4	4	4	4	4	5	5	5	5	5	6	6	6	6	6	7	7	7	7	7	8	8	8	8	8	9	9	9	9	9	10	10	10	10	10	11	11	11	11	11	12	12	12	12	12	13	13	13	13	13	14	14	14	14	14	15	15	15	15	15	16	16	16	16	16	17	17	17	17	17	18	18	18	18	18	19	19	19	19	19	20	20	20	20	20	21	21	21	21	21	22	22	22	22	22	23	23	23	23	23	24	24	24	24	24	25	25	25	25	25	26	26	26	26	26	27	27	27	27	27	28	28	28	28	28	29	29	29	29	29	30	30	30	30	30	31	31	31	31	31	32	32	32	32	32	33	33	33	33	33	34	34	34	34	34	35	35	35	35	35	36	36	36	36	36	37	37	37	37	37	38	38	38	38	38	39	39	39	39	39	40	40	40	40	40	41	41	41	41	41	42	42	42	42	42	43	43	43	43	43	44	44	44	44	44	45	45	45	45	45	46	46	46	46	46	47	47	47	47	47	48	48	48	48	48	49	49	49	49	49	50	50	50	50	50	51	51	51	51	51	52	52	52	52	52	53	53	53	53	53	54	54	54	54	54	55	55	55	55	55	56	56	56	56	56	57	57	57	57	57	58	58	58	58	58	59	59	59	59	59	60	60	60	60	60	61	61	61	61	61	62	62	62	62	62	63	63	63	63	63	64	64	64	64	64	65	65	65	65	65	66	66	66	66	66	67	67	67	67	67	68	68	68	68	68	69	69	69	69	69	70	70	70	70	70	71	71	71	71	71	72	72	72	72	72	73	73	73	73	73	74	74	74	74	74	75	75	75	75	75	76	76	76	76	76	77	77	77	77	77	78	78	78	78	78	79	79	79	79	79	80	80	80	80	80	81	81	81	81	81	81	81	81	81	81	81	81	81	82	82	82	82	82	82	82	82	82	82	82	82	83	83	83	83	83	83	83	83	83	83	83	83	83	84	84	84	84	84	84	84	84	84	84	84	84	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91]';
                if NPILR==1
                    BOTm(1:NLAY+1,1)=BOT_NODES(NNK+1:NNK+1+(NLAY+1)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
                    SYSTG(1:NLAY,1)=BOT_NODES(NNK+1+(NLAY+1):NNK+1+(NLAY+1)+(NLAY)-1);
                    SSSTG(1:NLAY,1)=BOT_NODES(NNK+1+(NLAY+1)+(NLAY):NNK+1+(NLAY+1)+(NLAY)+(NLAY)-1);
                    
                else
                    BOTm(1:NLAY+1,1)=BOT_NODES(NNK+1:NNK+1+(NLAY+1)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
                    SYSTG(1:NLAY,1)=BOT_NODES(NNK+1+NPILR*(NLAY+1):NNK+1+NPILR*(NLAY+1)+(NLAY)-1);
                    SSSTG(1:NLAY,1)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY):NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(NLAY)-1);
                    for i=2:NPILR
                        BOTm(1:NLAY+1,i)=BOT_NODES(NNK+1+(i-1)*(NLAY+1):NNK+1+i*(NLAY+1)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
                        SYSTG(1:NLAY,i)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+(i-1)*(NLAY):NNK+1+NPILR*(NLAY+1)+(i)*(NLAY)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
                        SSSTG(1:NLAY,i)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(i-1)*(NLAY):NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(i)*(NLAY)-1);
                    end
                end
                
            end
        end
        fclose(FID);
        % if sum(BOTm(:,NPILR))==0 || sum(SYSTG(:,NPILR))==0
        %     KPILLAR=[1	1	1	1	1	2	2	2	2	2	3	3	3	3	3	4	4	4	4	4	5	5	5	5	5	6	6	6	6	6	7	7	7	7	7	8	8	8	8	8	9	9	9	9	9	10	10	10	10	10	11	11	11	11	11	12	12	12	12	12	13	13	13	13	13	14	14	14	14	14	15	15	15	15	15	16	16	16	16	16	17	17	17	17	17	18	18	18	18	18	19	19	19	19	19	20	20	20	20	20	21	21	21	21	21	22	22	22	22	22	23	23	23	23	23	24	24	24	24	24	25	25	25	25	25	26	26	26	26	26	27	27	27	27	27	28	28	28	28	28	29	29	29	29	29	30	30	30	30	30	31	31	31	31	31	32	32	32	32	32	33	33	33	33	33	34	34	34	34	34	35	35	35	35	35	36	36	36	36	36	37	37	37	37	37	38	38	38	38	38	39	39	39	39	39	40	40	40	40	40	41	41	41	41	41	42	42	42	42	42	43	43	43	43	43	44	44	44	44	44	45	45	45	45	45	46	46	46	46	46	47	47	47	47	47	48	48	48	48	48	49	49	49	49	49	50	50	50	50	50	51	51	51	51	51	52	52	52	52	52	53	53	53	53	53	54	54	54	54	54	55	55	55	55	55	56	56	56	56	56	57	57	57	57	57	58	58	58	58	58	59	59	59	59	59	60	60	60	60	60	61	61	61	61	61	62	62	62	62	62	63	63	63	63	63	64	64	64	64	64	65	65	65	65	65	66	66	66	66	66	67	67	67	67	67	68	68	68	68	68	69	69	69	69	69	70	70	70	70	70	71	71	71	71	71	72	72	72	72	72	73	73	73	73	73	74	74	74	74	74	75	75	75	75	75	76	76	76	76	76	77	77	77	77	77	78	78	78	78	78	79	79	79	79	79	80	80	80	80	80	81	81	81	81	81	81	81	81	81	81	81	81	81	82	82	82	82	82	82	82	82	82	82	82	82	83	83	83	83	83	83	83	83	83	83	83	83	83	84	84	84	84	84	84	84	84	84	84	84	84	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91]';
        % for in=1:NPILR
        %     BOTm(1:NLAY+1,in)=[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
        % end
        % end
    end
    
    [KPILLAR]=KPILR_Cal(BOTm.*HPUNIT,XElemnt,IP0STm);
    % SYSTG=0.37;
    % SSSTG=0;
    % DELTT=0;
%     RrOGG=0;
%     RrNGG=0;
    % if KTN==1 && TIME==0
    %     HPILR1N=200;
    %     HPILR0=200;
    % end
    % XElemnt=zeros(NN,1);
    % XElemnt(1)=0;
    % TDeltZ=flip(DeltZ);
    % % BOTm=XElemnt(NN);
    % for ML=2:NL
    %     XElemnt(ML)=XElemnt(ML-1)+TDeltZ(ML-1);
    % end
    % XElemnt(NN)=1000;
    % % IBOT=IBOTT;
    
    Shh=zeros(NN,1);STheta_LL=zeros(NN,1);STheta_L=zeros(NN,1);
    Sh=zeros(NN,1);
    Ts_Min=0;Ts_Max=80;%TIME=3600;
    
    %
    % run StartInit;   % Initialize Temperature, Matric potential and soil air pressure.
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TIMEOLD=0;Delt_t=1;
    TIMELAST=0;TIME=TTIME*3600*24;TEND1=(TTIME+TTEND)*3600*24;%TSEC0;
    SGWTIME(KTN,1)=TIME;
    % % for i=1:tS+1                          % Notice here: In this code, the 'i' is strictly used for timestep loop and the arraies index of meteorological forcing data.
    %     KT=1                          % Counting Number of timesteps
    % %     if KT>1 && Delt_t>(TEND-TIME)
    % %         Delt_t=TEND-TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
    % %     end
    % %     TIME=TIME+Delt_t;               % The time elapsed since start of simulation
    %     TimeStep(KT,1)=Delt_t;
    %     SUMTIME(KT,1)=TIME;
    % %     Processing=TIME/TEND
    % if IP0STm<=5
    if KTN==1
        h=h0;
        hh=hh0;
    else
%         h(1:NN)=ThOLD(1:NN,IP0STm);
%         hh(1:NN)=THH(1:NN,IP0STm);
        h(1:NN)=ThOLD(1:NN,KTN-1,IP0STm);
        hh(1:NN)=THH(1:NN,KTN-1,IP0STm);
    end
    % else
    %     if KTN==1
    %         h=h02;
    %         hh=hh02;
    %     else
    %         h(1:NN)=ThOLD2(1:NN,KTN-1,IP0STm);
    %         hh(1:NN)=THH2(1:NN,KTN-1,IP0STm);
    %     end
    % end
    
    run SOIL2;
    
    STheta_L(2:1:NN)=Theta_LL(NN-1:-1:1,1);
    STheta_L(1)=Theta_LL(NL,2);
    Sh(1:1:NN)=hh(NN:-1:1);

    THETA0=STheta_L;
    QS=zeros(NN,1);
    Theta_L=Theta_LL;
    [ZTB0G,ICTRL0]=FINDTABLE(IP0STm,Sh,XElemnt,NN);%[ICTRL0]=FINDTABLE(ZTB0G,IP,Sh);
    %         return
    %     end
        save('2021030291.mat');

    for i=1:1:15000                        % Notice here: In this code, the 'i' is strictly used for timestep loop and the arraies index of meteorological forcing data.
        KT=KT+1;                          % Counting Number of timesteps
        if KT>1 && Delt_t>(TEND1-TIME)
            Delt_t=TEND1-TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
        end
        %     KTN=KT;
        
        TIME=TIME+Delt_t;               % The time elapsed since start of simulation
        TimeStep(KTN,1)=Delt_t;
        TimeStp(KT,1)=Delt_t;
        SUMTIME(KT,1)=TIME;
        Processing=TIME/TEND1;
        %%%%%% Updating the state variables. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% find the bottom layer of soil column %%%%%%%%%%%%%%%%%%%%%
        [HPILLAR,IBOT]=TIME_INTERPOLATION(TEND1,TTIME*86400,IP0STm,BOTm.*HPUNIT,HPILR1N*HPUNIT,HPILR0*HPUNIT,TIME,TTEND*86400,XElemnt,NN,Q3DF,ADAPTF);
        hBOT(KT)=HPILLAR;
        IBOTM(KT)=IBOT;
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        if IRPT1==0 && IRPT2==0
            for MN=1:NN
                hOLD(MN)=h(MN);
                h(MN)=hh(MN);
                hhh(MN,KT)=hh(MN);
                if Thmrlefc==1
                    TOLD(MN)=T(MN);
                    T(MN)=TT(MN);
                    TTT(MN,KT)=TT(MN);
                end
                if Soilairefc==1
                    P_gOLD(MN)=P_g(MN);
                    P_g(MN)=P_gg(MN);
                    P_ggg(MN,KT)=P_gg(MN);
                end
            end
            DSTOR0=DSTOR;
            if KT>1
                run SOIL1
            end
        end
        
        if Delt_t~=Delt_t0
            for MN=1:NN
                hh(MN)=h(MN)+(h(MN)-hOLD(MN))*Delt_t/Delt_t0;
                TT(MN)=T(MN)+(T(MN)-TOLD(MN))*Delt_t/Delt_t0;
            end
        end
        hSAVE=hh(NN);
        TSAVE=TT(NN);
        if NBCh==1
            hN=BCh;
            hh(NN)=hN;
            hSAVE=hN;
        elseif NBCh==2
            if NBChh~=2
                if BCh<0
                    hN=DSTOR0;
                    hh(NN)=hN;
                    hSAVE=hN;
                else
                    hN=-1e6;
                    hh(NN)=hN;
                    hSAVE=hN;
                end
            end
        else
            if NBChh~=2
                hN=DSTOR0;
                hh(NN)=hN;
                hSAVE=hN;
            end
        end
        run Forcing_PARM
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for KIT=1:NIT   % Start the iteration procedure in a time step.
            
            run SOIL2;
            run CondL_T;
            run Density_V;
            run CondL_Tdisp;
            %         run Latent;
            %         run Density_DA;
            %         run CondT_coeff;
            %         run Condg_k_g;
            %         run CondV_DE;
            %         run CondV_DVg;
            %
            %         run h_sub;
            run Diff_Moisture_Heat;
            if NBCh==1
                DSTOR=0;
                RS=0;
            elseif NBCh==2
                AVAIL=-BCh;
                EXCESS=(AVAIL+QMT(KT))*Delt_t;
                if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
                DSTOR=min(EXCESS,DSTMAX);
                RS=(EXCESS-DSTOR)/Delt_t;
            else
                AVAIL=AVAIL0-Evap(KT);
                EXCESS=(AVAIL+QMT(KT))*Delt_t;
                if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
                DSTOR=0;
                RS=0;
            end
            
            %         if Soilairefc==1
            %             run Air_sub;
            %         end
            %
            %         if Thmrlefc==1
            %             run Enrgy_sub;
            %         end
            
            if max(CHK)<0.001
                break
            end
            hSAVE=hh(NN);
            TSAVE=TT(NN);
        end
        TIMEOLD=KT;
        KIT;
        KIT=0;
        run SOIL2;
        run TimestepCHK
        %     save('20210309.mat')
        %         save('202103019.mat')
        
        if IRPT1==0 && IRPT2==0
            QS(:)=QS(:)+TQL(:)*Delt_t/86400;
            if KT        % In case last time step is not convergent and needs to be repeated.
                MN=0;
                for ML=1:NL
                    for ND=1:2
                        MN=ML+ND-1;
                        Theta_LLL(ML,ND,KT)=Theta_LL(ML,ND);
                        Theta_L(ML,ND)=Theta_LL(ML,ND);
                        %                 Theta_UUU(ML,ND,KT)=Theta_UU(ML,ND);
                        %                 Theta_U(ML,ND)=Theta_UU(ML,ND);
                        %                 Theta_III(ML,ND,KT)=Theta_II(ML,ND);
                        %                 Theta_I(ML,ND)=Theta_II(ML,ND);
                        %                 DDTheta_LLh(ML,KT)=DTheta_LLh(ML,2);
                        %                 DDTheta_LLT(ML,KT)=DTheta_LLT(ML,2);
                        %                 DDTheta_UUh(ML,KT)=DTheta_UUh(ML,2);
                    end
                end
                %         run ObservationPoints
            end
            
            %     [RrNG,RrOG,SC2]=HYDRUS1RECHARGE(TEND1,TTIME*86400,ITERQ3D,IP,IGRID,Q3DF,THETA0,ICTRL0,STheta_LL,TIME,TQL,Delt_t,TTEND*86400,ZTB0G,ZTB1G,Shh,KPILLAR,BOTm,RrNG,SYSTG,0,XElemnt);
            if (TEND1-TIME)<1E-3
                Shh(1:1:NN)=hh(NN:-1:1);
                STheta_LL(2:1:NN)=Theta_LL(NL:-1:1,1);
                STheta_L(2:1:NN)=Theta_L(NL:-1:1,1);
                STheta_LL(1)=Theta_LL(NL,2);STheta_L(1)=Theta_L(NL,2);
                %     if KTN==1
                %     [RrNGG,RrOGG,ZTB1G]=HYDRUS1RECHARGE(TEND1/86400,TTIME,ITERQ3D,IP,IGRID,Q3DF,THETA0,ICTRL0,STheta_LL,TIME/86400,...
                %         QS,Delt_t/86400,TTEND,ZTB0G,Shh,KPILLAR,XElemnt(NN),0,0.3,0,XElemnt,KTN);
                %     else
%                 RrNSTM=0;RrOGSTM=0;
                [RrNSTM,RrOGSTM,ZTB1G]=HYDRUS1RECHARGE(TEND1/86400,TTIME,ITERQ3D,IP0STm,IGRID,Q3DF,THETA0,ICTRL0,STheta_LL,TIME/86400,...
                    QS,Delt_t/86400,TTEND,ZTB0G,Shh,KPILLAR,BOTm.*HPUNIT,RrNG,SYSTG,SSSTG,XElemnt,KTN);
            
                if isnan(RrNSTM) || isinf(RrNSTM)
                    RrNSTM=0;
                end
                if isnan(RrOGSTM) || isinf(RrOGSTM)
                    RrOGSTM=0;
                end
                
                %     end
                %         for MN=1:NN
                %             hOLD(MN)=h(MN);
                %             h(MN)=hh(MN);
                %             hhh(MN,KT)=hh(MN);
                %             HRA(MN,KT)=HR(MN);
                %             if Thmrlefc==1
                %                 TOLD(MN)=T(MN);
                %                 T(MN)=TT(MN);
                %                 TTT(MN,KT)=TT(MN);
                %             end
                %             if Soilairefc==1
                %                 P_gOLD(MN)=P_g(MN);
                %                 P_g(MN)=P_gg(MN);
                %                 P_ggg(MN,KT)=P_gg(MN);
                %             end
                %         end
%                 KTNUM(IP0STm)=KT;
                % if KTN==1
                %     if (exist('h0','var')) %&& ~exist('h02','var')
                %         if ~isempty(h0)
                %
                %             NNK1=length(h0)-1;NLK1=NNK1-1;
                %             for IPm=1:NPILR
                %
                %                 THH(1:NNK1+1,KTN,IPm)=h0(1:NNK1+1).*0;
                %                 ThOLD(1:NNK1+1,KTN,IPm)=h0(1:NNK1+1).*0;
                %                 %         TTOLD(1:NN,KTN,IPm)=TOLD(1:NN).*0;
                %                 %         TTTt(1:NN,KTN,IPm)=TT(1:NN).*0;
                %                 %         TP_gOLD(1:NN,KTN,IPm)=P_gOLD(1:NN).*0;
                %                 %         TP_gg(1:NN,KTN,IPm)=P_gg(1:NN).*0;
                %                 %
                %                 %         TSim_Theta(1:NL,KTN,IPm)=Theta_LL(NL:-1:1,1).*0;
                %                 %         TSim_Temp(1:NL,KTN,IPm)=TT(NL:-1:1).*0;
                %                 %         STMHPLR0(KTN,IPm)=HPILR0.*0;
                %                 %         STMHPLR1N(KTN,IPm)=HPILR1N.*0;
                %                 %         STMZTB0(KTN)=ZTB0G.*0;
                %                 %         STMZTB1(KTN)=ZTB1G.*0;
                %                 %         STMRrN(KTN,IPm)=RrNGG.*0;
                %                 %         STMRrO(KTN,IPm)=RrOGG.*0;
                %                 %         IBOTSTM(KTN,IPm)=IBOT.*0;
                %                 %         IPSTM(KTN,IPm)=IP0STm.*0;
                %                 %
                %                 % %         STETEND(KT,IPm)=TEND1.*0;
                %             end
                %         end
                %     end
                %     %  %%
                %     if exist('h02','var')
                %         if ~isempty(h02)
                %             NNK=length(h02)-1;NLK=NNK-1;
                %             for IPm=1:NPILR
                %                 THH2(1:NNK+1,KTN,IPm)=h02(1:NNK+1).*0;
                %                 ThOLD2(1:NNK+1,KTN,IPm)=h02(1:NNK+1).*0;
                %                 %          TTOLD2(1:NN,KTN,IPm)=h02(1:NN).*0;
                %                 %          TTTt2(1:NN,KTN,IPm)=h02(1:NN).*0;
                %                 %          TP_gOLD2(1:NN,KTN,IPm)=h02(1:NN).*0;
                %                 %          TP_gg2(1:NN,KTN,IPm)=h02(1:NN).*0;
                %                 %
                %                 %          TSim_Theta2(1:NL,KTN,IPm)=h02(NL:-1:1,1).*0;
                %                 %          TSim_Temp2(1:NL,KTN,IPm)=h02(NL:-1:1).*0;
                %                 %          STMHPLR02(KTN,IPm)=HPILR0.*0;
                %                 %          STMHPLR1N2(KTN,IPm)=HPILR1N.*0;
                %                 %          STMZTB02(KTN)=ZTB0G.*0;
                %                 %          STMZTB12(KTN)=ZTB1G.*0;
                %                 %          STMRrN2(KTN,IPm)=RrNGG.*0;
                %                 %          STMRrO2(KTN,IPm)=RrOGG.*0;
                %                 %          IBOTSTM2(KTN,IPm)=IBOT.*0;
                %                 %          IPSTM2(KTN,IPm)=IP0STm.*0;
                %                 %
                %                 % %          STETEND2(KT,IPm)=TEND1.*0;
                %             end
                %         end
                %     end
                % end
                % if IP0STm<=5
                
%                 THH(1:NN+1,IP0STm)=hh(1:NN+1);
%                 ThOLD(1:NN+1,IP0STm)=hOLD(1:NN+1);                
                THH(1:NN+1,KTN,IP0STm)=hh(1:NN+1);
                ThOLD(1:NN+1,KTN,IP0STm)=hOLD(1:NN+1);
                        RrNGG(IP0STm)=RrNSTM;
                        RrOGG(IP0STm)=RrOGSTM;                
                %         TTOLD(1:NN,KTN,IP0STm)=TOLD(1:NN);
                %         TTTt(1:NN,KTN,IP0STm)=TT(1:NN);
                %         TP_gOLD(1:NN,KTN,IP0STm)=P_gOLD(1:NN);
                %         TP_gg(1:NN,KTN,IP0STm)=P_gg(1:NN);
                %
                %         TSim_Theta(1:NL,KTN,IP0STm)=Theta_LL(NL:-1:1,1);
                % %         TSim_Theta_I(1:NL,TTIME/3600)=Theta_II(NL:-1:1,1);
                % %         TSim_Theta_U(1:NL,TTIME/3600)=Theta_UU(NL:-1:1,1);
                %         TSim_Temp(1:NL,KTN,IP0STm)=TT(NL:-1:1);
                % % %          TTRAP(TTIME/3600)=Trap(KT);
                % % %          tpt(TTIME/3600)=QMT(KT);
                % % %          TEVAP(TTIME/3600)=Evap(KT);
                % % %          Ttpt(TTIME/3600)=Tp_t(KT);
                % % %          TWIS(TTIME/3600)=WISDT;
                % %          for ML=1:NL
                % %             if ~Soilairefc
                % %                 QLHHT(ML,TTIME/3600)=QLH(ML);
                % %                 QLTTT(ML,TTIME/3600)=QLT(ML);
                % %             else
                % %                 QLHHT(ML,TTIME/3600)=QL_h(ML);
                % %                 QLTTT(ML,TTIME/3600)=QL_T(ML);
                % %                 QLAAT(ML,TTIME/3600)=QL_a(ML);
                % %             end
                % %          end
                % %         TIMEt=TIME;
                % %         SAVEtS=tS;%Ohy=Theta_r';Osat=Theta_s';
                % %         Ohy(1:1:NL)=Theta_r(NL:-1:1).* Gama_hh(NL:-1:1);
                % %         Vout(1,:) = ((Theta_U(ndz:-1:1,1)'+Theta_U(ndz:-1:1,2)')./2 -Ohy).*dz;
                % %         Vout(2,:) = ((Theta_UU(ndz:-1:1,1)'+Theta_UU(ndz:-1:1,2)')./2 -Ohy).*dz;
                % %         Tdp=(TT(ndz+1:-1:2)'+TT(ndz:-1:1)')./2;
                % %         Delt_tcur=Delt_t;
                %         STMHPLR0(KTN,IP0STm)=HPILR0;
%                         STMHPLR1N(KTN,IP0STm)=HPILR1N;
% %                 %         STMZTB0(KTN)=ZTB0G;
%                         STMZTB1(KTN)=ZTB1G;
%                         STMRrN(KTN,IP0STm)=RrNGG;
% %                 %         STMRrO(KTN,IP0STm)=RrOGG;
%                 % %         STMSY(KTN)=SYSTG;
%                 % %         STMSS(KTN)=SSSTG;
%                         IBOTSTM(KTN,IP0STm)=IBOT;
                % %         KPILRSTM(KTN)=DELTT;
                %         IPSTM(KTN,IP0STm)=IP0STm;
                %
                % %         STETEND(KT,IP0STm)=TEND1;
                %%
                %  if KTN==1
                %      if exist('h02','var')
                %          if ~isempty(h02)
                %              NNK=length(h02)-1;NLK=NNK-1;
                %              THH2(1:NNK+1,KTN,1:NPILR)=hh02(1:NNK+1,KTN-1,1:NPILR);
                %              ThOLD2(1:NNK+1,KTN,1:NPILR)=h02(1:NNK+1,KTN-1,1:NPILR);
                %          end
                %      end
                %  else
                %         NNK=length(h02)-1;NLK=NNK-1;
                %         THH2(1:NNK+1,KTN,1:NPILR)=THH2(1:NNK+1,KTN-1,1:NPILR);
                %         ThOLD2(1:NNK+1,KTN,1:NPILR)=ThOLD2(1:NNK+1,KTN-1,1:NPILR);
                % %         TTOLD2(1:NNK,KTN,1:NPILR)=TTOLD2(1:NNK,KTN-1,1:NPILR);
                % %         TTTt2(1:NNK,KTN,1:NPILR)=TTTt2(1:NNK,KTN-1,1:NPILR);
                % %         TP_gOLD2(1:NNK,KTN,1:NPILR)=TP_gOLD2(1:NNK,KTN-1,1:NPILR);
                % %         TP_gg2(1:NNK,KTN,1:NPILR)=TP_gg2(1:NNK,KTN-1,1:NPILR);
                % %
                % %         TSim_Theta2(1:NLK,KTN,1:NPILR)=TSim_Theta2(1:NLK,KTN-1,1:NPILR);
                % %         TSim_Temp2(1:NLK,KTN,1:NPILR)=TSim_Temp2(1:NLK,KTN-1,1:NPILR);
                % %         STMHPLR02(KTN,1:NPILR)=STMHPLR02(KTN-1,1:NPILR);
                % %         STMHPLR1N2(KTN,1:NPILR)= STMHPLR1N2(KTN-1,1:NPILR);
                % %         STMZTB02(KTN)=STMZTB02(KTN-1);
                % %         STMZTB12(KTN)=STMZTB12(KTN-1);
                % %         STMRrN2(KTN,1:NPILR)=STMRrN2(KTN-1,1:NPILR);
                % %         STMRrO2(KTN,1:NPILR)=STMRrO2(KTN-1,1:NPILR);
                % %         IBOTSTM2(KTN,1:NPILR)=IBOTSTM2(KTN-1,1:NPILR);
                % %         IPSTM2(KTN,1:NPILR)=IPSTM2(KTN-1,1:NPILR);
                % % %         STETEND2(KT,1:NPILR)=STETEND2(KT,1:NPILR);
                %  end
                %
                %
                % else
                %         THH2(1:NN+1,KTN,IP0STm)=hh(1:NN+1);
                %         ThOLD2(1:NN+1,KTN,IP0STm)=hOLD(1:NN+1);
                % %         TTOLD2(1:NN,KTN,IP0STm)=TOLD(1:NN);
                % %         TTTt2(1:NN,KTN,IP0STm)=TT(1:NN);
                % %         TP_gOLD2(1:NN,KTN,IP0STm)=P_gOLD(1:NN);
                % %         TP_gg2(1:NN,KTN,IP0STm)=P_gg(1:NN);
                % %
                % %         TSim_Theta2(1:NL,KTN,IP0STm)=Theta_LL(NL:-1:1,1);
                % %         TSim_Temp2(1:NL,KTN,IP0STm)=TT(NL:-1:1);
                % %         STMHPLR02(KTN,IP0STm)=HPILR0;
                % %         STMHPLR1N2(KTN,IP0STm)=HPILR1N;
                % %         STMZTB02(KTN)=ZTB0G;
                % %         STMZTB12(KTN)=ZTB1G;
                % %         STMRrN2(KTN,IP0STm)=RrNGG;
                % %         STMRrO2(KTN,IP0STm)=RrOGG;
                % % %         STMSY(KTN)=SYSTG;
                % % %         STMSS(KTN)=SSSTG;
                % %         IBOTSTM2(KTN,IP0STm)=IBOT;
                % % %         KPILRSTM(KTN)=DELTT;
                % %         IPSTM2(KTN,IP0STm)=IP0STm;
                % % %         STETEND2(KT,IP0STm)=TEND1;
                %
                % %%
                % % if KTN>1
                %         NNK1=length(h0)-1;NLK1=NNK1-1;
                %         THH(1:NNK1+1,KTN,1:NPILR)=THH(1:NNK1+1,KTN,1:NPILR);
                %         ThOLD(1:NNK1+1,KTN,1:NPILR)=ThOLD(1:NNK1+1,KTN,1:NPILR);
                % %         TTOLD(1:NNK1,KTN,1:NPILR)=TTOLD(1:NNK1,KTN,1:NPILR);
                % %         TTTt(1:NNK1,KTN,1:NPILR)=TTTt(1:NNK1,KTN,1:NPILR);
                % %         TP_gOLD(1:NNK1,KTN,1:NPILR)=TP_gOLD(1:NNK1,KTN,1:NPILR);
                % %         TP_gg(1:NNK1,KTN,1:NPILR)=TP_gg(1:NNK1,KTN,1:NPILR);
                % %
                % %         TSim_Theta(1:NLK1,KTN,1:NPILR)=TSim_Theta(1:NLK1,KTN,1:NPILR);
                % %         TSim_Temp(1:NLK1,KTN,1:NPILR)=TSim_Temp(1:NLK1,KTN,1:NPILR);
                % %         STMHPLR0(KTN,1:NPILR)=STMHPLR0(KTN,1:NPILR);
                % %         STMHPLR1N(KTN,1:NPILR)= STMHPLR1N(KTN,1:NPILR);
                % %         STMZTB0(KTN)=STMZTB0(KTN);
                % %         STMZTB1(KTN)=STMZTB1(KTN);
                % %         STMRrN(KTN,1:NPILR)=STMRrN(KTN,1:NPILR);
                % %         STMRrO(KTN,1:NPILR)=STMRrO(KTN,1:NPILR);
                % %         IBOTSTM(KTN,1:NPILR)=IBOTSTM(KTN,1:NPILR);
                % %         IPSTM(KTN,1:NPILR)=IPSTM(KTN,1:NPILR);
                % %         STETEND(KT,1:NPILR)=STETEND(KT,1:NPILR);
                % % end
                % end
%                 if mod(KTN,5)==0%KTN==80
%                     save('202103021.mat');
%                 end
                save('20210412.mat');
                clear i NN L IBOT XElemnt
                %         keyboard
                return %break
            end
        end
%         return
    end
%     return
end
%%
% if IP0STm>=6 %&& itlevel1==0
%     
% %%    run Constants_StartInit2
%     %         itlevel2=0;
%     %         itlevel2=itlevel2+1;
%     % sum2=2
%     %     end
%     % end
%     % sum3=3
%     % end
%     
%     % % function MainLoop
%     % global i tS KT Delt_t TEND TIME MN NN NL ML ND hOLD TOLD h hh T TT P_gOLD P_g P_gg Delt_t0
%     % global KIT NIT TimeStep Processing KTNUM
%     % global SUMTIME hhh TTT P_ggg Theta_LLL DSTOR Thmrlefc CHK Theta_LL Theta_L
%     % global NBCh AVAIL Evap DSTOR0 EXCESS QMT RS BCh hN hSAVE NBChh DSTMAX Soilairefc
%     % global TSAVE IRPT1 IRPT2 AVAIL0 TIMEOLD TIMELAST Ts_Min Ts_Max
%     % global DDEhBAR DEhBAR DDRHOVhDz DRHOVhDz EEtaBAR EtaBAR DD_Vg D_Vg DDRHOVTDz DRHOVTDz KKLhBAR KLhBAR KKLTBAR KLTBAR DDTDBAR DTDBAR QVV QLL CChh SAVEDTheta_LLT SAVEDTheta_LLh SAVEDTheta_UUh DSAVEDTheta_LLT DSAVEDTheta_LLh DSAVEDTheta_UUh
%     % global CChT QVT QVH QVTT QVHH SSa Sa HRA HR QVAA QVa QLH QLT QLHH QLTT DVH DVHH DVT DVTT SSe Se QAA QAa QL_TT QL_HH QLAA QL_a DPgDZ DDPgDZ k_g kk_g VV_A V_A Theta_r Theta_s m n Alpha SAVETheta_UU  Gama_hh Theta_a Gama_h hm hd
%     % global SAVEKfL_h KCHK FCHK TKCHK hCHK TSAVEhh SAVEhh_frez Precip SAVETT INDICATOR rwuef TSim_Theta TSim_Theta_I TSim_Theta_U TSim_Temp Gvc Tp_t DeltZ TTdps Rnnet HG QEG QvG Lphot GHT
%     % global Precip_msr WS_msr Ta_msr RH_msr Pg_msr SAD1_msr RH_msr_sat SAD2_msr Rn_msr Rns_msr SAB1_msr SAB2_msr Rlatm Tdew_msr PARB_msr PARD_msr Tat COR U HR_a Rns TopPg Ta_EVAP LAI_EVAP Rnld LAI_EVAP_ALL
%     % global TVXY TGXY TAHXY EAHXY FWETXY ALBOLDXY CANLIQXY CANICEXY SNOWHXY SNEQVOXY SNEQVXY ISNOWXY CHXY CMXY QSNOWXY
%     % global TTS TTV TTG TSSOIL TFGEV TFCTR TSAV TSAG TFSA TFIRA TFSH TFCEV LAI1 TFSHA SAVETHETAII mL SAVETHETA
%     % global TTTS TTTV TTTG TTSSOIL TTFGEV TTFCTR TTSAV TTSAG TTFSA TTFIRA TTFSH TTFCEV Vavail_mul%LAI1 TFSHA SAVETHETAII mL SAVETHETA
%     % global QMTT Shh Sh STheta_LL STheta_L TSEC1 TSEC0 TQL IBOT TEND1 hBOT IBOTM%KTN TTEND TTIME% if TTIME==7200
%     % global TimeStp SGWTIME XElemnt QQS DDW dMODQ RRrN STETEND ITCTRL1 ITCTRL0 itlevel1 itlevel2
%     % global STMHPLR0 STMHPLR1N STMZTB0 STMZTB1 STMRrN STMRrO STMSY STMSS Q3DF ADAPTF RrNGG RrOGG
%     % global TP_gg TP_gOLD TTTt TTOLD ThOLD THH h0 hh0 IBOTSTM KPILRSTM IPSTM BOT_NODES KPILLAR BOTm SYSTG SSSTG
%     % global STMHPLR02 STMHPLR1N2 STMZTB02 STMZTB12 STMRrN2 STMRrO2 STMSY2 STMSS2 RrNGG2 RrOGG2 IPSTM2
%     % global TP_gg2 TP_gOLD2 TTTt2 TTOLD2 ThOLD2 THH2 h02 hh02 IBOTSTM2 TSim_Theta2 TSim_Temp2 STETEND2 IP0STm1 iBOTNODEs
%     
%     %% set constants for GW
%     NLAY=2;
%     NPILR=9;
%     ITERQ3D=1;
%     % IP=1;
%     IGRID=1;
%     Q3DF=1;
%     RELAXF=0.8;
%     % KPILLAR=ones(NN);
%     ADAPTF=1;
%     %%
% %     if ~exist('KTNUM','var')
%         if KT+1==0
%             KT=0;
%         else
%             KT=KT;
%         end
% %     else
% %         if length(KTNUM)>=IP0STm
% %             if KTNUM(IP0STm)>0
% %                 KT=KTNUM(IP0STm);
% %             else
% %                 if KT+1==0
% %                     KT=0;
% %                 else
% %                     KT=KT;
% %                 end
% %             end
% %         else
% %             if KT+1==0
% %                 KT=0;
% %             else
% %                 KT=KT;
% %             end
% %         end
% %         
% %     end
%     
%     %% IP parameter
%     if IP0STm==1
%         if (~exist('iBOTNODEs','var') || isempty(iBOTNODEs))
%             BOTm=zeros(NLAY+1,NPILR);
%             SYSTG=zeros(NLAY,NPILR);
%             SSSTG=zeros(NLAY,NPILR);
%         end
%         file_path = 'BOT_NODES.txt';
%         FID = fopen(file_path);
%         s = dir(file_path);
%         % KT=0
%         
%         if FID>=0
%             if (~exist('iBOTNODEs','var') || isempty(iBOTNODEs)) && s.bytes ~= 0 %KT==0
%                 iBOTNODEs=1;
%                 %% Check whether running on PC or MAC/UNIX machine
%                 %     if ispc, slash_dir = '\'; else slash_dir = '/'; end
%                 
%                 %% Store working directory and subdirectory containing the files needed to run this example
%                 %     EXAMPLE_dir = [pwd ,slash_dir,'grid1/HYDRUS1/']; %CONV_dir = [pwd ,slash_dir,'diagnostics'];
%                 EXAMPLE_dir = pwd ; %CONV_dir = [pwd ,slash_dir,'diagnostics'];
%                 addpath(EXAMPLE_dir);
%                 load BOT_NODES.txt;
%                 NNK=0;
%                 %     KPILLAR=BOT_NODES(1:NNK);%[1	1	1	1	1	2	2	2	2	2	3	3	3	3	3	4	4	4	4	4	5	5	5	5	5	6	6	6	6	6	7	7	7	7	7	8	8	8	8	8	9	9	9	9	9	10	10	10	10	10	11	11	11	11	11	12	12	12	12	12	13	13	13	13	13	14	14	14	14	14	15	15	15	15	15	16	16	16	16	16	17	17	17	17	17	18	18	18	18	18	19	19	19	19	19	20	20	20	20	20	21	21	21	21	21	22	22	22	22	22	23	23	23	23	23	24	24	24	24	24	25	25	25	25	25	26	26	26	26	26	27	27	27	27	27	28	28	28	28	28	29	29	29	29	29	30	30	30	30	30	31	31	31	31	31	32	32	32	32	32	33	33	33	33	33	34	34	34	34	34	35	35	35	35	35	36	36	36	36	36	37	37	37	37	37	38	38	38	38	38	39	39	39	39	39	40	40	40	40	40	41	41	41	41	41	42	42	42	42	42	43	43	43	43	43	44	44	44	44	44	45	45	45	45	45	46	46	46	46	46	47	47	47	47	47	48	48	48	48	48	49	49	49	49	49	50	50	50	50	50	51	51	51	51	51	52	52	52	52	52	53	53	53	53	53	54	54	54	54	54	55	55	55	55	55	56	56	56	56	56	57	57	57	57	57	58	58	58	58	58	59	59	59	59	59	60	60	60	60	60	61	61	61	61	61	62	62	62	62	62	63	63	63	63	63	64	64	64	64	64	65	65	65	65	65	66	66	66	66	66	67	67	67	67	67	68	68	68	68	68	69	69	69	69	69	70	70	70	70	70	71	71	71	71	71	72	72	72	72	72	73	73	73	73	73	74	74	74	74	74	75	75	75	75	75	76	76	76	76	76	77	77	77	77	77	78	78	78	78	78	79	79	79	79	79	80	80	80	80	80	81	81	81	81	81	81	81	81	81	81	81	81	81	82	82	82	82	82	82	82	82	82	82	82	82	83	83	83	83	83	83	83	83	83	83	83	83	83	84	84	84	84	84	84	84	84	84	84	84	84	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91]';
%                 if NPILR==1
%                     BOTm(1:NLAY+1,1)=BOT_NODES(NNK+1:NNK+1+(NLAY+1)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
%                     SYSTG(1:NLAY,1)=BOT_NODES(NNK+1+(NLAY+1):NNK+1+(NLAY+1)+(NLAY)-1);
%                     SSSTG(1:NLAY,1)=BOT_NODES(NNK+1+(NLAY+1)+(NLAY):NNK+1+(NLAY+1)+(NLAY)+(NLAY)-1);
%                     
%                 else
%                     BOTm(1:NLAY+1,1)=BOT_NODES(NNK+1:NNK+1+(NLAY+1)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
%                     SYSTG(1:NLAY,1)=BOT_NODES(NNK+1+NPILR*(NLAY+1):NNK+1+NPILR*(NLAY+1)+(NLAY)-1);
%                     SSSTG(1:NLAY,1)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY):NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(NLAY)-1);
%                     for i=2:NPILR
%                         BOTm(1:NLAY+1,i)=BOT_NODES(NNK+1+(i-1)*(NLAY+1):NNK+1+i*(NLAY+1)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
%                         SYSTG(1:NLAY,i)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+(i-1)*(NLAY):NNK+1+NPILR*(NLAY+1)+(i)*(NLAY)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
%                         SSSTG(1:NLAY,i)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(i-1)*(NLAY):NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(i)*(NLAY)-1);
%                     end
%                 end
%                 
%             end
%         end
%         fclose(FID);
%         % if sum(BOTm(:,NPILR))==0 || sum(SYSTG(:,NPILR))==0
%         %     KPILLAR=[1	1	1	1	1	2	2	2	2	2	3	3	3	3	3	4	4	4	4	4	5	5	5	5	5	6	6	6	6	6	7	7	7	7	7	8	8	8	8	8	9	9	9	9	9	10	10	10	10	10	11	11	11	11	11	12	12	12	12	12	13	13	13	13	13	14	14	14	14	14	15	15	15	15	15	16	16	16	16	16	17	17	17	17	17	18	18	18	18	18	19	19	19	19	19	20	20	20	20	20	21	21	21	21	21	22	22	22	22	22	23	23	23	23	23	24	24	24	24	24	25	25	25	25	25	26	26	26	26	26	27	27	27	27	27	28	28	28	28	28	29	29	29	29	29	30	30	30	30	30	31	31	31	31	31	32	32	32	32	32	33	33	33	33	33	34	34	34	34	34	35	35	35	35	35	36	36	36	36	36	37	37	37	37	37	38	38	38	38	38	39	39	39	39	39	40	40	40	40	40	41	41	41	41	41	42	42	42	42	42	43	43	43	43	43	44	44	44	44	44	45	45	45	45	45	46	46	46	46	46	47	47	47	47	47	48	48	48	48	48	49	49	49	49	49	50	50	50	50	50	51	51	51	51	51	52	52	52	52	52	53	53	53	53	53	54	54	54	54	54	55	55	55	55	55	56	56	56	56	56	57	57	57	57	57	58	58	58	58	58	59	59	59	59	59	60	60	60	60	60	61	61	61	61	61	62	62	62	62	62	63	63	63	63	63	64	64	64	64	64	65	65	65	65	65	66	66	66	66	66	67	67	67	67	67	68	68	68	68	68	69	69	69	69	69	70	70	70	70	70	71	71	71	71	71	72	72	72	72	72	73	73	73	73	73	74	74	74	74	74	75	75	75	75	75	76	76	76	76	76	77	77	77	77	77	78	78	78	78	78	79	79	79	79	79	80	80	80	80	80	81	81	81	81	81	81	81	81	81	81	81	81	81	82	82	82	82	82	82	82	82	82	82	82	82	83	83	83	83	83	83	83	83	83	83	83	83	83	84	84	84	84	84	84	84	84	84	84	84	84	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	85	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	86	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	87	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	88	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	89	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	90	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91	91]';
%         % for in=1:NPILR
%         %     BOTm(1:NLAY+1,in)=[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
%         % end
%         % end
%     end
%     
%     [KPILLAR]=KPILR_Cal(BOTm.*HPUNIT,XElemnt,IP0STm);
%     % SYSTG=0.37;
%     % SSSTG=0;
%     % DELTT=0;
%     RrOGG=0;
%     % if KTN==1 && TIME==0
%     %     HPILR1N=200;
%     %     HPILR0=200;
%     % end
%     % XElemnt=zeros(NN,1);
%     % XElemnt(1)=0;
%     % TDeltZ=flip(DeltZ);
%     % % BOTm=XElemnt(NN);
%     % for ML=2:NL
%     %     XElemnt(ML)=XElemnt(ML-1)+TDeltZ(ML-1);
%     % end
%     % XElemnt(NN)=1000;
%     % % IBOT=IBOTT;
%     
%     Shh=zeros(NN,1);STheta_LL=zeros(NN,1);STheta_L=zeros(NN,1);
%     Sh=zeros(NN,1);
%     Ts_Min=0;Ts_Max=80;%TIME=3600;
%     
%     %
%     % run StartInit;   % Initialize Temperature, Matric potential and soil air pressure.
%     % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     TIMEOLD=0;Delt_t=1;
%     TIMELAST=0;TIME=TTIME*3600*24;TEND1=(TTIME+TTEND)*3600*24;%TSEC0;
%     SGWTIME(KTN,1)=TIME;
%     % % for i=1:tS+1                          % Notice here: In this code, the 'i' is strictly used for timestep loop and the arraies index of meteorological forcing data.
%     %     KT=1                          % Counting Number of timesteps
%     % %     if KT>1 && Delt_t>(TEND-TIME)
%     % %         Delt_t=TEND-TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
%     % %     end
%     % %     TIME=TIME+Delt_t;               % The time elapsed since start of simulation
%     %     TimeStep(KT,1)=Delt_t;
%     %     SUMTIME(KT,1)=TIME;
%     % %     Processing=TIME/TEND
%     % if IP0STm>5
%     %     if KTN==1
%     %         h=h0;
%     %         hh=hh0;
%     %     else
%     %         h(1:NN)=ThOLD(1:NN,KTN-1,IP0STm);
%     %         hh(1:NN)=THH(1:NN,KTN-1,IP0STm);
%     %     end
%     % else
%     if KTN==1
%         h=h02;
%         hh=hh02;
%     else
% %         h(1:NN)=ThOLD2(1:NN,IP0STm);
% %         hh(1:NN)=THH2(1:NN,IP0STm);
%         h(1:NN)=ThOLD2(1:NN,KTN-1,IP0STm);
%         hh(1:NN)=THH2(1:NN,KTN-1,IP0STm);
%     end
%     % end
%     
%     run SOIL2;
%     
%     STheta_L(2:1:NN)=Theta_LL(NN-1:-1:1,1);
%     STheta_L(1)=Theta_LL(NL,2);
%     Sh(1:1:NN)=hh(NN:-1:1);
% 
%     THETA0=STheta_L;
%     QS=zeros(NN,1);
%     Theta_L=Theta_LL;
%     
%     [ZTB0G,ICTRL0]=FINDTABLE(IP0STm,Sh,XElemnt,NN);%[ICTRL0]=FINDTABLE(ZTB0G,IP,Sh);
%     %         return
%     %     end
%     save('2021030292.mat');
%     
%     for i=1:1:15000                        % Notice here: In this code, the 'i' is strictly used for timestep loop and the arraies index of meteorological forcing data.
%         KT=KT+1;                          % Counting Number of timesteps
%         if KT>1 && Delt_t>(TEND1-TIME)
%             Delt_t=TEND1-TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
%         end
%         %     KTN=KT;
%         
%         TIME=TIME+Delt_t;               % The time elapsed since start of simulation
%         TimeStep(KTN,1)=Delt_t;
%         TimeStp(KT,1)=Delt_t;
%         SUMTIME(KT,1)=TIME;
%         Processing=TIME/TEND1;
%         %%%%%% Updating the state variables. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%% find the bottom layer of soil column %%%%%%%%%%%%%%%%%%%%%
%         [HPILLAR,IBOT]=TIME_INTERPOLATION(TEND1,TTIME*86400,IP0STm,BOTm.*HPUNIT,HPILR1N*HPUNIT,HPILR0*HPUNIT,TIME,TTEND*86400,XElemnt,NN,Q3DF,ADAPTF);
%         hBOT(KT)=HPILLAR;
%         IBOTM(KT)=IBOT;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%
%         if IRPT1==0 && IRPT2==0
%             for MN=1:NN
%                 hOLD(MN)=h(MN);
%                 h(MN)=hh(MN);
%                 hhh(MN,KT)=hh(MN);
%                 if Thmrlefc==1
%                     TOLD(MN)=T(MN);
%                     T(MN)=TT(MN);
%                     TTT(MN,KT)=TT(MN);
%                 end
%                 if Soilairefc==1
%                     P_gOLD(MN)=P_g(MN);
%                     P_g(MN)=P_gg(MN);
%                     P_ggg(MN,KT)=P_gg(MN);
%                 end
%             end
%             DSTOR0=DSTOR;
%             if KT>1
%                 run SOIL1
%             end
%         end
%         
%         if Delt_t~=Delt_t0
%             for MN=1:NN
%                 hh(MN)=h(MN)+(h(MN)-hOLD(MN))*Delt_t/Delt_t0;
%                 TT(MN)=T(MN)+(T(MN)-TOLD(MN))*Delt_t/Delt_t0;
%             end
%         end
%         hSAVE=hh(NN);
%         TSAVE=TT(NN);
%         if NBCh==1
%             hN=BCh;
%             hh(NN)=hN;
%             hSAVE=hN;
%         elseif NBCh==2
%             if NBChh~=2
%                 if BCh<0
%                     hN=DSTOR0;
%                     hh(NN)=hN;
%                     hSAVE=hN;
%                 else
%                     hN=-1e6;
%                     hh(NN)=hN;
%                     hSAVE=hN;
%                 end
%             end
%         else
%             if NBChh~=2
%                 hN=DSTOR0;
%                 hh(NN)=hN;
%                 hSAVE=hN;
%             end
%         end
%         run Forcing_PARM
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         for KIT=1:NIT   % Start the iteration procedure in a time step.
%             
%             run SOIL2;
%             run CondL_T;
%             run Density_V;
%             run CondL_Tdisp;
%             %         run Latent;
%             %         run Density_DA;
%             %         run CondT_coeff;
%             %         run Condg_k_g;
%             %         run CondV_DE;
%             %         run CondV_DVg;
%             %
%             %         run h_sub;
%             run Diff_Moisture_Heat;
%             if NBCh==1
%                 DSTOR=0;
%                 RS=0;
%             elseif NBCh==2
%                 AVAIL=-BCh;
%                 EXCESS=(AVAIL+QMT(KT))*Delt_t;
%                 if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
%                 DSTOR=min(EXCESS,DSTMAX);
%                 RS=(EXCESS-DSTOR)/Delt_t;
%             else
%                 AVAIL=AVAIL0-Evap(KT);
%                 EXCESS=(AVAIL+QMT(KT))*Delt_t;
%                 if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
%                 DSTOR=0;
%                 RS=0;
%             end
%             
%             %         if Soilairefc==1
%             %             run Air_sub;
%             %         end
%             %
%             %         if Thmrlefc==1
%             %             run Enrgy_sub;
%             %         end
%             
%             if max(CHK)<0.001
%                 break
%             end
%             hSAVE=hh(NN);
%             TSAVE=TT(NN);
%         end
%         TIMEOLD=KT;
%         KIT;
%         KIT=0;
%         run SOIL2;
%         run TimestepCHK
%         %     save('20210309.mat')
%         %         save('202103019.mat')
%         
%         if IRPT1==0 && IRPT2==0
%             QS(:)=QS(:)+TQL(:)*Delt_t/86400;
%             if KT        % In case last time step is not convergent and needs to be repeated.
%                 MN=0;
%                 for ML=1:NL
%                     for ND=1:2
%                         MN=ML+ND-1;
%                         Theta_LLL(ML,ND,KT)=Theta_LL(ML,ND);
%                         Theta_L(ML,ND)=Theta_LL(ML,ND);
%                         %                 Theta_UUU(ML,ND,KT)=Theta_UU(ML,ND);
%                         %                 Theta_U(ML,ND)=Theta_UU(ML,ND);
%                         %                 Theta_III(ML,ND,KT)=Theta_II(ML,ND);
%                         %                 Theta_I(ML,ND)=Theta_II(ML,ND);
%                         %                 DDTheta_LLh(ML,KT)=DTheta_LLh(ML,2);
%                         %                 DDTheta_LLT(ML,KT)=DTheta_LLT(ML,2);
%                         %                 DDTheta_UUh(ML,KT)=DTheta_UUh(ML,2);
%                     end
%                 end
%                 %         run ObservationPoints
%             end
%             
%             %     [RrNG,RrOG,SC2]=HYDRUS1RECHARGE(TEND1,TTIME*86400,ITERQ3D,IP,IGRID,Q3DF,THETA0,ICTRL0,STheta_LL,TIME,TQL,Delt_t,TTEND*86400,ZTB0G,ZTB1G,Shh,KPILLAR,BOTm,RrNG,SYSTG,0,XElemnt);
%             if (TEND1-TIME)<1E-3
%                 Shh(1:1:NN)=hh(NN:-1:1);
%                 STheta_LL(2:1:NN)=Theta_LL(NL:-1:1,1);
%                 STheta_L(2:1:NN)=Theta_L(NL:-1:1,1);
%                 STheta_LL(1)=Theta_LL(NL,2);STheta_L(1)=Theta_L(NL,2);
%                 %     if KTN==1
%                 %     [RrNGG,RrOGG,ZTB1G]=HYDRUS1RECHARGE(TEND1/86400,TTIME,ITERQ3D,IP,IGRID,Q3DF,THETA0,ICTRL0,STheta_LL,TIME/86400,...
%                 %         QS,Delt_t/86400,TTEND,ZTB0G,Shh,KPILLAR,XElemnt(NN),0,0.3,0,XElemnt,KTN);
%                 %     else
%                 [RrNGG,RrOGG,ZTB1G]=HYDRUS1RECHARGE(TEND1/86400,TTIME,ITERQ3D,IP0STm,IGRID,Q3DF,THETA0,ICTRL0,STheta_LL,TIME/86400,...
%                     QS,Delt_t/86400,TTEND,ZTB0G,Shh,KPILLAR,BOTm.*HPUNIT,RrNG,SYSTG,SSSTG,XElemnt,KTN);
%             
%                 if isnan(RrNGG) || isinf(RrNGG)
%                     RrNGG=0;
%                 end
%                 if isnan(RrOGG) || isinf(RrOGG)
%                     RrOGG=0;
%                 end
%                 %     end
%                 %         for MN=1:NN
%                 %             hOLD(MN)=h(MN);
%                 %             h(MN)=hh(MN);
%                 %             hhh(MN,KT)=hh(MN);
%                 %             HRA(MN,KT)=HR(MN);
%                 %             if Thmrlefc==1
%                 %                 TOLD(MN)=T(MN);
%                 %                 T(MN)=TT(MN);
%                 %                 TTT(MN,KT)=TT(MN);
%                 %             end
%                 %             if Soilairefc==1
%                 %                 P_gOLD(MN)=P_g(MN);
%                 %                 P_g(MN)=P_gg(MN);
%                 %                 P_ggg(MN,KT)=P_gg(MN);
%                 %             end
%                 %         end
% %                 KTNUM(IP0STm)=KT;
%                 % if KTN==1
%                 %     if (exist('h0','var')) %&& ~exist('h02','var')
%                 %         if ~isempty(h0)
%                 %
%                 %             NNK1=length(h0)-1;NLK1=NNK1-1;
%                 %             for IPm=1:NPILR
%                 %
%                 %                 THH(1:NNK1+1,KTN,IPm)=h0(1:NNK1+1).*0;
%                 %                 ThOLD(1:NNK1+1,KTN,IPm)=h0(1:NNK1+1).*0;
%                 %                 %         TTOLD(1:NN,KTN,IPm)=TOLD(1:NN).*0;
%                 %                 %         TTTt(1:NN,KTN,IPm)=TT(1:NN).*0;
%                 %                 %         TP_gOLD(1:NN,KTN,IPm)=P_gOLD(1:NN).*0;
%                 %                 %         TP_gg(1:NN,KTN,IPm)=P_gg(1:NN).*0;
%                 %                 %
%                 %                 %         TSim_Theta(1:NL,KTN,IPm)=Theta_LL(NL:-1:1,1).*0;
%                 %                 %         TSim_Temp(1:NL,KTN,IPm)=TT(NL:-1:1).*0;
%                 %                 %         STMHPLR0(KTN,IPm)=HPILR0.*0;
%                 %                 %         STMHPLR1N(KTN,IPm)=HPILR1N.*0;
%                 %                 %         STMZTB0(KTN)=ZTB0G.*0;
%                 %                 %         STMZTB1(KTN)=ZTB1G.*0;
%                 %                 %         STMRrN(KTN,IPm)=RrNGG.*0;
%                 %                 %         STMRrO(KTN,IPm)=RrOGG.*0;
%                 %                 %         IBOTSTM(KTN,IPm)=IBOT.*0;
%                 %                 %         IPSTM(KTN,IPm)=IP0STm.*0;
%                 %                 %
%                 %                 % %         STETEND(KT,IPm)=TEND1.*0;
%                 %             end
%                 %         end
%                 %     end
%                 %     %  %%
%                 %     if exist('h02','var')
%                 %         if ~isempty(h02)
%                 %             NNK=length(h02)-1;NLK=NNK-1;
%                 %             for IPm=1:NPILR
%                 %                 THH2(1:NNK+1,KTN,IPm)=h02(1:NNK+1).*0;
%                 %                 ThOLD2(1:NNK+1,KTN,IPm)=h02(1:NNK+1).*0;
%                 %                 %          TTOLD2(1:NN,KTN,IPm)=h02(1:NN).*0;
%                 %                 %          TTTt2(1:NN,KTN,IPm)=h02(1:NN).*0;
%                 %                 %          TP_gOLD2(1:NN,KTN,IPm)=h02(1:NN).*0;
%                 %                 %          TP_gg2(1:NN,KTN,IPm)=h02(1:NN).*0;
%                 %                 %
%                 %                 %          TSim_Theta2(1:NL,KTN,IPm)=h02(NL:-1:1,1).*0;
%                 %                 %          TSim_Temp2(1:NL,KTN,IPm)=h02(NL:-1:1).*0;
%                 %                 %          STMHPLR02(KTN,IPm)=HPILR0.*0;
%                 %                 %          STMHPLR1N2(KTN,IPm)=HPILR1N.*0;
%                 %                 %          STMZTB02(KTN)=ZTB0G.*0;
%                 %                 %          STMZTB12(KTN)=ZTB1G.*0;
%                 %                 %          STMRrN2(KTN,IPm)=RrNGG.*0;
%                 %                 %          STMRrO2(KTN,IPm)=RrOGG.*0;
%                 %                 %          IBOTSTM2(KTN,IPm)=IBOT.*0;
%                 %                 %          IPSTM2(KTN,IPm)=IP0STm.*0;
%                 %                 %
%                 %                 % %          STETEND2(KT,IPm)=TEND1.*0;
%                 %             end
%                 %         end
%                 %     end
%                 % end
%                 % if IP0STm<=5
%                 %
%                 %
%                 %         THH(1:NN+1,KTN,IP0STm)=hh(1:NN+1);
%                 %         ThOLD(1:NN+1,KTN,IP0STm)=hOLD(1:NN+1);
%                 % %         TTOLD(1:NN,KTN,IP0STm)=TOLD(1:NN);
%                 % %         TTTt(1:NN,KTN,IP0STm)=TT(1:NN);
%                 % %         TP_gOLD(1:NN,KTN,IP0STm)=P_gOLD(1:NN);
%                 % %         TP_gg(1:NN,KTN,IP0STm)=P_gg(1:NN);
%                 % %
%                 % %         TSim_Theta(1:NL,KTN,IP0STm)=Theta_LL(NL:-1:1,1);
%                 % % %         TSim_Theta_I(1:NL,TTIME/3600)=Theta_II(NL:-1:1,1);
%                 % % %         TSim_Theta_U(1:NL,TTIME/3600)=Theta_UU(NL:-1:1,1);
%                 % %         TSim_Temp(1:NL,KTN,IP0STm)=TT(NL:-1:1);
%                 % % % %          TTRAP(TTIME/3600)=Trap(KT);
%                 % % % %          tpt(TTIME/3600)=QMT(KT);
%                 % % % %          TEVAP(TTIME/3600)=Evap(KT);
%                 % % % %          Ttpt(TTIME/3600)=Tp_t(KT);
%                 % % % %          TWIS(TTIME/3600)=WISDT;
%                 % % %          for ML=1:NL
%                 % % %             if ~Soilairefc
%                 % % %                 QLHHT(ML,TTIME/3600)=QLH(ML);
%                 % % %                 QLTTT(ML,TTIME/3600)=QLT(ML);
%                 % % %             else
%                 % % %                 QLHHT(ML,TTIME/3600)=QL_h(ML);
%                 % % %                 QLTTT(ML,TTIME/3600)=QL_T(ML);
%                 % % %                 QLAAT(ML,TTIME/3600)=QL_a(ML);
%                 % % %             end
%                 % % %          end
%                 % % %         TIMEt=TIME;
%                 % % %         SAVEtS=tS;%Ohy=Theta_r';Osat=Theta_s';
%                 % % %         Ohy(1:1:NL)=Theta_r(NL:-1:1).* Gama_hh(NL:-1:1);
%                 % % %         Vout(1,:) = ((Theta_U(ndz:-1:1,1)'+Theta_U(ndz:-1:1,2)')./2 -Ohy).*dz;
%                 % % %         Vout(2,:) = ((Theta_UU(ndz:-1:1,1)'+Theta_UU(ndz:-1:1,2)')./2 -Ohy).*dz;
%                 % % %         Tdp=(TT(ndz+1:-1:2)'+TT(ndz:-1:1)')./2;
%                 % % %         Delt_tcur=Delt_t;
%                 % %         STMHPLR0(KTN,IP0STm)=HPILR0;
%                 % %         STMHPLR1N(KTN,IP0STm)=HPILR1N;
%                 % %         STMZTB0(KTN)=ZTB0G;
%                 % %         STMZTB1(KTN)=ZTB1G;
%                 % %         STMRrN(KTN,IP0STm)=RrNGG;
%                 % %         STMRrO(KTN,IP0STm)=RrOGG;
%                 % % %         STMSY(KTN)=SYSTG;
%                 % % %         STMSS(KTN)=SSSTG;
%                 % %         IBOTSTM(KTN,IP0STm)=IBOT;
%                 % % %         KPILRSTM(KTN)=DELTT;
%                 % %         IPSTM(KTN,IP0STm)=IP0STm;
%                 % %
%                 % % %         STETEND(KT,IP0STm)=TEND1;
%                 %  %%
%                 %  if KTN==1
%                 %      if exist('h02','var')
%                 %          if ~isempty(h02)
%                 %              NNK=length(h02)-1;NLK=NNK-1;
%                 %              THH2(1:NNK+1,KTN,1:NPILR)=hh02(1:NNK+1,KTN-1,1:NPILR);
%                 %              ThOLD2(1:NNK+1,KTN,1:NPILR)=h02(1:NNK+1,KTN-1,1:NPILR);
%                 %          end
%                 %      end
%                 %  else
%                 %         NNK=length(h02)-1;NLK=NNK-1;
%                 %         THH2(1:NNK+1,KTN,1:NPILR)=THH2(1:NNK+1,KTN-1,1:NPILR);
%                 %         ThOLD2(1:NNK+1,KTN,1:NPILR)=ThOLD2(1:NNK+1,KTN-1,1:NPILR);
%                 % %         TTOLD2(1:NNK,KTN,1:NPILR)=TTOLD2(1:NNK,KTN-1,1:NPILR);
%                 % %         TTTt2(1:NNK,KTN,1:NPILR)=TTTt2(1:NNK,KTN-1,1:NPILR);
%                 % %         TP_gOLD2(1:NNK,KTN,1:NPILR)=TP_gOLD2(1:NNK,KTN-1,1:NPILR);
%                 % %         TP_gg2(1:NNK,KTN,1:NPILR)=TP_gg2(1:NNK,KTN-1,1:NPILR);
%                 % %
%                 % %         TSim_Theta2(1:NLK,KTN,1:NPILR)=TSim_Theta2(1:NLK,KTN-1,1:NPILR);
%                 % %         TSim_Temp2(1:NLK,KTN,1:NPILR)=TSim_Temp2(1:NLK,KTN-1,1:NPILR);
%                 % %         STMHPLR02(KTN,1:NPILR)=STMHPLR02(KTN-1,1:NPILR);
%                 % %         STMHPLR1N2(KTN,1:NPILR)= STMHPLR1N2(KTN-1,1:NPILR);
%                 % %         STMZTB02(KTN)=STMZTB02(KTN-1);
%                 % %         STMZTB12(KTN)=STMZTB12(KTN-1);
%                 % %         STMRrN2(KTN,1:NPILR)=STMRrN2(KTN-1,1:NPILR);
%                 % %         STMRrO2(KTN,1:NPILR)=STMRrO2(KTN-1,1:NPILR);
%                 % %         IBOTSTM2(KTN,1:NPILR)=IBOTSTM2(KTN-1,1:NPILR);
%                 % %         IPSTM2(KTN,1:NPILR)=IPSTM2(KTN-1,1:NPILR);
%                 % % %         STETEND2(KT,1:NPILR)=STETEND2(KT,1:NPILR);
%                 %  end
%                 %
%                 %
%                 % else
% %                 THH2(1:NN+1,IP0STm)=hh(1:NN+1);
% %                 ThOLD2(1:NN+1,IP0STm)=hOLD(1:NN+1);               
%                 THH2(1:NN+1,KTN,IP0STm)=hh(1:NN+1);
%                 ThOLD2(1:NN+1,KTN,IP0STm)=hOLD(1:NN+1);
%                 %         TTOLD2(1:NN,KTN,IP0STm)=TOLD(1:NN);
%                 %         TTTt2(1:NN,KTN,IP0STm)=TT(1:NN);
%                 %         TP_gOLD2(1:NN,KTN,IP0STm)=P_gOLD(1:NN);
%                 %         TP_gg2(1:NN,KTN,IP0STm)=P_gg(1:NN);
%                 %
%                 %         TSim_Theta2(1:NL,KTN,IP0STm)=Theta_LL(NL:-1:1,1);
%                 %         TSim_Temp2(1:NL,KTN,IP0STm)=TT(NL:-1:1);
%                 %         STMHPLR02(KTN,IP0STm)=HPILR0;
% %                         STMHPLR1N2(KTN,IP0STm)=HPILR1N;
% %                 %         STMZTB02(KTN)=ZTB0G;
% %                         STMZTB12(KTN)=ZTB1G;
% %                         STMRrN2(KTN,IP0STm)=RrNGG;
% %                 %         STMRrO2(KTN,IP0STm)=RrOGG;
% %                 % %         STMSY(KTN)=SYSTG;
% %                 % %         STMSS(KTN)=SSSTG;
% %                         IBOTSTM2(KTN,IP0STm)=IBOT;
%                 % %         KPILRSTM(KTN)=DELTT;
%                 %         IPSTM2(KTN,IP0STm)=IP0STm;
%                 % %         STETEND2(KT,IP0STm)=TEND1;
%                 
%                 %%
%                 % % if KTN>1
%                 %         NNK1=length(h0)-1;NLK1=NNK1-1;
%                 %         THH(1:NNK1+1,KTN,1:NPILR)=THH(1:NNK1+1,KTN,1:NPILR);
%                 %         ThOLD(1:NNK1+1,KTN,1:NPILR)=ThOLD(1:NNK1+1,KTN,1:NPILR);
%                 % %         TTOLD(1:NNK1,KTN,1:NPILR)=TTOLD(1:NNK1,KTN,1:NPILR);
%                 % %         TTTt(1:NNK1,KTN,1:NPILR)=TTTt(1:NNK1,KTN,1:NPILR);
%                 % %         TP_gOLD(1:NNK1,KTN,1:NPILR)=TP_gOLD(1:NNK1,KTN,1:NPILR);
%                 % %         TP_gg(1:NNK1,KTN,1:NPILR)=TP_gg(1:NNK1,KTN,1:NPILR);
%                 % %
%                 % %         TSim_Theta(1:NLK1,KTN,1:NPILR)=TSim_Theta(1:NLK1,KTN,1:NPILR);
%                 % %         TSim_Temp(1:NLK1,KTN,1:NPILR)=TSim_Temp(1:NLK1,KTN,1:NPILR);
%                 % %         STMHPLR0(KTN,1:NPILR)=STMHPLR0(KTN,1:NPILR);
%                 % %         STMHPLR1N(KTN,1:NPILR)= STMHPLR1N(KTN,1:NPILR);
%                 % %         STMZTB0(KTN)=STMZTB0(KTN);
%                 % %         STMZTB1(KTN)=STMZTB1(KTN);
%                 % %         STMRrN(KTN,1:NPILR)=STMRrN(KTN,1:NPILR);
%                 % %         STMRrO(KTN,1:NPILR)=STMRrO(KTN,1:NPILR);
%                 % %         IBOTSTM(KTN,1:NPILR)=IBOTSTM(KTN,1:NPILR);
%                 % %         IPSTM(KTN,1:NPILR)=IPSTM(KTN,1:NPILR);
%                 % %         STETEND(KT,1:NPILR)=STETEND(KT,1:NPILR);
%                 % % end
%                 % end
% %                 if mod(KTN,5)==0%KTN==80
% %                     save('2021030212.mat');
% %                 end
%                 
%                 clear i NN L IBOT XElemnt
%                 %         keyboard
%                 return %break
%             end
%         end
% %         return
%     end
% %     return
% end