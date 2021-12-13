function [sfactor] = calc_sfactor(Rl,Theta_s,Theta_r,Theta_LL,bbx,wfrac)
SMC=Theta_LL(:,1); % soil surface moisture
nn=numel(SMC);
for i=1:nn
        wfrac(i)=1/(1+exp((-100*Theta_s)*(SMC(i)-(0.24+Theta_r)/2)));
 end
wfrac=wfrac.*bbx;

RL=Rl.*bbx;
RLfrac=RL./(sum(sum(RL)));
sfactor=sum(sum(RLfrac.*wfrac));
end

