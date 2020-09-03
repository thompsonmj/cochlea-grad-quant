function vq = makima(x,v,xq)
%% Modified Akima Piecewise Cubic Hermite Interpolation Code
% Source: https://blogs.mathworks.com/cleve/2019/04/29/makima-piecewise-cubic-interpolation/
% Copied 2020-01-14
% Comes standard with R2019b
%MAKIMA   Modified Akima piecewise cubic Hermite interpolation.
%
%       We modify Akima's formula to eliminate overshoot and undershoot
%       when the data is constant for more than two consecutive nodes.
%
%   vq = MAKIMA(x,v,xq) interpolates the data (x,v) at the query points xq
%   using a modified Akima cubic Hermite interpolation formula.
%
%   References:
%
%       H. Akima, "A New Method of Interpolation and Smooth Curve Fitting
%       Based on Local Procedures", JACM, v. 17-4, p.589-602, 1970.
%
%   MAKIMA vs. PCHIP vs. SPLINE:
%
%     - MAKIMA is a middle ground between SPLINE and PCHIP:
%       It has lower-amplitude wiggles than SPLINE, but is not as agressive
%       at reducing the wiggles as PCHIP.
%     - MAKIMA and SPLINE generalize to n-D grids.
%
%   Example: No overshoot and undershoot with MAKIMA when the data is
%            constant for more than two consecutive nodes
%
%       x = 1:7;
%       v = [-1 -1 -1 0 1 1 1];
%       xq = 0.75:0.05:7.25;
%       vqs = spline(x,v,xq);
%       vqp = pchip(x,v,xq);
%       vqa = akima(x,v,xq);
%       vqm = makima(x,v,xq);
%
%       figure
%       plot(x,v,'ko','LineWidth',2,'MarkerSize',10), hold on
%       plot(xq,vqp,'LineWidth',4)
%       plot(xq,vqs,xq,vqa,xq,vqm,'LineWidth',2)
%       legend('Data','''pchip''','''spline''','Akima''s formula',...
%           '''makima''','Location','SE')
%       title('''makima'' has no overshoot in x(1:3) and x(5:7)')
%
%   Example: Compare MAKIMA with AKIMA, SPLINE, and PCHIP
%
%       x = [1 2 3 4 5 5.5 7 8 9 9.5 10];
%       v = [0 0 0 0.5 0.4 1.2 1.2 0.1 0 0.3 0.6];
%       xq = 0.75:0.05:10.25;
%       vqs = spline(x,v,xq);
%       vqp = pchip(x,v,xq);
%       vqa = akima(x,v,xq);
%       vqm = makima(x,v,xq);
%
%       figure
%       plot(x,v,'ko','LineWidth',2,'MarkerSize',10), hold on
%       plot(xq,vqp,'LineWidth',4)
%       plot(xq,vqs,xq,vqa,xq,vqm,'--','LineWidth',2)
%       legend('Data','''pchip''','''spline''','Akima''s formula','''makima''')
%       title('Cubic Hermite interpolation in MATLAB')
%
%   See also AKIMA, SPLINE, PCHIP.


%   mailto: cosmin.ionita@mathworks.com

    assert(isvector(x) && isvector(v) && (numel(x) == numel(v)))
    assert(numel(x) > 2)
    x = x(:).'; v = v(:).'; % Same shapes as in pchip.m and spline.m

% Compute modified Akima slopes
    h = diff(x);
    delta = diff(v)./h;
    slopes = makimaSlopes(delta);

% Evaluate the piecewise cubic Hermite interpolant
    vq = ppval(pwch(x,v,slopes,h,delta),xq);

end

function compareCubicPlots(x,v,xq,showMakima,legendLocation)
% Plot 'pchip', 'spline', Akima, and 'makima' interpolation results
    vqp = pchip(x,v,xq);      % same as vq = interp1(x,v,xq,'pchip')
    vqs = spline(x,v,xq);     % same as vq = interp1(x,v,xq,'spline')
    vqa = akima(x,v,xq);
    if showMakima
        vqm = makima(x,v,xq); % same as vq = interp1(x,v,xq,'makima')
    end

    plot(x,v,'ko','LineWidth',2,'MarkerSize',10,'DisplayName','Input data')
    hold on
    plot(xq,vqp,'LineWidth',4,'DisplayName','''pchip''')
    plot(xq,vqs,'LineWidth',2,'DisplayName','''spline''')
    plot(xq,vqa,'LineWidth',2,'DisplayName','Akima''s formula')
    if showMakima
        plot(xq,vqm,'--','Color',[0 3/4 0],'LineWidth',2, ...
            'DisplayName','''makima''')
    end
    hold off
    xticks(x(1)-1:x(end)+1)
    legend('Location',legendLocation)
    title('Cubic Hermite interpolation')
end

function vq = akima(x,v,xq)
%AKIMA   Akima piecewise cubic Hermite interpolation.
%
%   vq = AKIMA(x,v,xq) interpolates the data (x,v) at the query points xq
%   using Akima's cubic Hermite interpolation formula.
%
%   References:
%
%       H. Akima, "A New Method of Interpolation and Smooth Curve Fitting
%       Based on Local Procedures", JACM, v. 17-4, p.589-602, 1970.
%
%   AKIMA vs. PCHIP vs. SPLINE:
%
%     - Akima's cubic formula is a middle ground between SPLINE and PCHIP:
%       It has lower-amplitude wiggles than SPLINE, but is not as agressive
%       at reducing the wiggles as PCHIP.
%     - Akima's cubic formula and SPLINE generalize to n-D grids.
%
%   Example: Compare AKIMA with MAKIMA, SPLINE, and PCHIP
%
%       x = [1 2 3 4 5 5.5 7 8 9 9.5 10];
%       v = [0 0 0 0.5 0.4 1.2 1.2 0.1 0 0.3 0.6];
%       xq = 0.75:0.05:10.25;
%       vqs = spline(x,v,xq);
%       vqp = pchip(x,v,xq);
%       vqa = akima(x,v,xq);
%       vqm = makima(x,v,xq);
%
%       figure
%       plot(x,v,'ko','LineWidth',2,'MarkerSize',10), hold on
%       plot(xq,vqp,'LineWidth',4)
%       plot(xq,vqs,xq,vqa,xq,vqm,'--','LineWidth',2)
%       legend('Data','''pchip''','''spline''','Akima''s formula','''makima''')
%       title('Cubic Hermite interpolation in MATLAB')
%
%   See also MAKIMA, SPLINE, PCHIP.


%   mailto: cosmin.ionita@mathworks.com

    assert(isvector(x) && isvector(v) && (numel(x) == numel(v)))
    assert(numel(x) > 2)
    x = x(:).'; v = v(:).'; % Same shapes as in pchip.m and spline.m

    % Compute Akima slopes
    h = diff(x);
    delta = diff(v)./h;
    slopes = akimaSlopes(delta);

    % Evaluate the piecewise cubic Hermite interpolant
    vq = ppval(pwch(x,v,slopes,h,delta),xq);
end

function s = akimaSlopes(delta)
% Derivative values for Akima cubic Hermite interpolation

% Akima's derivative estimate at grid node x(i) requires the four finite
% differences corresponding to the five grid nodes x(i-2:i+2).
%
% For boundary grid nodes x(1:2) and x(n-1:n), append finite differences
% which would correspond to x(-1:0) and x(n+1:n+2) by using the following
% uncentered difference formula correspondin to quadratic extrapolation
% using the quadratic polynomial defined by data at x(1:3)
% (section 2.3 in Akima's paper):
    n = numel(delta) + 1; % number of grid nodes x
    delta_0  = 2*delta(1)   - delta(2);
    delta_m1 = 2*delta_0    - delta(1);
    delta_n  = 2*delta(n-1) - delta(n-2);
    delta_n1 = 2*delta_n    - delta(n-1);
    delta = [delta_m1 delta_0 delta delta_n delta_n1];

% Akima's derivative estimate formula (equation (1) in the paper):
%
%       H. Akima, "A New Method of Interpolation and Smooth Curve Fitting
%       Based on Local Procedures", JACM, v. 17-4, p.589-602, 1970.
%
% s(i) = (|d(i+1)-d(i)| * d(i-1) + |d(i-1)-d(i-2)| * d(i))
%      / (|d(i+1)-d(i)|          + |d(i-1)-d(i-2)|)
    weights = abs(diff(delta));
    weights1 = weights(1:n);   % |d(i-1)-d(i-2)|
    weights2 = weights(3:end); % |d(i+1)-d(i)|
    delta1 = delta(2:n+1);     % d(i-1)
    delta2 = delta(3:n+2);     % d(i)

    weights12 = weights1 + weights2;
    s = (weights2./weights12) .* delta1 + (weights1./weights12) .* delta2;

% To avoid 0/0, Akima proposed to average the divided differences d(i-1)
% and d(i) for the edge case of d(i-2) = d(i-1) and d(i) = d(i+1):
    ind = weights1 == 0 & weights2 == 0;
    s(ind) = (delta1(ind) + delta2(ind)) / 2;
end

function s = makimaSlopes(delta)
% Derivative values for modified Akima cubic Hermite interpolation

% Akima's derivative estimate at grid node x(i) requires the four finite
% differences corresponding to the five grid nodes x(i-2:i+2).
%
% For boundary grid nodes x(1:2) and x(n-1:n), append finite differences
% which would correspond to x(-1:0) and x(n+1:n+2) by using the following
% uncentered difference formula correspondin to quadratic extrapolation
% using the quadratic polynomial defined by data at x(1:3)
% (section 2.3 in Akima's paper):
    n = numel(delta) + 1; % number of grid nodes x
    delta_0  = 2*delta(1)   - delta(2);
    delta_m1 = 2*delta_0    - delta(1);
    delta_n  = 2*delta(n-1) - delta(n-2);
    delta_n1 = 2*delta_n    - delta(n-1);
    delta = [delta_m1 delta_0 delta delta_n delta_n1];

% Akima's derivative estimate formula (equation (1) in the paper):
%
%       H. Akima, "A New Method of Interpolation and Smooth Curve Fitting
%       Based on Local Procedures", JACM, v. 17-4, p.589-602, 1970.
%
% s(i) = (|d(i+1)-d(i)| * d(i-1) + |d(i-1)-d(i-2)| * d(i))
%      / (|d(i+1)-d(i)|          + |d(i-1)-d(i-2)|)
%
% To eliminate overshoot and undershoot when the data is constant for more
% than two consecutive nodes, in MATLAB's 'makima' we modify Akima's
% formula by adding an additional averaging term in the weights.
% s(i) = ( (|d(i+1)-d(i)|   + |d(i+1)+d(i)|/2  ) * d(i-1) +
%          (|d(i-1)-d(i-2)| + |d(i-1)+d(i-2)|/2) * d(i)  )
%      / ( (|d(i+1)-d(i)|   + |d(i+1)+d(i)|/2  ) +
%          (|d(i-1)-d(i-2)| + |d(i-1)+d(i-2)|/2)
    weights = abs(diff(delta)) + abs((delta(1:end-1)+delta(2:end))/2);

    weights1 = weights(1:n);   % |d(i-1)-d(i-2)|
    weights2 = weights(3:end); % |d(i+1)-d(i)|
    delta1 = delta(2:n+1);     % d(i-1)
    delta2 = delta(3:n+2);     % d(i)

    weights12 = weights1 + weights2;
    s = (weights2./weights12) .* delta1 + (weights1./weights12) .* delta2;

% If the data is constant for more than four consecutive nodes, then the
% denominator is zero and the formula produces an unwanted NaN result.
% Replace this NaN with 0.
    s(weights12 == 0) = 0;
end