%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
% Image Filtering
%
%       ima_out = Analyse_Filter(ima,h)
%
% This function high or low pass filter an image
%     
%       ima : real input image
%       h   : filter in space domain
%   
%
% Yvan Petillot, January 2002                                  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by myself in order to see the full and different plots when this
% function is called motiple times inside a script.

function [ima_out, H_mag, f1, f2] = Analyse_Filter_test(ima,h)

% Show original image

figure;

subplot(1,3,1);
imshow(ima);
hold on;
xlabel('Original image');
drawnow;
ima = double(ima);
% Filter size generation
sx = size(h,1); 

sy = size(h,2);

% Compute fft and show result

H = zeros(256,256);

H(128-floor(sx/2):128+floor(sx/2),128-floor(sy/2):128+floor(sy/2)) = h;

FH = fftshift(fft2(fftshift(H)));

subplot(1,3,2);

imshow(log(abs(FH)+1));

xlabel('FFT magnitude display');

drawnow;

% Filter Image


ima_out = filter2(h,ima);

mini = min(min(ima_out));

maxi = max(max(ima_out));

ima_out = (ima_out-mini)/(maxi-mini);

subplot(1,3,3);

imshow(ima_out);

xlabel('Resulting filtered image');

hold off;

[H_mag, f1, f2] = freqz2(h);

figure;

freqz2(h);

xlabel('Frequency response in 3D');
hold off;

drawnow;
drawnow;