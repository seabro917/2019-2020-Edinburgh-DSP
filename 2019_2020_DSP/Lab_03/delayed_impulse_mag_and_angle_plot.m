function delayed_impulse_mag_and_angle_plot(delay)
impulse = zeros(1, 100);
impulse(1 + delay) = 1; % Set the value at delayed point to 1. which results in a delayed impulse function.  
impulse_fft = fft(impulse);
impulse_fft_mag = abs(impulse_fft);
% omega = -49/50*pi : 1/50*pi : pi;
omega = 0:pi/50:99/50*pi; 
plot(omega, impulse_fft_mag)
impulse_fft_angle = angle(impulse_fft);
figure
plot(omega, impulse_fft_angle)
figure
unwraped_angle = unwrap(impulse_fft_angle);
plot(omega, unwraped_angle)
end

