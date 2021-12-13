global RHOV_A Msrmn_Fitting Msr_Mois Msr_Temp Msr_Time QMTT%Trap EVAP_ind TRAP_ind Sim_Theta_ind Sim_Theta EVAP_dir TRAP_dir ET_H E_D ET_D sumTRAP_dir sumEVAP_dir

disp ('Convergence Achieved.')
figure;
subplot(3,3,1); plot (hhh, 'DisplayName','hhh', 'YDataSource', 'hhh');
subplot(3,3,2); plot(TTT, 'DisplayName','TTT', 'YDataSource', 'TTT');
subplot(3,3,3); plot(SUMTIME,QMTT);
subplot(3,3,4); plot(SUMTIME,Evapo);
subplot(3,3,5); plot(SUMTIME,trap);
subplot(3,3,6); plot(SUMTIME,Ta(1:KT));
subplot(3,3,7); plot(SUMTIME,U(1:KT));
subplot(3,3,8); plot(SUMTIME,HR_a(1:KT));
subplot(3,3,9); plot(SUMTIME,RHOV_A(1:KT));

if Msrmn_Fitting
    fig1=figure;
    subplot(5,1,1);plot (SUMTIME/3600, Sim_Theta_ind(:,17), 'r-',SUMTIME/3600,Sim_Theta(:,17), 'g-',Msr_Time/3600, Msr_Mois(1,:),'b.','LineWidth',2);title('20cm');
    subplot(5,1,2);plot (SUMTIME/3600, Sim_Theta_ind(:,21), 'r-',SUMTIME/3600,Sim_Theta(:,21), 'g-',Msr_Time/3600, Msr_Mois(2,:),'b.','LineWidth',2);title('40cm');
    subplot(5,1,3);plot (SUMTIME/3600, Sim_Theta_ind(:,24), 'r-',SUMTIME/3600,Sim_Theta(:,24), 'g-',Msr_Time/3600, Msr_Mois(3,:),'b.','LineWidth',2);title('60cm');
    ylabel('Soil moisture \theta','Rotation',90)
    subplot(5,1,4);plot (SUMTIME/3600, Sim_Theta_ind(:,26), 'r-',SUMTIME/3600,Sim_Theta(:,26), 'g-',Msr_Time/3600, Msr_Mois(4,:),'b.','LineWidth',2);title('80cm');
    subplot(5,1,5);plot (SUMTIME/3600, Sim_Theta_ind(:,28), 'r-',SUMTIME/3600,Sim_Theta(:,28), 'g-',Msr_Time/3600, Msr_Mois(5,:),'b.','LineWidth',2);title('100cm');
    xlabel('Time(h)');
    legend('\thetaind','\thetadir','\thetaobs')
    fig2=figure;
    subplot(5,1,1);plot (SUMTIME/3600, Sim_Temp_ind(:,17), 'r-' ,SUMTIME/3600, Sim_Temp(:,17), 'g-' ,Msr_Time/3600, Msr_Temp(1,:),'b.','LineWidth',2);title('20cm');
    subplot(5,1,2);plot (SUMTIME/3600, Sim_Temp_ind(:,21), 'r-' ,SUMTIME/3600, Sim_Temp(:,21), 'g-' ,Msr_Time/3600, Msr_Temp(2,:),'b.','LineWidth',2);title('40cm');
    subplot(5,1,3);plot (SUMTIME/3600, Sim_Temp_ind(:,24), 'r-' ,SUMTIME/3600, Sim_Temp(:,24), 'g-' ,Msr_Time/3600, Msr_Temp(3,:),'b.','LineWidth',2);title('60cm');
    ylabel('Soil temperature T','Rotation',90)
    subplot(5,1,4);plot (SUMTIME/3600, Sim_Temp_ind(:,26), 'r-' ,SUMTIME/3600, Sim_Temp(:,26), 'g-' ,Msr_Time/3600, Msr_Temp(4,:),'b.','LineWidth',2);title('80cm');
    subplot(5,1,5);plot (SUMTIME/3600, Sim_Temp_ind(:,28), 'r-' ,SUMTIME/3600, Sim_Temp(:,28), 'g-' ,Msr_Time/3600, Msr_Temp(5,:),'b.','LineWidth',2);title('100cm');
    xlabel('Time(h)');
    legend('Tind','Tdir','Tobs')
    fig3=figure;
    plot (SUMTIME/3600, EVAP_ind+TRAP_ind, 'b-' ,SUMTIME/3600, EVAP_dir+TRAP_dir, 'r-' ,Msr_Time/3600,ET_H,'ko','LineWidth',2,'MarkerSize',5);
    xlabel('Time(h)');
    ylabel('EvapoTranspiration ET(mm)','Rotation',90);
    legend('ETind','ETdir','ETobs','Location','best')
    fig4=figure;
    subplot(2,1,1);plot (175:275, sumEVAP_ind+sumTRAP_ind, 'b-' ,175:275, sumEVAP_dir+sumTRAP_dir, 'r-' ,175:275,ET_D(1:101),'ko','LineWidth',2,'MarkerSize',5);
    xlabel('DOY');
    ylabel('EvapoTranspiration ET(mm)','Rotation',90);
    legend('ETind','ETdir','ETobs','Location','best')
    subplot(2,1,2);plot (175:275, sumEVAP_ind, 'b-' ,175:275, sumEVAP_dir, 'r-' ,175:275,E_D(1:101),'ko','LineWidth',2,'MarkerSize',5);
    xlabel('DOY');
    ylabel('Evaporation E(mm)','Rotation',90);
    legend('Eind','Edir','Eobs','Location','best')
end