% function name: FiniDiffMod2.m
% author: Wei Dou

%Same as FINITE DIFF MOD2 w/ a distributed ligand source
%
% David Umulis Updates on 07/01/2014
% Last Update: 12/3/2013
%
% functionality:
%    This function uses a 1D finite difference method to solve the ODE for
%    Zebrafish BMP gradient formation during embryogenesis. 
%    Based on the primary function FiniteTest.m for the evaluation of differential 
%    equations using the 4th order runge-kutta technique with a fixed step-size.
%
% ODE system:
%
%    d[B]/dt = DB*(d^2[B]/dx^2)
%            - kon2*[B]*[C] + koff2*[BC] 
%            - kon3*[B]*[N] + koff3*[BN] 
%
%            - decB*[B] + etaB + lambdaBC*Tld*[BC]             
%
%    d[C]/dt = DC*(d^2[C]/dx^2)
%            - kon2*[B]*[C] + koff2*[BC] 
%            - decC*[C] + etaC - lambdaC*Tld*[C]
%
%    d[N]/dt = DN*(d^2[N]/dx^2) 
%            - kon3*[B]*[N] + koff3*[BN]
%            - decN*[N] + etaN
%
%    d[BC]/dt = DBC*(d^2[BC]/dx^2)
%             + kon2*[B]*[C] - koff2*[BC] 
%             - lambdaBC*Tld*[BC]
%
%    d[BN]/dt = DBN*(d^2[BN]/dx^2)
%             + kon3*[B]*[N] - koff3*[BN]
%
% function input:
%    n - number of nodes to evaluate finite difference equations
%    tRange - time interval to evaluate differential equations, eg. [0 5000]
%    parameters - a stucture storing input parameter values like diffusion
%                 rates, and reaction rates, etc. 
%        .Ltot - length of the embryo (1D assumption)       microns
%        .Lven - length of ventral region (1D assumption)   microns
%        .LdorC - length of dorsal Chd expression region    microns
%        .LdorN - length of dorsal Nog expression region    microns
%        .DB - diffusion rate of ligand (BMP)    (microns^2*s^-1)*60s*m^-1
%        .DC - diffusion rate of Chordin       (microns^2*s^-1)*60s*m^-1
%        .DN - diffusion rate of Noggin          (microns^2*s^-1)*60s*m^-1
%        .DBC - diffusion rate of [BMP,Chd]    (microns^2*s^-1)*60s*m^-1
%        .DBN - diffusion rate of [BMP,Nog]      (microns^2*s^-1)*60s*m^-1
%        .k2 - binding rates for BMP ligand and Chordin      nM^-1*m^-1
%        .k_2 - unbinding rates for BMP ligand and Chordin   m^-1
%        .k3 - binding rates for BMP ligand and Noggin       nM^-1*m^-1
%        .k_3 - unbinding rates for BMP ligand and Noggin    m^-1
%        .k4 - binding rates for BMP ligand and surface component  nM^-1*m^-1
%        .k_4 - unbinding rates for BMP ligand and surface componetn  m^-1 
%        .k6 - binding rates for [BMP,Nog] and surface component  nM^-1*m^-1
%        .k_6 - unbinding rates for [BMP,Nog] and surface component  m^-1
%        .kendo1 - endocytosis rate of [B,C]   m^-1
%        .kendo2 - endocytosis rate of [BN,C]  m^-1
%        .decB - decay rate of Ligand (BMP)    m^-1  
%        .decC - decay rate of Chd             m^-1  
%        .decN - decay rate of Nog             m^-1  
%        .j1 - production rate of BMP          nM*m^-1  
%        .j2 - production rate of Chordin      nM*m^-1
%        .j3 - production rate of Noggin       nM*m^-1
%        .lambda_tld_C - tld processing rate of Chd     nM^-1*m^-1
%        .lambda_tld_BC - tld processing rate of BChd   nM^-1*m^-1
%        .tld_conc - tld concentration         nM
%        .Stot - total surface component       nM
%     save_or_not - whether to save the output into .mat files (0 or 1)
%                   default = 0 (not save)
% NOTE: make n that can exactly divided by Ltot for easy calculation
%
% function output:
%    B - vector storing distribution of BMP 
%    C - vector storing distribution of Chordin
%    N - vector storing distribution of Noggin
%    BC - vector storing distribution of BMP-Chordin complex
%    BN - vector storing distribution of BMP-Noggin complex
%    X - vector storing postional information (micron)

