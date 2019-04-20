function [ qpsksig ] = qpskgraymod( bitstream )

% https://www.mathworks.com/matlabcentral/fileexchange/30697-ber-curve-for-qpsk-in-rayleigh-channel?focused=5180249&tab=function

% imaginary part (Q channel)
%         ^
%         |
%  10 x   |   x 00   (odd bit, even bit)
%         |
%  -------+------->  real part (I channel)
%         |
%  11 x   |   x 01
%         |

        % Split the stream into two streams, for Quadrature Carriers
        B1 = bitstream(1:2:end);
        B2 = bitstream(2:2:end);
        
        % QPSK modulator set to pi/4 radians constellation
        % If you want to change the constellation angles
        % just change the angles. (Gray Coding)
        qpsksig = ((B1==0).*(B2==0)*(exp(1i*pi/4))+ ...
                   (B1==0).*(B2==1)*(exp(3*1i*pi/4))+ ...
                   (B1==1).*(B2==1)*(exp(5*1i*pi/4))+ ...
                   (B1==1).*(B2==0)*(exp(7*1i*pi/4)) ...
                   ); 

end

