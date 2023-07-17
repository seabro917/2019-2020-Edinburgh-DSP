function output_signal = my_fft_convolution(x, h, P)
x_padded = zeros(P,1);
x_padded(1:length(x)) = x; 
h_padded = zeros(P,1); 
h_padded(1:length(h)) = h; 
Fx = fft(x_padded); 
Fh = fft(h_padded);
 % note the use of element-wise multiplication 
% we need to take the real part to avoid any       
% floating point errors making the output complex 
Fy = Fx.*Fh;  
output_signal = real(ifft(Fy));             
end

