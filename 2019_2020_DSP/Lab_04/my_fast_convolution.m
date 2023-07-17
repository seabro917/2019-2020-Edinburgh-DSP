function output_signal = my_fast_convolution(input_signal, impulse_response)
N = length(input_signal);
K = length(impulse_response);
number_of_blocks_for_fft = floor(N/K);
final_result = zeros(number_of_blocks_for_fft, N+K-1);
for i = 1:number_of_blocks_for_fft
    final_result(i, (i-1)*K+1:(i-1)*K+1+(2*K-2)) = my_fft_convolution(input_signal((i-1)*K+1:i*K), impulse_response, 2*K-1);
end
output_signal = sum(final_result);
end

