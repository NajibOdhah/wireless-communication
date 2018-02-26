% backscattering simulation
% Table B.2.1-2 Extended Pedestrian A model (EPA) rayleigh fading channel model
% Excess tap delay[ns/10]    	Relative power[dB]
% 0  						0.0
% 50  						-3.0
% 110						-10.0
% 170						-18.0 
% 290						-26.0
% 310						-32.0


%% 该部分测试正弦信号经过rayleigh衰减信道，和经过rayleigh衰减信道后并添加部分噪声后的  
%% 信号功率的比较

clc;
clear;
close all;

f1 = 900e6;				% 信号频率900MHz,信号周期为10/9 ns
N  = 10;				% 信号周期内的采样点数
Fs = N*f1;				% sampling frequency, 采样频率
T = 1/Fs;  				% sampling period, 采样周期
L = 10000*N; 				% length of signal

t = (0:L-1)*T;			% 采样时间s，fs的值越大，出来的波形失真越小
A = 4;					% 信号幅值

%% 构造初始信号
source = A*sin(2*pi*f1*t);

%% 
[Pxx_hamming, F]= periodogram(source, hamming(length(source)),[],Fs,'centered', 'psd');
power_source = bandpower(Pxx_hamming, F, 'psd');
power_source_db = 10*log10(power_source/2)


%% 构造rayleigh信道
delay_vector = [0, 50, 110, 170, 290, 310]*1e-9; 	% Discrete delays of four-path channel (s)
gain_vector  = [0 -3.0 -10.0 -18.0 -26.0 -32.0]; 	% Average path gains (dB)			
max_Doppler_shift = 50;  					% Maximum Doppler shift of diffuse components (Hz)			
rayleigh_chan = rayleighchan(T,max_Doppler_shift,delay_vector,gain_vector);

%% 经过rayleigh信道，且将保持该信道特性
rayleigh_chan.ResetBeforeFiltering = 0;
data_after_rayleigh = filter(rayleigh_chan,source); 


%% 功率谱，并计算通过rayleigh信道后的信号功率
[Pxx_hamming_after_rayleigh, F_after_rayleigh]= periodogram(data_after_rayleigh,... 
	hamming(length(data_after_rayleigh)),[],Fs,'centered', 'psd');
power_after_rayleigh = bandpower(Pxx_hamming_after_rayleigh,...
	F_after_rayleigh, 'psd');
power_after_rayleigh_db = 10*log10(power_after_rayleigh/2)


%%************************************************************
%% 反射路径 
%% 发射因子为0.5
coeffi = 1.0;
data_backscatter = data_after_rayleigh.*coeffi;

%% 反射后，信号经过再次经过rayleigh信道
rayleigh_chan.ResetBeforeFiltering = 0;
backscatter_after_rayleigh = filter(rayleigh_chan,data_backscatter); 

%% 计算反射之后经过rayleigh信道后的信号功率
[Pxx_hamming_after_back, F_after_back]= periodogram(backscatter_after_rayleigh,...
	hamming(length(backscatter_after_rayleigh)),[],Fs,'centered', 'psd');
power_after_back = bandpower(Pxx_hamming_after_back, F_after_back, 'psd');
power_after_back_db = 10*log10(power_after_back/2)


figure;
plot(t(1:2000),real(backscatter_after_rayleigh(1:2000)));
% axis([0 inf -1.5 1.5]);
title('sine signal after channel');
xlabel(['Time(f=',num2str(f1),')'])
ylabel('Amplitude/V');

