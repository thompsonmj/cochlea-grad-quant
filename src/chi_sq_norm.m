function C_out = chi_sq_norm(I)

n = size(I,2);
% %Initialize Coef (A,B) matrix with intial values

Coef0 = ones(1,n);

% %Coef0(2,:) = -sum(I,1)/size(I,1);
options = optimset('TolFun',1e-6, 'Display', 'off');
warning('Off', 'optim:fmincon:SwitchingToMediumScale')

% %Generate anonymous function to pass multiple parameters to Resid

% %Call minimization routine to solve f (Resid)
% %LBound = zeros(2,size(I(1,:),2));
B=mean(I,1);
C_mean0= mean((I - ones(size(I,1),1)*B),2);
onemat = ones(size(I,1),1);
%%%c_err0 = 1e-4; % Getting stuck between 0.05 and 6.0
c_err0 = 5*1e-4;
c_err = 51;

lb = 0;
ub = 51;

while c_err > c_err0

    for i=1:n
        f=@(Coef)Resid(Coef,I(:,i), B(i), C_mean0);
        [Coef(1, i),fval] = fmincon(f,Coef0(1,i),[],[], [], [], lb, ub, [], options);
    end

    C_mean = mean(((I - onemat*B)./(onemat*Coef)),2);
    c_err = sum(abs((C_mean-C_mean0)))
    C_mean0=C_mean;
end 

% %Calculate C(x) for each of n embryos
Amat = ones([size(I,1) 1])*Coef(1,:);
% %Amat,Bmat expand the Coef vectors across the x dimension to matrices for
% %calculation with I
Bmat = ones([size(I,1) 1])*mean(I);
C=((I-Bmat)./Amat);
C_out = C;

end