function [B, C, N, BC, BN, X, T] = FiniDiffMod3(n, tRange, parameters, save_or_not)

if nargin~=4, save_or_not = 0; end;

tic; % start record time

% Create a function that handles faster evaluation of differential equations
fdAdt = @dAdt;

%Capture current time to measure computational speed
%----------------- initialize geometry and vectors --------------------
B0 = zeros(1,n);   % initialize BMP vector
C0 = zeros(1,n);   % initialize Chordin vector
N0 = zeros(1,n);   % initialize Noggin vector
BC0 = zeros(1,n);   % initialize BMP_Chordin vector
BN0 = zeros(1,n);   % initialize BMP_Noggin vector

initial = [B0, C0, N0, BC0, BN0];    % initialize condition vector

options = odeset('RelTol', 1e-9);    % set solving options 

% solve ode using 15s
% must use vertically concatenated inputs to solve simultaneously - MJT
% 2019-03-06
[T, D] = ode15s(fdAdt, tRange, initial, options, n, parameters);   

%------------------------- store data in vectors --------------------------
B1 = D(:, 1:n);      
C1 = D(:, n+1:2*n);
N1 = D(:, 2*n+1:3*n);
BC1 = D(:, 3*n+1:4*n);
BN1 = D(:, 4*n+1:5*n);
%------------------------- Reflect the solution ---------------------------
B2 = zeros(size(B1));
C2 = zeros(size(C1));
N2 = zeros(size(N1));
BC2 = zeros(size(BC1));
BN2 = zeros(size(BN1));

for i=1:n
    B2(:,i) = B1(:,n+1-i);
    C2(:,i) = C1(:,n+1-i);
    N2(:,i) = N1(:,n+1-i);
    BC2(:,i) = BC1(:,n+1-i);
    BN2(:,i) = BN1(:,n+1-i);
end

B = [B2 B1];
C = [C2 C1];
N = [N2 N1];
BC = [BC2 BC1];
BN = [BN2 BN1];

%--------------------------- make x data vector --------------------------- 
start = -parameters.Ltot + parameters.Ltot/n;
X = start:(parameters.Ltot/n):parameters.Ltot;

end

% This fucntion is the set of differential equations
function dY = dAdt(t, Y, n, parameters)

%----------------------- obtain parameter values --------------------------
  %%% geometry
Ltot = parameters.Ltot;   % length of the embryo (1D assumption)       microns
Lven = parameters.Lven;  % length of ventral region for Bmp expression         microns
LvenXlr = parameters.LvenXlr; % length of ventral region for Xlr expression    microns
LdorC = parameters.LdorC;   % length of dorsal Chd expression region   microns
LdorN = parameters.LdorN;   % length of dorsal Nog expression region   microns
  %%% diffusion rates
DB = parameters.DB;       % diffusion rate of ligand (BMP)    (microns^2*s^-1)*60s*m^-1
DC = parameters.DC;       % diffusion rate of Chordin         (microns^2*s^-1)*60s*m^-1
DN = parameters.DN;       % diffusion rate of Noggin          (microns^2*s^-1)*60s*m^-1
DBC = parameters.DBC;     % diffusion rate of [BMP,Chd]       (microns^2*s^-1)*60s*m^-1
DBN = parameters.DBN;     % diffusion rate of [BMP,Nog]       (microns^2*s^-1)*60s*m^-1
  %%% kinetic parameters
k2 = parameters.k2;       % binding rates for BMP ligand and Chordin          nM^-1*m^-1
k_2 = parameters.k_2;     % unbinding rates for BMP ligand and Chordin        m^-1
k3 = parameters.k3;       % binding rates for BMP ligand and Noggin           nM^-1*m^-1
k_3 = parameters.k_3;     % unbinding rates for BMP ligand and Noggin         m^-1
kendo1 = parameters.kendo1; % endocytosis rate of [B,C]   m^-1
kendo2 = parameters.kendo2; % endocytosis rate of [BN,C]  m^-1
  %%% decay/recycle rates 
