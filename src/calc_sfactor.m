function [sfactor] = calc_sfactor(Rl,Theta_s,Theta_r,Theta_LL,bbx,Ta,Theta_f)
SMC=Theta_LL(1:54,1); % soil surface moisture 顺序相反
wfrac=1./(1+exp((-100.*Theta_s').*(SMC-(Theta_f'+Theta_r')/2))).*bbx; %各层土壤的水分胁迫系数
RL=Rl.*bbx;
RLfrac=RL./(sum(sum(RL))); %各层土壤的根长密度占比
sfactor=sum(sum(RLfrac.*wfrac)); %总体水分胁迫系数    
end
