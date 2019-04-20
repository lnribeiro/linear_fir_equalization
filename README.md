# Linear FIR Equalization

MATLAB scripts to simulate a linear and time-invariant channel with $Q$ taps to be equalized by a finite impulse response (FIR) equalizer with $N$ taps.

Three equalizers are implemented:

* MMSE filter (analytical)
* MMSE filter (sample-based)
* NLMS filter

Run ``experiment.m`` to test the equalizers and ``experiment_ber_curve.m`` to obtain the BER performance of the MMSE and NLMS filters.