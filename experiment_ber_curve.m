clc;
clear all;
close all;

Q = 3;       % num of channel taps
K = 2000;    % training sequence length
N = 50;      % filter length

num_symbols = N+Q+K-1;
num_bits = 2*num_symbols;

SNR_dB_vec = [0 5 10 15 20 25 30];

mu_nlms = 1;    % NLMS step size

nruns = 1000;

%% Monte Carlo experiment

mc_err_mmse = zeros(nruns, length(SNR_dB_vec));
mc_err_nlms = zeros(nruns, length(SNR_dB_vec));

for nn = 1:length(SNR_dB_vec)
    
    % select SNR and calc noise var
    SNR_dB = SNR_dB_vec(nn);
    SNR_lin = 10^(SNR_dB/10);
    var_noise = 1/SNR_lin;
    
    for rr = 1:nruns
        
        fprintf('point %d/%d, run %d/%d\n', nn, length(SNR_dB_vec), rr, nruns);
          
        % gen channel
        h = randn(Q, 1) + 1i*randn(Q, 1);       % channel taps
        
        % form convolution matrix
        c = zeros(N, 1); c(1) = h(1);
        r = [h.', zeros(1, N-1)];
        H = toeplitz(c, r); % (N x N + Q - 1) Toeplitz matrix
        
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
        
        % find optimal delay
        opt_delay = find_opt_channel_delay(H, var_noise);
        d_delay = S(opt_delay,:);
        b_delay = qpskgraydemod(d_delay);
        
        % compute filters' coefficients
        w_mmse  = equalizer_mmse_analytical(H, var_noise, opt_delay);
        [w_nlms, e_nlms] = equalizer_nlms(X, d_delay, mu_nlms);
        
        % get filters' output
        y_mmse = w_mmse'*X;
        y_nlms = w_nlms'*X;
        
        % demodulate filters' output
        b_mmse = qpskgraydemod(y_mmse);
        b_nlms = qpskgraydemod(y_nlms);
        
        % count errors
        mc_err_mmse(rr,nn) = sum(b_delay ~= b_mmse);
        mc_err_nlms(rr,nn) = sum(b_delay ~= b_nlms);
        
    end
    
end

ber_mmse = squeeze(sum(mc_err_mmse, 1))/(nruns*2*K);
ber_nlms = squeeze(sum(mc_err_nlms, 1))/(nruns*2*K);

%%

figure; 
semilogy(SNR_dB_vec, ber_mmse, '-x'); hold on;
semilogy(SNR_dB_vec, ber_nlms, '-o');
title(sprintf('Channel length = %d, filter length = %d', Q, N));
grid on;
xlabel('SNR [dB]');
ylabel('BER');
