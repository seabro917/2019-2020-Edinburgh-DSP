function fmagplot_02(x, dt)
Xw = fft(x);
L = length(x);
range = 0:L/2;
ff = range/L/dt;
plot(ff,mag2db(abs(Xw(1+range))));
xlabel('Frequency(Hz)');
ylabel('Magnitiude of the FFT(dB)');
end