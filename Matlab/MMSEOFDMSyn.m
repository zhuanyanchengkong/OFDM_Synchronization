function [CPStartPoint,FCO]	= MMSEOFDMSyn(data, NFFT, SNRdB)
%MMSEOFDMSYN MMSE estimation of time and frequency offset in OFDM systems
%   Detailed explanation goes here

%   Authors: Neil Judson
%   Copyright 2016 Neil Judson
%   $Revision: 1.1 $  $Date: 2016/07/29 10:45:00 $

%% 时延
dataDelay = data;
data = [dataDelay(NFFT+1:end) zeros(1,NFFT)];

%% 自相关、能量
selfMult = dataDelay .* conj(data);
dataDelayPwr = dataDelay .* conj(dataDelay);
dataPwr = data .* conj(data);
% gammaLength = length(selfMult) - 256;
gammaLength = 500;
gamma = zeros(1,gammaLength);
phi = zeros(1,gammaLength);
L = 0;
for n = 1:1:gammaLength
    gamma(n) = sum(selfMult(n:n+31+L));
    phi(n) = sum(dataDelayPwr(n:n+31+L)+dataPwr(n:n+31+L)) / 2;
end

%% 时间同步
gammaAbs = abs(gamma);
target = gammaAbs - phi;
CPStartPoint = find(target(1:500)==max(target(1:500)));

%% 小数频偏估计
FCO = -atan(imag(gamma(CPStartPoint))/real(gamma(CPStartPoint))) / 2 / pi;

end