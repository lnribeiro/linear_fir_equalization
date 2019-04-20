function w = equalizer_mmse_sample(X, d)

K = size(X, 2);

Rxx = (1/K)*(X)*(X');
Pdx = (1/K)*(X)*conj(d.');

w = Rxx\Pdx;

end