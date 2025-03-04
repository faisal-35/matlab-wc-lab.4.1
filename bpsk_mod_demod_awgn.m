clc; clear all; close all;

% (1) Define Binary Sequence
BINSEQ = [0 1 0 0 1 0 0 0 0 1]; % Given 10-bit sequence
number_bits = length(BINSEQ);  

% (2) BPSK Modulation Parameters
t = 0:1/100:1; % Time vector for one bit
Eb = 1;        % Bit energy
Tb = 1;        % Bit duration
nc = 4;        % Number of carrier cycles per bit
fc = nc/Tb;    % Carrier frequency
Ac = sqrt(2*Eb/Tb); % Carrier amplitude (normalized)
wc = 2*pi*fc;  % Carrier angular frequency
TX = [];       % Modulated signal storage

% (3) BPSK Modulation (Polar NRZ: 0 -> -1, 1 -> +1)
for m=1:number_bits
    if BINSEQ(m) == 1
        TX = [TX Ac*cos(wc*t)];  % BPSK: Bit "1"
    else
        TX = [TX -Ac*cos(wc*t)]; % BPSK: Bit "0" -> Phase shift by 180°
    end
end

% (a) Plot Polar NRZ and BPSK Modulated Signal
figure;
subplot(2,1,1)
stairs([BINSEQ, BINSEQ(end)], 'LineWidth', 2);
ylim([-1.5 1.5]); xlim([1 number_bits+1]);
title('(a) Polar NRZ Input Binary Sequence');
xlabel('Bit Index'); ylabel('Amplitude');
grid on;

subplot(2,1,2)
plot(1:length(TX), TX, 'b');
title('(a) BPSK Modulated Signal');
xlabel('Time Samples'); ylabel('Amplitude');
grid on;

% (4) Additive White Gaussian Noise (AWGN) Channel
snr_db = 3; % Given SNR = 3 dB
signal_power = mean(TX.^2);  % Signal power
noise_power = signal_power / (10^(snr_db/10)); % Noise power
noise = sqrt(noise_power/2) * randn(size(TX)); % AWGN noise

RX_AWGN = TX + noise; % Received signal with noise
