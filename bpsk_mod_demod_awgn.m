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

% (b) Plot Received BPSK Signal with AWGN
figure;
plot(1:length(RX_AWGN), RX_AWGN, 'r');
title('(b) Received BPSK Signal with AWGN (SNR = 3 dB)');
xlabel('Time Samples'); ylabel('Amplitude');
grid on;

% (5) Coherent Correlation Demodulation
LO = Ac*cos(wc*t); % Local oscillator (Reference signal)
BINSEQDET = [];    % Detected sequence storage
CS = [];           % Correlation output storage

for n = 1:number_bits
    temp = RX_AWGN((n-1)*101+1:n*101); % Extract one-bit duration
    S = sum(temp .* LO); % Correlate with local oscillator
    CS = [CS S]; % Store correlation result
    
    if S > 0
        BINSEQDET = [BINSEQDET 1]; % Detected bit "1"
    else
        BINSEQDET = [BINSEQDET 0]; % Detected bit "0"
    end
end

% (c) Plot Output of the Correlation Receiver
figure;
subplot(2,1,1)
stem(CS, 'LineWidth', 1.5);
title('(c) Output of the Coherent Correlation Receiver');
xlabel('Bit Index'); ylabel('Correlation Output');
grid on;

subplot(2,1,2)
scatter(CS, zeros(1, number_bits), 'filled');
title('(c) Signal-Space Diagram for the BPSK Signal');
xlabel('Correlation Output'); ylabel('Zero Line');
grid on;

% (d) Plot Transmitted vs Detected Binary Sequences
figure;
subplot(2,1,1)
stem(BINSEQ, 'LineWidth', 1.5, 'Marker', 'o');
title('(d) Transmitted Binary Sequence');
xlabel('Bit Index'); ylabel('Bit Value');
grid on;

subplot(2,1,2)
stem(BINSEQDET, 'LineWidth', 1.5, 'Marker', 'x');
title('(d) Detected Binary Sequence');
xlabel('Bit Index'); ylabel('Bit Value');
grid on;

% (6) Compute Bit Errors
Bit_error = sum(abs(BINSEQDET - BINSEQ));

% Display number of bit errors
disp(['Number of Bit Errors: ', num2str(Bit_error)]);

% (7) Visualize Errors in the Sequence
% Highlighting errors where transmitted bit differs from detected bit
error_indices = find(BINSEQ ~= BINSEQDET);

% Plot both sequences with highlighted errors
figure;
subplot(2,1,1);
stem(BINSEQ, 'LineWidth', 1.5, 'Marker', 'o');
hold on;
plot(error_indices, BINSEQ(error_indices), 'ro', 'MarkerFaceColor', 'r'); % Highlight errors in red
title('(e) Transmitted Binary Sequence with Errors');
xlabel('Bit Index'); ylabel('Bit Value');
grid on;

subplot(2,1,2);
stem(BINSEQDET, 'LineWidth', 1.5, 'Marker', 'x');
hold on;
plot(error_indices, BINSEQDET(error_indices), 'rx', 'MarkerFaceColor', 'r'); % Highlight errors in red
title('(e) Detected Binary Sequence with Errors');
xlabel('Bit Index'); ylabel('Bit Value');
grid on;
