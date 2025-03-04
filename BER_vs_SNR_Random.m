clc;
clear;
close all;

% Parameters
M = 8;                      % Modulation order (8-PSK)
bps = log2(M);              % Bits per symbol
numBits = 1e5;              % Total number of bits to transmit

% Generate random input bits
inputBits = randi([0 1], numBits, 1);

% Ensure the total number of bits is divisible by bps
remainder = mod(numBits, bps);
if remainder ~= 0
    paddingBits = zeros(bps - remainder, 1);  % Add zeros as padding
    inputBits = [inputBits; paddingBits];     % Append padding bits
end

% Group bits into symbols
reshapedBits = reshape(inputBits, [], bps);   % Reshape bits into groups of 'bps'
symbolIndices = bi2de(reshapedBits, 'left-msb'); % Convert groups of bits to decimal indices

% 8-PSK Modulation
txSymbols = pskmod(symbolIndices, M, pi/M); % pi/M phase offset for standard 8-PSK

% SNR Range
SNR_dB = 0:15;               % SNR values in dB
BER = zeros(size(SNR_dB));   % Preallocate BER vector

% Loop over SNR values
for idx = 1:length(SNR_dB)
    % Add AWGN noise to the transmitted symbols
    rxSymbols = awgn(txSymbols, SNR_dB(idx), 'measured');
    
    % Demodulation
    rxSymbolIndices = pskdemod(rxSymbols, M, pi/M); % Use same phase offset
    
    % Convert symbols back to bits
    rxBits = de2bi(rxSymbolIndices, bps, 'left-msb'); 
    rxBits = reshape(rxBits', [], 1);  % Reshape back to column vector
    
    % Calculate Bit Error Rate (BER)
    [~, BER(idx)] = biterr(inputBits, rxBits);
end

% Plot SNR vs BER
figure;
semilogy(SNR_dB, BER, 'o-', 'LineWidth', 1.5);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('SNR vs BER for 8-PSK Modulation');
