function [KPILLAR]=KPILR_Cal(BOT,X,IP)
%     �����������ڵ�������������Ŷ�Ӧ
NLAY=length(BOT(:,1));
NPILLAR=length(BOT(1,:));
NumNP=length(X);
% KPILLAR=zeros(NumNP,NPILLAR);
KPILLAR=zeros(NumNP,1);

KPILLAR(1)=2;% JCZENG 20180412 ǿ�����Ӷ���λ�ڵر�
    for I=2:NumNP
        for K=2:NLAY
            Z1=BOT(K-1,IP);
            Z0=BOT(K,IP);
            ZZ=BOT(1,IP)-X(I);
            if(ZZ<=Z1 && ZZ>Z0)
                KPILLAR(I)=K;
                break%EXIT
            elseif(ZZ==Z0 && K==NLAY)
                KPILLAR(I)=K;
                break%EXIT
            end
        end
    end
