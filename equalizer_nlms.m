function [w, e] = equalizer_nlms(X, d, mu)

N = size(X, 1);

K = size(X,2);
w = zeros(N,1); w(1) = 1;
e = zeros(K,1);
for kk = 1:K
    e(kk) = d(kk) - w'*X(:,kk);
    w = w + mu*conj(e(kk))*X(:,kk)/norm(X(:,kk))^2;
end

end