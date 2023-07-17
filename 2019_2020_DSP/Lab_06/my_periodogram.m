function my_periodogram(x) 
% This function plots the periodogram of the  
% sequence x as a function of frequency between  
% 0 and 2pi(or 0 to pi).
N = length(x);
fft_signal = fft(x);
Pxx = (1/N) .* (abs(fft_signal)).^2;
% Option plot to pi. 
w = 0:2*pi/N:(N-2)*pi/N;
plot(w, Pxx(1:N/2))
% Option plot to 2pi.
% w = 0:2*pi/N:(N-1)*2*pi/N;
% plot(w, Pxx)
end