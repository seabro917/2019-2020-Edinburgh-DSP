function my_Bartlett(x, K)
% Assume the length of input data is integer multiple of 1, 2, 4 and 8.
% And K only takes values: 1, 2, 4 and 8.
N = length(x);
% Length of a block
n = N/K;
% Matrix for storing all blocks.
data_blocks = zeros(K, n);
for j = 1:K
data_blocks(j, :) = x((j-1)*n+1:j*n);    
end
periodogram_temp = zeros(K, 1024);
for i = 1:K
    fft_signal = fft(data_blocks(i, :), 1024);
    periodogram_temp(i, :) = (1/n) .* (abs(fft_signal)).^2;
end
final_periodogram = 1/K .* sum(periodogram_temp);
w = 0:2*pi/1024:511*2*pi/1024;
plot(w, final_periodogram(1:512));
end

