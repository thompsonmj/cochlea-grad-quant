function Chi = Resid(A,I,B, C_mean)

% %Expand Coef(1) across x for calculation
% Amat = ones([size(I(:,1)) 1])*Coef(1,:);
% Bmat = ones([size(I(:,1)) 1])*Coef(2,:);
% %Calculate average Concentration across n embryos
% Cbar=(1/n)*(sum((I-Amat)./Bmat,2));
% %Calculate residual of Intensities when calculated by average C
% R=(Cbar*Coef(1,:) + ones([size(I(:,1)) 1])*Coef(2,:))-I;
% %Calculate Chi, a sum of squared errors term
% Chi = sum(sum(R.^2));
% end

% B = zeros(size(I,1),1);
% A = ones(size(I,1),1)*Coef();

Chi = sum((I - A .* C_mean - B).^2);

end