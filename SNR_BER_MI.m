clc  
clear all  
close all  

% bps  
M = 8;  
bps = log2(M);  

% input + reshape  
nosymbol = 600;  
symbols = randint(1,nosymbol,256);  

%  
symbolToBitMapping = de2bi(symbols,8,'left-msb');  

txt1 = 'Information and communication engineering';  
symbols = double(txt1);  
symbolToBitMapping = de2bi(symbols,8,'left-msb');  

totNoBits = numel(symbolToBitMapping);  
inputReshapedBits = reshape(symbolToBitMapping,1,totNoBits);  

% padding  
remainder = rem(totNoBits,bps);  
if(remainder == 0)  
    userPaddedData = inputReshapedBits;  
else  
    paddingBits = zeros(1, bps - remainder);  
    userPaddedData = [inputReshapedBits paddingBits];  
end  

% modulation  
reshapedUserPaddedData = reshape(userPaddedData, numel(userPaddedData)/bps, bps);  
bitToSymbolMapping = bi2de(reshapedUserPaddedData, 'left-msb');  
modulatedSymbol = pskmod(bitToSymbolMapping, M);  

% channel  
SNR = [];  
BER = [];  

for snr = 6:15  
    SNR = [SNR snr];  
    noisySymbols = awgn(modulatedSymbol, snr, 'measured');  
    demodulatedSymbol = pskdemod(noisySymbols,M);  

    %original data  
    demodulatedSymbolToBitMapping = de2bi(demodulatedSymbol,'left-msb');  
    reshapedDemodulatedBits = reshape(demodulatedSymbolToBitMapping, 1, numel(demodulatedSymbolToBitMapping));  

    %remove padding  
    demodulatedBitsWithoutPadding = reshapedDemodulatedBits(1: totNoBits);  

    [noe ber] = biterr(inputReshapedBits, demodulatedBitsWithoutPadding);  
    BER = [BER ber];  

    %Original Text  
    txtBits = reshape(demodulatedBitsWithoutPadding, numel(demodulatedBitsWithoutPadding)/8,8);  
    txtBitsDecimal = bi2de(txtBits, 'left-msb');  
    msg = char(txtBitsDecimal)'  
end  

figure(1)  
semilogy(SNR, BER, '--');  
xlabel('SNR');  
ylabel('BER');  
title('SNR VS BER');  
