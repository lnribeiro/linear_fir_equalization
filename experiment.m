clc;
clear all;
close all;

Q = 3;       % num of channel taps
K = 2000;    % training sequence length
N = 50;      % filter length

num_symbols = N+Q+K-1;
num_bits = 2*num_symbols;

SNR_dB = 20;
SNR_lin = 10^(SNR_dB/10);
var_noise = 1/SNR_lin;

mu_nlms = 1;    % NLMS step size

%% generate channel

h = randn(Q, 1) + 1i*randn(Q, 1);       % channel taps

% form convolution matrix
c = zeros(N, 1); c(1) = h(1);
r = [h.', zeros(1, N-1)];
H = toeplitz(c, r); % (N x N + Q - 1) Toeplitz matrix

%% gen signals

% gen bitstream
b = randi([0 1], num_bits, 1);

% modulate bitstream
s = qpskgraymod(b);

% prepare for convolution
S = zeros(N+Q-1, K);
aux = 1;
for kk = N+Q-1:N+Q-2+K
    sk = s(kk:-1:kk-N-Q+2);
    S(:,aux) = sk;
    aux = aux + 1;
end

% AWGN
B = sqrt(var_noise)*(1/sqrt(2))*(randn(N, K) + 1i*randn(N, K));

% observed signal
X = H*S + B;

%% equalization

% find optimal delay
opt_delay = find_opt_channel_delay(H, var_noise);
d_delay = S(opt_delay,:);
b_delay = qpskgraydemod(d_delay);

% compute filters' coefficients
w_mmse  = equalizer_mmse_analytical(H, var_noise, opt_delay);
w_mmse_sample = equalizer_mmse_sample(X, d_delay);
[w_nlms, e_nlms] = equalizer_nlms(X, d_delay, mu_nlms);

% get filters' output
y_mmse = w_mmse'*X;
y_mmse_sample = w_mmse_sample'*X;
y_nlms = w_nlms'*X;

% demodulate filters' output
b_mmse = qpskgraydemod(y_mmse);
b_mmse_sample = qpskgraydemod(y_mmse_sample);
b_nlms = qpskgraydemod(y_nlms);

%% count errors

mse_mmse = norm(d_delay-y_mmse)^2/K
mse_mmse_sample = norm(d_delay-y_mmse_sample)^2/K
mse_nlms = norm(d_delay-y_nlms)^2/K

ber_mmse = sum(b_delay ~= b_mmse)/length(b_mmse)
ber_mmse_sample = sum(b_delay ~= b_mmse_sample)/length(b_mmse_sample)
ber_nlms = sum(b_delay ~= b_nlms)/length(b_nlms)

%% plot results

figure; hold on;
plot(y_nlms, 'd');
plot(y_mmse, 'o');
plot(y_mmse_sample, 'x');
xlabel('In-phase');
ylabel('Quadrature');
legend('NLMS','MMSE','MMSE Sample');
grid on;

figure;
semilogy(abs(e_nlms));
xlabel('Iterations');
ylabel('MSE');
grid on;
title('NLMS learning curve');