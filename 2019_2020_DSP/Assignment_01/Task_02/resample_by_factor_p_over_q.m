function [output_signal] = resample_by_factor_p_over_q(input_signal, p, q)
% Output:
%       output_signal: The signal after being resampled.
% Input:
%       input_signal: Data for the input signal.
%       p: The sampling frequency that we want to resample to, in kHz.
%       q: The sampling frequency for the input signal, in kHz.
% This function will resample the signal of qkHz with duration 1 second to
% pkHz with duration 1 second.
% Note that this the anti-aliasing operation in this function only applies
% to the signal whose highest frequency component does not exceed 2kHz,
% since in this assignment, both the original signal and the signal after
% being convolved satisfies this condition, this function is applicable to
% these signals.
% Author: Yuchen MU
% Last modified date: 10/10/19

% Since the required sampling frequency after doing up sampling is not a
% integral multiple of the original sampling frequency, we have to firt do
% the up sampling, then do the down sampling. Meaning, first do upsampling by
% p times, then down sample by q times.

% Interleave the signal with zeros.
signal_interleave_with_zeros = zeros(1, q*1000*p);
index = 1;
for i = 1:q*1000*p
    if mod(i, p) == 1
        signal_interleave_with_zeros(i) = input_signal(index);
        index = index + 1;
    end
end
% Plot the signal in frequency domain after interleaving zeros.
fft_for_signal_interleave_with_zeros = fft(signal_interleave_with_zeros);
f = 0:(q*1000*p)-1;
figure
plot(f, abs(fft_for_signal_interleave_with_zeros));
xlabel('Frequency (Hz)');
ylabel('Magnitude of the transform');
title('Fourier transform of the signal after interleaving with zeros');
xlim([0 q*1000*p]);
hold off;
% As we can see in the frequency domain, the transform of the upsampling
% samples are the copies of the original samples, this means that the
% transform of the original samples was "compressed" within (0, 2*pi),
% where 2*pi denotes the sampling frequency, and since we upsample the
% original samples by a factor of p, from 0 to 2*pi in the frequency
% domain, it contains 8 copies of the original transform. And the transform
% from 0 to 2500Hz will contain all information about the original signal,
% thus, we filter this spectrum up to 2.5kHz.
% We also filter out these frequency components to avoid aliasing.

% Here in order to make sure that after doing inverse transform, we
% still have the same signal amplitude as the signal before doing
% upsampling, we multiply the amplitude of the fourier transform for the
% upsampling signal by a factor of 2*p.
fft_for_upsampling_after_filtering=  [2*p*fft_for_signal_interleave_with_zeros(1:2501), zeros(1, q*1000*p-2501)];
% Since for this transfrom we have 0 padding, the inverse transform is of
% complex number, we take the real part of these complex numbers to get the
% signal in time domain.
signal_after_upsampling = real(ifft(fft_for_upsampling_after_filtering)); 

% Decimation operation
signal_after_downsampling = zeros(1, p*1000);
index = 1;
for i = 1:q*1000*p
    if mod(i, q) == 1
        signal_after_downsampling(index) = signal_after_upsampling(i);
        index = index + 1;
    end
end
% Plot the downsampled signal in time domain.
k = 0:(1000*p)-1;
figure
subplot(2,1,1);
stem(k, signal_after_downsampling);
xlabel('n');
ylabel('x(n)');
title(['Signal sampled at ' , int2str(p), 'kHz in time domain']);
xlim([0 p*(10^3)]);
% Plot the downsampled signal in frequency domain.
fft_for_signal_after_downsampling_ = fft(signal_after_downsampling);
subplot(2,1,2);
plot(k, abs(fft_for_signal_after_downsampling_));
xlabel('Frequency (Hz)');
ylabel('Magnitude of the transform');
title(['Fourier transform of the signal sampled at ', int2str(p), 'kHz']);
xlim([0 p*(10^3)]);
% soundsc(signal_after_downsampling);
output_signal = signal_after_downsampling;


end

