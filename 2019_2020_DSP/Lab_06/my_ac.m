function res_ac_final =  my_ac(x, T)
% 
% This function calculates the autocorrelation function of  
% the real valued sequence x and then plots it against the  
% sample delay between -T and T
N = length(x);
res_ac_temp = zeros(1, T+1); 
for k = 0:T % Outter loop for different ACS value(of length 2T). 
    summation_temp = zeros(1, N-abs(k));
    for i = 0:(N-abs(k)-1)   % Inner loop through all possible n under k.
        summation_temp(i+1) = (1/N) * (x(i+1)*x(i+k+1));
    end
    res_ac_temp(k+1) = sum(summation_temp);
end

% Since ACF is symeetric for a real sgnal.
res_ac_final = zeros(1, 2*T+1);
temp = res_ac_temp(end:-1:2);
res_ac_final(1:T) = temp;
res_ac_final(T+1:end) = res_ac_temp;
% stem(res_ac_final, -T:T);
stem(-T:T, res_ac_final);
end