decB = parameters.decB;   % decay rate of Ligand (BMP)    nM*m^-1  
decC = parameters.decC;   % decay rate of Chd             nM*m^-1  
decN = parameters.decN;   % decay rate of Nog             nM*m^-1 
decBC = parameters.decBC;   % decay rate of Chd             nM*m^-1  
decBN = parameters.decBN;   % decay rate of Nog             nM*m^-1  

  %%% production rates 
j1 = parameters.j1;       % production rate of BMP          nM*m^-1  
j2 = parameters.j2;       % production rate of Chordin      nM*m^-1
j3 = parameters.j3;       % production rate of Noggin       nM*m^-1
  %%% Tolloid behavior
lambda_tld_C = parameters.lambda_tld_C;     % tld processing rate of Chd  nM^-1*m^-1
lambda_tld_BC = parameters.lambda_tld_BC;   % tld processing rate of LC   nM^-1*m^-1
tld_conc = parameters.tld_conc;             % tld concentration           nM

  %%% Positive Feedback
K = parameters.K;         % Vmax for positive feedback (multiply by 0 to turn off)
kM = parameters.kM;       % kM parameter for Hill function
nu = parameters.nu;       % cooperative parameter

%------------- Convert boundaries to positions of nearest node ------------
nven = round(Lven*n/Ltot);
nvenXlr = round(LvenXlr*n/Ltot);
ndorC = round(LdorC*n/Ltot);
ndorN = round(LdorN*n/Ltot);

%--- Increment size for finite difference method,distance between nodes --- 
dx = Ltot/n;

%----------------- Initialize prepatterns for secretion -------------------
% source production - MJT 2019-03-06
etaB = zeros(1,n);
etaC = zeros(1,n);
etaN = zeros(1,n);
Tld = zeros(1,n);
x_lig = 1:n;
y = (exp(-(x_lig-11)/5))./(0.1+exp(-(x_lig-11)/5));  %original version had 18 instead of 11 Update 02162017
etaB = j1 * y;      % define ventral region for BMP production
for i = 1:n
    
    etaC(i) = j2 * double( i>(n-ndorC) );  % define dorsal region for Chordin production
    etaN(i) = j3 * double( i>(n-ndorN) );  % define dorsal region for Noggin production
%    Tld(i) = tld_conc;       % Tolloid uniformly distributed in the embryo
    Tld(i) = tld_conc*double(i<=nvenXlr);   % Tolloid distributed ventrally
end

%------------ convert Y vector into vectors for each component ------------
Bmp = Y(1:n);
Chd = Y(n+1:2*n);
Nog = Y(2*n+1:3*n);
BC = Y(3*n+1:4*n);
BN = Y(4*n+1:5*n);

%----------------------- Zero out difference vectors ----------------------
dBmp = zeros(1,n);
dChd = zeros(1,n);
dNog = zeros(1,n);
dBC = zeros(1,n);
dBN = zeros(1,n);

%--------------------Begin solving for ODEs at each time point--------
%--------------------Index one corresponds to ventral midline---------
dBmp(1) = DB/dx^2*(-2*Bmp(1)+2*Bmp(2)) ...
        - k2*Bmp(1)*Chd(1) + k_2*BC(1) ...
        - k3*Bmp(1)*Nog(1) + k_3*BN(1) ...
        - decB*Bmp(1) + etaB(1) + lambda_tld_BC*Tld(1)*BC(1) ...
        + K*Bmp(1)^nu/(kM^nu+Bmp(1)^nu);
    
dChd(1) = DC/dx^2*(-2*Chd(1)+2*Chd(2)) ...
        - k2*Bmp(1)*Chd(1) + k_2*BC(1) ...
        - decC*Chd(1) + etaC(1) - lambda_tld_C*Tld(1)*Chd(1) ...
        + K/(kM^nu+Bmp(1)^nu);
      
