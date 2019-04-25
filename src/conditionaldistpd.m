function h = conditionaldistpd(data,given,tol)
%CONDITIONALDISTPD Create a probability density plot for a conditional
%distribution.
% Inputs:
%   > data: 
%   > given: given value of dependent variable
%   > tol: tolerance for given

% Use histogram(in,'Normalization','Probability')

nX = size(data,1);

% Sort dependent variable from low to high, associate each array with a
% correspondingly sorted independent variable.

% Look through each independent variable value. If it falls in given +/-
% tol, save value and position.

end

