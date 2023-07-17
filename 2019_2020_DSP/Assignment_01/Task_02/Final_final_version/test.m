clear all;
close all;
clc;
f = 200; % Signal fundamental frequency of 200Hz.
fs= 5000; % Sampling frequency of 5kHz.
N = 5000; % Since duration of the signal is 1s, and fs=5kHz, we need 5000 samples.
n = 0:N-1;
T= 1/fs; % Sample period.
x = zeros(10,5000); % Matrix for the whole signal
for i = 1:10
    x(i,:) = cos(2*pi*i*f*n*T);
end
signal_superposition = sum(x, 1);
% Plot the original signal in time domain.
subplot(2,1,1);
stem(n, signal_superposition);
xlabel('n');
ylabel('x(n)');
title('Signal sampled at 5kHz in time domain');
% Plot the original signal in frequency domain.
fft_for_signal = fft(signal_superposition);
f = 0:4999;
subplot(2,1,2);
plot(f, abs(fft_for_signal));
xlabel('frequency (Hz)');
ylabel('Magnitude of the transform');
title('Signal sampled at 5kHz in frequency domain');
hold off;
% Read the audio file into workspace.
[samples_of_the_wav_file, fs_of_wav_file] = audioread('telephoneIR.wav');

% First in order to do convolution operation to original signal and filter,
% we have to make their sampling frequency identical, thus resampling the
% original signal to 22kHz, which is the sampling frequency of the samples
% in .wav file.
signal_after_resample_22kHz = resample_by_factor_p_over_q(signal_superposition, 22, 5);
% Convolve the resampled signal with the .wav samples in time domain.
signal_after_conv_with_wav_22kHz = conv(signal_after_resample_22kHz, samples_of_the_wav_file','same');
% Plot the convolved signal in frequency domain.
fft_for_convolved_signal_22kHz = fft(signal_after_conv_with_wav_22kHz);
figure
k = 0:21999;
plot(k, abs(fft_for_convolved_signal_22kHz));
xlabel('frequency (Hz)');
ylabel('Magnitude of the transform');
title('Signal after convolution sampled at 22kHz');
xlim([0 22000]);
hold off;
% Resample the convolved signal to sampling frequency of 8kHz.
final_signal_resample_to_8kHz = resample_by_factor_p_over_q(signal_after_conv_with_wav_22kHz, 8, 22);

% Compare the final result returned by my function with the result returned
% by MATLAB built-in 'resample' function, to show the success of my method.
MATLAB_signal_22kHz = resample(signal_superposition, 22, 5);
MATLAB_convolved_signal_22kHz = conv(MATLAB_signal_22kHz, samples_of_the_wav_file, 'same');
MATLAB_final_convolved_signal_8kHz = resample(MATLAB_convolved_signal_22kHz, 8, 22);

% The result returned by my function.
figure
subplot(3,1,1);
k = 0:7999;
plot(k, abs(fft(final_signal_resample_to_8kHz)));
xlabel('frequency (Hz)');
ylabel('Magnitude');
title('Fourier transform of the final result by my function');
hold on;

% The result returned by MATLAB buil-in function.
subplot(3,1,2);
plot(k, abs(fft(MATLAB_final_convolved_signal_8kHz)));
xlabel('frequency (Hz)');
ylabel('Magnitude');
title('Fourier transform of the final result by matlab built-in resample function');

% Difference between these two results in time domain.
subplot(3,1,3);
plot(k, final_signal_resample_to_8kHz - MATLAB_final_convolved_signal_8kHz);
xlabel('n');
ylabel('Difference of x[n]');
title('Difference between the result of my function and matlab built-in function');

function [output_signal] = resample_by_factor_p_over_q(input_signal, p, q)
% Output:
%       output_signal: The signal after being resampled.
% Input:
%       input_signal: Data for the input signal.
%       p: Integer, the sampling frequency that we want to resample to, in kHz.
%       q: Integer, the sampling frequency for the input signal, in kHz.
% This function will resample the signal of qkHz with duration 1 second to
% pkHz with duration 1 second.
% The anti-aliasing operation is done with a rectangular window, which
% corresponds to a sinc function in time domain, I also truncated sinc
% function based on different resampling needs.
% Author: Yuchen MU
% Last modified date: 15/10/19

% ----------------------------------------------------------------
% Up-sampling part
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

% ----------------------------------------------------------------
% Anti-aliasing part
% There are p copies of the original signal in the frequency domain, we
% have to filter out the frequency components higher than half of the
% original sampling frequency, i.e., ((q*1000)/2)Hz.
% Filtering operation, assuming rectangular window is used.
% Adapative length of the sinc function, based on different resampling needs.
N_for_sinc = (p*q*1000)/50;
t = -(N_for_sinc/2)*(1/(p*q*1000)):(1/(p*q*1000)):(N_for_sinc/2)*(1/(p*q*1000));
% Filter out frequency component higher than half of the original sampling
% frequency, i.e., ((q*1000)/2)Hz.
filter_sinc = sinc(q*1000*t);
% Convolve in time domain.
signal_after_filtering = conv(signal_interleave_with_zeros, filter_sinc, 'same');
% Plot the signal in frequency domain after being filtered.
figure
k = 0:(q*p*1000)-1;
fft_after_conv = fft(signal_after_filtering);
plot(k, abs(fft_after_conv));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Fourier transform of the signal after being filtered');
xlim([0 p*q*1000]);

% ----------------------------------------------------------------
% Down-sampling part
% Decimation operation
signal_after_downsampling = zeros(1, p*1000);
index = 1;
for i = 1:q*1000*p
    if mod(i, q) == 1
        signal_after_downsampling(index) = signal_after_filtering(i);
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
