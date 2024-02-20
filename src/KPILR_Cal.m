function [KPILLAR]=KPILR_Cal(BOT,X,IP)
%     将各个土柱节点与虚拟土柱层号对应
NLAY=length(BOT(:,1));
NPILLAR=length(BOT(1,:));
NumNP=length(X);
% KPILLAR=zeros(NumNP,NPILLAR);
KPILLAR=zeros(NumNP,1);

% for IP=1:NPILLAR
%     CALL HYDRUS1PNT(IP,IGRID)
    KPILLAR(1)=1;% JCZENG 20180412 强制柱子顶部位于地表
    %		KPILRSTMm(1)=KPILLAR(1)
    for I=2:NumNP
        for K=2:NLAY
            Z1=BOT(K-1,IP);
            Z0=BOT(K,IP);
            ZZ=BOT(1,IP)-X(I);
            if(ZZ<=Z1 && ZZ>Z0)
                KPILLAR(I)=K-1;
                %			  KPILRSTMm(I)=K
                break%EXIT
            elseif(ZZ==Z0 && K==NLAY)
                KPILLAR(I)=K-1;
                %			  KPILRSTMm(I)=K
                break%EXIT
            end
        end
    end
% end