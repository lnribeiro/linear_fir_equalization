function [ bitstream ] = qpskgraydemod( qpsksig )

% https://www.mathworks.com/matlabcentral/fileexchange/30697-ber-curve-for-qpsk-in-rayleigh-channel?focused=5180249&tab=function

    B4 = (real(qpsksig)<0);
    B3 = (imag(qpsksig)<0);
        
    bitstream = zeros(2*length(qpsksig),1);
    bitstream(1:2:end) = B3;
    bitstream(2:2:end) = B4;

end

