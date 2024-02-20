function Dtrmn_Z
%  The determination of the element length
global Elmn_Lnth ML DeltZ NL Tot_Depth DeltZ_R MML 

Elmn_Lnth=0;
NL=35;
DeltZ=zeros(1,NL);
for ML=1:30
    DeltZ_R(ML)=10;
end
%     DeltZ_R(3)=3;

for ML=31:NL
    DeltZ_R(ML)=40;
end
for ML=1:NL
    MML=NL-ML+1;
    DeltZ(ML)=DeltZ_R(MML);
end
%         NL=18;
        
% for ML=1:2
%     DeltZ_R(ML)=0.25;
% end
%     DeltZ_R(3)=0.5;
%     
% for ML=4:12
%     DeltZ_R(ML)=1;
% end
% 
% for ML=13:17
%     DeltZ_R(ML)=2;
% end
% 
% for ML=18:23
%     DeltZ_R(ML)=5;
% end
% % Sum of element lengths and compared to the total lenght, so that judge 
% % can be made to determine the length of rest elements.
% 
% for ML=1:23
%     Elmn_Lnth=Elmn_Lnth+DeltZ_R(ML);
% end
% 
% % If the total sum of element lenth is over the predefined depth, stop the
% % for loop, make the ML, at which the element lenth sumtion is over defined
% % depth, to be new NL.
% for ML=24:30
%     DeltZ_R(ML)=20;
%     Elmn_Lnth=Elmn_Lnth+DeltZ_R(ML);
%     if Elmn_Lnth>Tot_Depth
%         DeltZ_R(ML)=Tot_Depth-Elmn_Lnth+DeltZ_R(ML);
%         NL=ML;
% 
%         for ML=1:NL
%             MML=NL-ML+1;
%             DeltZ(ML)=DeltZ_R(MML);
%         end        
%         return
%     elseif Elmn_Lnth<Tot_Depth && ML==NL
%         NL=NL+NL*2;
%     end
% end
% 
% DeltZ_R(31)=40;
% Elmn_Lnth=Elmn_Lnth+DeltZ_R(31);
% if Elmn_Lnth>Tot_Depth
%     DeltZ_R(31)=Tot_Depth-Elmn_Lnth+DeltZ_R(31);
%     NL=31;
% 
%     for ML=1:NL
%         MML=NL-ML+1;
%         DeltZ(ML)=DeltZ_R(MML);
%     end
%     return
% elseif Elmn_Lnth<Tot_Depth
%     NL=NL*2;
% end
%     
% for ML=32:NL
%     DeltZ_R(ML)=50;
%     Elmn_Lnth=Elmn_Lnth+DeltZ_R(ML);
%     if Elmn_Lnth>Tot_Depth
%         DeltZ_R(ML)=Tot_Depth-Elmn_Lnth+DeltZ_R(ML);
%         NL=ML;
%         
%         for ML=1:NL
%             MML=NL-ML+1;
%             DeltZ(ML)=DeltZ_R(MML);
%         end
%         return
%     end
% end





        