function [B, X, T] = findiff1d(nN, tRange, pVals)
% FINDIFF1D uses the 1D finite difference method to solve
% reaction-diffusion PDEs for cochlea development.
%
% Inputs:
%   nN: number of finite difference nodes along domain
%   tRange: time duration (e.g. [0,5000]) [s]
%   pVals: struct containing ODE parameter values
% 
% Outputs:
%   B: Bmp4 distribution along domain at each node (1D column)
%
% ODE system:
%
% d[B]/dt = D_B*9d^2[B]/dx^2)
%             - dec_B*[B] + gen_B
%
% 
% Parameter definitions:
% Ltot:     Total circumferencial organ length (1D)     [micron]
% LB_gen:   Bmp4 ligand expression region length        [micron]
% D_B:      Bmp4 ligand diffusion rate                  [micron^2/s]*(60s/min)
% dec_B:    Bmp4 ligand decay rate                      [1/min]
% gen_B:    Bmp4 production                             [...]
% 

% Function handle for faster evaluation of differential equations.
fdAdt = @dAdt;

% Initial Conditions
B0 = zeros(1,nN); %%% want to switch to col

init = B0; %%% want to switch to vertcat

options = odeset('RelTol', 1e-9); % 1e-3 default

[T, D] = ode15s(fdAdt, tRange, init, options, nN, pVals);

% Store solution data
% % % B1 = D(:, 1:nN);
B = D(:, 1:nN);

% % % % Reflect solution
% % % B2 = zeros(size(B1));
% % % 
% % % for iN = 1:nN
% % %     B2(:,iN) = B1(:, (nN + 1) - iN);
% % % end
% % % 
% % % B = [B2 B1];

% Create position data array.
% % % start = -pVals.Ltot + pVals.Ltot/nN;
dx = pVals.Ltot/nN;
start = dx;
X = start:(pVals.Ltot/nN):pVals.Ltot;

end

% Subfunction holding differential equations
function dY = dAdt(t, Y, nN, pVals)
%% Extract parameter values.
% Geometry
Ltot = pVals.Ltot;        % Total circumferencial organ length (1D)  [micron]
LB_gen = pVals.LB_gen;    % Length of Bmp4 ligand expression region  [micron]
% Diffusion
D_B = pVals.D_B;          % Bmp4 ligand diffusion rate               [micron^2/s]*(60s/min)
% Kinetic
%%%
% Decay
dec_B = pVals.dec_B;      % Bmp4 ligand decay rate                   [nM/min]
% Production
gen_B = pVals.gen_B;      % Bmp4 ligand production rate              [nM/min]
% Feedback
%%%

%% Convert boundary positions to nearest node locations.
nB_gen = round( (LB_gen*nN)/Ltot );

% Discretize domain to node positions.
dx = Ltot/nN;

%% Initialize prepatterns for production.
eta_B = zeros(1,nN);
x_lig = 1:nN;
% % % y = (exp(-(x_lig-11)/5))./(0.1+exp(-(x_lig-11)/5));  %original version had 18 instead of 11 Update 02162017
nCells = 4; % number of cells producing Bmp4
cellWidth = 10; % [micron]
peak = 2/3; % Center for Bmp4 production
y = zeros(1,nN);
y(nN*0.6:nN*0.7) = ones(101,1);
y( ceil( peak*nN - (nCells*cellWidth/2) ) : floor( peak*nN + (nCells*cellWidth/2) ) ) = ...
    ones(1,nCells*cellWidth); 
eta_B = gen_B * y; % Defines lateral production region for Bmp4

%% Convert Y vetor into.
Bmp = Y(1:nN);

%% Re-initialize difference vectors.
dBmp = zeros(1,nN);

%% Solve ODEs at each time point. (index 1 corresponds to ???
% Boundary node 1
dBmp(1) = ( D_B/dx^2 )*( -2*Bmp(1) + 2*Bmp(2) ) ...
    - dec_B*Bmp(1) + eta_B(1);

% Internal nodes
for iN = 2:nN-1
    dBmp(iN) = ( D_B/dx^2 )*( Bmp(iN-1) - 2*Bmp(iN) + Bmp(iN+1) ) ...
        - dec_B*Bmp(iN) + eta_B(iN);
end

% Boundary node 2
dBmp(nN) = ( D_B/dx^2 )*( 2*Bmp(nN-1) - 2*Bmp(nN) ) ...
    - dec_B*Bmp(nN) + eta_B(nN);

%% Update solution array.
dY = [dBmp]';
end