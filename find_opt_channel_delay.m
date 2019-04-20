function delay = find_opt_channel_delay( H, var_noise )

N = size(H, 1);

Rxx = H*H' + var_noise*eye(N);
C = (H')*(Rxx \ H);
c = abs(diag(C));

[~, delay] = max(c);

end