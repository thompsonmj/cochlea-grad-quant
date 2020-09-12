function P = decodingmap(Y)

[nPts,nReplicates] = size(Y);

g_mean = mean(Y,2);
g_std = std(Y,0,2);

Z = 1;
for iR = 1:nReplicates
    for idx_x_imp = 1:nPts
        for idx_x = 1:nPts
            
            g_alpha_at_x = Y(idx_x,iR);
            g_mean_at_x_imp = g_mean(idx_x_imp);
            g_std_at_x_imp = g_std(idx_x_imp);
            
            chi2_for_g_alpha_at_x = ...
                (g_alpha_at_x - g_mean_at_x_imp)^2/(g_std_at_x_imp^2);

            P_of_g_alpha_at_x_given_x_imp = ...
                (1/Z)* ...
                sqrt(2 * pi * g_std_at_x_imp^2)* ...
                exp(-chi2_for_g_alpha_at_x / 2)* ...
                (1/nPts);

            P(idx_x_imp,idx_x,iR) = P_of_g_alpha_at_x_given_x_imp;                
            
        end
    end
end

P = rot90(P);

end
