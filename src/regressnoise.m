function [s_approx] = regressnoise(n_ref,x)
% REGRESSNOISE Correct a signalling measurement by accounting for
% any variations in nuclear density along the profile.
% 
% Inputs
% > n_ref: measured noise reference
% > x: measured signal + noise
% Outputs
% > s_approx: approximated pure signal (mean ~ 0)

beta = ( transpose(x)*n_ref )/( transpose(n_ref)*n_ref );

s_approx = x - beta*n_ref;

end