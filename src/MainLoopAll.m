clc;
clearvars -global -except HPILR1N HPILR0 RrNG KTN TTIME TTEND KTNUM BOT_NODES BOTm SYSTG SSSTG itlevel2 itlevel IP0STm ...
    STMHPLR0 STMHPLR1N STMZTB0 STMZTB1 STMRrN STMRrO STMSY STMSS Q3DF ADAPTF RrNGG RrOGG ...
    TP_gg TP_gOLD TTTt TTOLD ThOLD THH h0 hh0 IBOTSTM KPILRSTM IPSTM TSim_Theta TSim_Temp Tt0 TT0 ThOLD_frez THH_frez ...
    STMHPLR02 STMHPLR1N2 STMZTB02 STMZTB12 STMRrN2 STMRrO2 STMSY2 STMSS2 RrNGG2 RrOGG2 IPSTM2 ...
    TP_gg2 TP_gOLD2 TTTt2 TTOLD2 ThOLD2 THH2 h02 hh02 IBOTSTM2 TSim_Theta2 TSim_Temp2 STETEND2 iBOTNODEs STMDelt STMDelt0 STMDelt2 STMDelt02 HPUNIT ThOLD_frez THH_frez rwuef

TIME=0;
%% set constants for Groundwater module, added by LY
NLAY=5;     % number of layer in MODFLOW
NPILR=44;   % number of soil columns
ITERQ3D=1;  % indicator for the quasi-3d iteration simulation
IGRID=1;    % 
Q3DF=1;     % indicator for the quasi-3d simulation
RELAXF=0.8; % ralaxation factor
ADAPTF=1;   % indicator for the adaptive lower boundary setting, =1, the moving lower boundary scheme is used; =0, the fixed lower boundary scheme is used
IP0STmcn=1;
NumN=100;   % number of soil layers for STEMMUS
IP0STmN=NPILR;
ThOLD=zeros(NumN,IP0STmN);  % The matric head at the end of last time step, added by LY
THH=zeros(NumN,IP0STmN);    % The matric head at the end of current time step;
TTOLD=zeros(NumN,IP0STmN);  % The soil temperature at the end of last time step;
TTTt=zeros(NumN,IP0STmN);   % The soil temperature at the end of current time step;
hOLD_frez=zeros(NumN,IP0STmN);  % The freezing soil matric head at the end of last time step;
THH_frez=zeros(NumN,IP0STmN);   % The freezing soil matric head at the end of current time step;
ThOLDtm1=zeros(NumN,IP0STmN);   % The matric head at the start of last time step;
THHtm1=zeros(NumN,IP0STmN);     % The matric head at the start of current time step;
TTOLDtm1=zeros(NumN,IP0STmN);   % The soil temperature at the start of last time step;
TTTttm1=zeros(NumN,IP0STmN);    % The soil temperature at the start of current time step;
ThOLD_freztm1=zeros(NumN,IP0STmN);  % The freezing soil matric head at the start of last time step;
THH_freztm1=zeros(NumN,IP0STmN);    % The freezing soil matric head at the start of current time step;
THHKTN=zeros(1097,NumN,IP0STmN);    
%% Read MODFLOW Bottom and specific yield, storage parameters 
if IP0STmcn==1 || isempty(BOTm)
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

            %% Store working directory and subdirectory containing the files needed to run this example
            EXAMPLE_dir = pwd ;
            addpath(EXAMPLE_dir);
            load BOT_NODES.txt;
            NNK=0;
            if NPILR==1
                BOTm(1:NLAY+1,1)=BOT_NODES(NNK+1:NNK+1+(NLAY+1)-1);
                SYSTG(1:NLAY,1)=BOT_NODES(NNK+1+(NLAY+1):NNK+1+(NLAY+1)+(NLAY)-1);
                SSSTG(1:NLAY,1)=BOT_NODES(NNK+1+(NLAY+1)+(NLAY):NNK+1+(NLAY+1)+(NLAY)+(NLAY)-1);

            else
                BOTm(1:NLAY+1,1)=BOT_NODES(NNK+1:NNK+1+(NLAY+1)-1);
                SYSTG(1:NLAY,1)=BOT_NODES(NNK+1+NPILR*(NLAY+1):NNK+1+NPILR*(NLAY+1)+(NLAY)-1);
                SSSTG(1:NLAY,1)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY):NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(NLAY)-1);
                for i=2:NPILR
                    BOTm(1:NLAY+1,i)=BOT_NODES(NNK+1+(i-1)*(NLAY+1):NNK+1+i*(NLAY+1)-1);
                    SYSTG(1:NLAY,i)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+(i-1)*(NLAY):NNK+1+NPILR*(NLAY+1)+(i)*(NLAY)-1);%[1000	995	990	985	980	975	970	965	960	955	950	945	940	935	930	925	920	915	910	905	900	895	890	885	880	875	870	865	860	855	850	845	840	835	830	825	820	815	810	805	800	795	790	785	780	775	770	765	760	755	750	745	740	735	730	725	720	715	710	705	700	695	690	685	680	675	670	665	660	655	650	645	640	635	630	625	620	615	610	605	600	587.5	575	562.5	550	525	500	450	400	300	200 0]';
                    SSSTG(1:NLAY,i)=BOT_NODES(NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(i-1)*(NLAY):NNK+1+NPILR*(NLAY+1)+NPILR*(NLAY)+(i)*(NLAY)-1);
                end
            end

        end
    end
    fclose(FID);
end
save('STEMUSMODFLOW1006.mat')

[ThOLD(:,IP0STm),THH(:,IP0STm),TTOLD(:,IP0STm),TTTt(:,IP0STm),ThOLD_frez(:,IP0STm),THH_frez(:,IP0STm),RrNSTM,RrOGSTM,TIME]=MainLoop_par(IP0STm,KTN,TTIME,TTEND,HPILR1N(IP0STm),HPILR0(IP0STm),0,BOTm,SYSTG,SSSTG,ThOLDtm1(:,IP0STm),THHtm1(:,IP0STm),TTOLDtm1(:,IP0STm),TTTttm1(:,IP0STm),ThOLD_freztm1(:,IP0STm),THH_freztm1(:,IP0STm));

RrNGG(IP0STm)=RrNSTM; % the recharge water flux at the current time step, added by LY
RrOGG(IP0STm)=RrOGSTM;% the recharge water flux at the last time step, added by LY

ThOLDtm1=ThOLD;
THHtm1=THH;
TTOLDtm1=TTOLD;
TTTttm1=TTTt;
ThOLD_freztm1=ThOLD_frez;
THH_freztm1=THH_frez;
KTN
IP0STmcn=2;
THHKTN(KTN,1:NumN,1:IP0STmN)=THH(1:NumN,1:IP0STmN);