dNog(1) = DN/dx^2*(-2*Nog(1)+2*Nog(2)) ...
        - k3*Bmp(1)*Nog(1) + k_3*BN(1) ...
        - decN*Nog(1) + etaN(1);

dBC(1) = DBC/dx^2*(-2*BC(1)+2*BC(2)) ...
       + k2*Bmp(1)*Chd(1) - k_2*BC(1) ...
       - lambda_tld_BC*Tld(1)*BC(1) - decBC*BC(1);
   
dBN(1) = DBN/dx^2*(-2*BN(1)+2*BN(2)) ...
       + k3*Bmp(1)*Nog(1) - k_3*BN(1) - decBN*BN(1);
   
%----------------------Internal node points--------------------------    
for i=2:1:n-1
    dBmp(i) = DB/dx^2*(Bmp(i-1)-2*Bmp(i)+Bmp(i+1)) ...
        - k2*Bmp(i)*Chd(i) + k_2*BC(i) ...
        - k3*Bmp(i)*Nog(i) + k_3*BN(i) ...
        - decB*Bmp(i) + etaB(i) + lambda_tld_BC*Tld(i)*BC(i) ...
        + K*Bmp(i)^nu/(kM^nu+Bmp(i)^nu)*double(i<=nven);
    
    dChd(i) = DC/dx^2*(Chd(i-1)-2*Chd(i)+Chd(i+1)) ...
            - k2*Bmp(i)*Chd(i) + k_2*BC(i) ...
            - decC*Chd(i) + etaC(i) - lambda_tld_C*Tld(i)*Chd(i) ...
            + K/(kM^nu+Bmp(i)^nu) * double( i>(n-ndorC) );
       
    dNog(i) = DN/dx^2*(Nog(i-1)-2*Nog(i)+Nog(i+1)) ...
            - k3*Bmp(i)*Nog(i) + k_3*BN(i) ...
            - decN*Nog(i) + etaN(i);

    dBC(i) = DBC/dx^2*(BC(i-1)-2*BC(i)+BC(i+1)) ...
           + k2*Bmp(i)*Chd(i) - k_2*BC(i) ...
           - lambda_tld_BC*Tld(i)*BC(i) - decBC*BC(i);
   
    dBN(i) = DBN/dx^2*(BN(i-1)-2*BN(i)+BN(i+1)) ...
           + k3*Bmp(i)*Nog(i) - k_3*BN(i) - decBN*BN(i);
end
%--------------nth node point corresponds to dorsal midline----------------
dBmp(n) = DB/dx^2*(2*Bmp(n-1)-2*Bmp(n)) ...
        - k2*Bmp(n)*Chd(n) + k_2*BC(n) ...
        - k3*Bmp(n)*Nog(n) + k_3*BN(n) ...
        - decB*Bmp(n) + etaB(n) + lambda_tld_BC*Tld(n)*BC(n);
    
dChd(n) = DC/dx^2*(2*Chd(n-1)-2*Chd(n)) ...
        - k2*Bmp(n)*Chd(n) + k_2*BC(n) ...
        - decC*Chd(n) + etaC(n) - lambda_tld_C*Tld(n)*Chd(n) ...
        + K/(kM^nu+Bmp(n)^nu);
      
dNog(n) = DN/dx^2*(2*Nog(n-1)-2*Nog(n)) ...
        - k3*Bmp(n)*Nog(n) + k_3*BN(n) ...
        - decN*Nog(n) + etaN(n);

dBC(n) = DBC/dx^2*(2*BC(n-1)-2*BC(n)) ...  % change 
       + k2*Bmp(n)*Chd(n) - k_2*BC(n) ...
       - lambda_tld_BC*Tld(n)*BC(n) - decBC*BC(n);
   
dBN(n) = DBN/dx^2*(2*BN(n-1)-2*BN(n)) ...
       + k3*Bmp(n)*Nog(n) - k_3*BN(n) - decBN*BN(n);

%-----------------------Update solution vector---------------------------
dY = [dBmp dChd dNog dBC dBN]'; % Vertical concatenation of each species - MJT 2019-03-06

end