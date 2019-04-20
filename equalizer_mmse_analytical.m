function w  = equalizer_mmse_analytical( H, var_noise, delay )

[N, L] = size(H);

Rxx = H*H' + var_noise*eye(N);
uni = zeros(L, 1); uni(delay) = 1;
p = H*uni;

w = Rxx \ p;

end