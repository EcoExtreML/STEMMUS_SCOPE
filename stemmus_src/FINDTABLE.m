function [ZTB,ICTRL]=FINDTABLE(IP,HC,X,NUMNP)
% find the index of soil layer where the phreatic surface is
ZTB=0;
    for I=NUMNP:-1:2%找到各个虚拟柱子控制潜水面的非饱和节点编号
        HEAD1=HC(I);
        X1=X(I);
        HEAD0=HC(I-1);
        X0=X(I-1);
        if(HEAD1>-1e-5 && HEAD0<=-1E-5)   % ORI 0
            ZTB=(HEAD1*X0-HEAD0*X1)/(HEAD1-HEAD0);
            XMID=(X(I)+X(I-1))/2;
            if(ZTB>=XMID)
                ICTRL=I;
            elseif(ZTB<XMID)
                ICTRL=I-1;
            end
            break
        end
    end
% end
if(ZTB<=0)
disp('NO GROUNDWATER TABLE FOUND IN MODFLOW!');
% % if (HC(2)>0 && HC(1)>0) % modified to prevent the nan valuce of ICTRL
if min(HC)==-1E-6
    ZTB=X(2)-X(1);
    ICTRL=1;
elseif max(HC)<0
    ZTB=X(2)-X(1);
    ICTRL=1;    
end
save('ICTRRL2022.mat') 
end
end