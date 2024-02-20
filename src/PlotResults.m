global RHOV_A Msrmn_Fitting Msr_Mois Msr_Temp Msr_Time

disp ('Convergence Achieved.')
figure;
subplot(3,3,1); plot (hhh, 'DisplayName','hhh', 'YDataSource', 'hhh'); 
subplot(3,3,2); plot(TTT, 'DisplayName','TTT', 'YDataSource', 'TTT'); 
subplot(3,3,3); plot(SUMTIME,QMT);
subplot(3,3,4); plot(SUMTIME,Evap);
subplot(3,3,5); plot(SUMTIME,Ts(1:KT));
subplot(3,3,6); plot(SUMTIME,Ta(1:KT));
subplot(3,3,7); plot(SUMTIME,U(1:KT));
subplot(3,3,8); plot(SUMTIME,HR_a(1:KT));
subplot(3,3,9); plot(SUMTIME,RHOV_A(1:KT));


if Msrmn_Fitting
    fig1=figure;
    subplot(5,1,1);plot (SUMTIME, Sim_Theta(:,1), 'r-',Msr_Time, Msr_Mois(1,:),'bo');
    subplot(5,1,2);plot (SUMTIME, Sim_Theta(:,2), 'r-',Msr_Time, Msr_Mois(2,:),'bo');
    subplot(5,1,3);plot (SUMTIME, Sim_Theta(:,3), 'r-',Msr_Time, Msr_Mois(3,:),'bo');
    subplot(5,1,4);plot (SUMTIME, Sim_Theta(:,4), 'r-',Msr_Time, Msr_Mois(4,:),'bo');
    subplot(5,1,5);plot (SUMTIME, Sim_Theta(:,5), 'r-',Msr_Time, Msr_Mois(5,:),'bo');

    fig2=figure;
    subplot(5,1,1);plot (SUMTIME, Sim_Temp(:,1), 'r-' ,Msr_Time, Msr_Temp(1,:),'bo');
    subplot(5,1,2);plot (SUMTIME, Sim_Temp(:,2), 'r-' ,Msr_Time, Msr_Temp(2,:),'bo');
    subplot(5,1,3);plot (SUMTIME, Sim_Temp(:,3), 'r-' ,Msr_Time, Msr_Temp(3,:),'bo');
    subplot(5,1,4);plot (SUMTIME, Sim_Temp(:,4), 'r-' ,Msr_Time, Msr_Temp(4,:),'bo');
    subplot(5,1,5);plot (SUMTIME, Sim_Temp(:,7), 'r-' ,Msr_Time, Msr_Temp(5,:),'bo');
end 


