
            %%   With 37 node-500cm Length KT=681 with 0.35/3600 Prep., while KT=708 with 0.4/3600 
%             2cm	 5cm	10cm	20cm	30cm	40cm	50cm
%               34	   31	     26	      21	     19	      17	   15
%%
%             Moni_Depth=[34 31 26 21 19 17 15];
%             Moni_Depth_SM=[26 21 19 17 15];

%             Sim_Theta(KT,1:5)=Theta_LLL(Moni_Depth_SM,1,KT);
%             Sim_Temp(KT,1:7)=TTT(Moni_Depth,KT);
            
            
            Moni_Depth=45:-1:1;
            Moni_Depth_SM=45:-1:1;
            Moni_Depth_RT=45:-1:1;


            Sim_Theta(KT,1:length(Moni_Depth_SM))=Theta_LLL(Moni_Depth_SM,1,KT);
            Sim_Temp(KT,1:length(Moni_Depth))=TTT(Moni_Depth,KT);
            if rwuef==1
                Sim_SRT(KT,1:length(Moni_Depth))=SRT(Moni_Depth,KT);
            end
           
