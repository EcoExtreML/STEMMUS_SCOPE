function [ZTB,ICTRL]=FINDTABLE(IP,HC,X,NUMNP)
% USE Q3DMODULE,ONLY:BOT
% USE HYDRUS,ONLY:X,NUMNP
% INTEGER ICTRL,IP
% DOUBLEPRECISION HEAD1,HEAD0,XMID,HCHILD,X0,X1
% DOUBLEPRECISION ZTB, ZTB,HC
% DIMENSION HC(NUMNP)
ZTB=0;
% ICTRL=NUMNP-2;% Prevent the nan value of ICTRL
for I=NUMNP:-1:2%找到各个虚拟柱子控制潜水面的非饱和节点编号
    HEAD1=HC(I);
    X1=X(I);
    HEAD0=HC(I-1);
    X0=X(I-1);
    if(HEAD1>0 && HEAD0<=0)
        ZTB=(HEAD1*X0-HEAD0*X1)/(HEAD1-HEAD0);
        XMID=(X(I)+X(I-1))/2;
        if(ZTB>=XMID)
            ICTRL=I;
        elseif(ZTB<XMID)
            ICTRL=I-1;
        end
%         break
    end
end
if(ZTB<=0),disp('NO GROUNDWATER TABLE FOUND IN MODFLOW!');end

% return
end