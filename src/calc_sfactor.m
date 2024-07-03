function [sfactor] = calc_sfactor(Rl, Theta_s, Theta_r, Theta_LL, bbx, Ta, Theta_f)
    SMC = Theta_LL(1:end - 1, 1); % soil surface moisture
    wfrac = 1 ./ (1 + exp((-100 .* Theta_s') .* (SMC - (Theta_f' + Theta_r') / 2))) .* bbx; % The soil water stress factor in each layer
    RL = Rl .* bbx;
    RLfrac = RL ./ (sum(sum(RL))); % root fraction in each layer
    sfactor = sum(sum(RLfrac .* wfrac)); % Total soil water stress factor
end
