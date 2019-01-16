xNorm = x/max(x);
psmadNorm = psmad/max(max(psmad));
sox2Norm = sox2/max(max(sox2));

nMeas = size(x,1);


nSlices = size(psmad,2);

w = 100; type = 4; ends = 1;

for iSlice = 1:nSlices
    psmadNormSmooth(:,iSlice) = fastsmooth(psmadNorm(:,iSlice), w, type, ends);
    sox2NormSmooth(:,iSlice) = fastsmooth(sox2Norm(:,iSlice), w, type, ends);
end



% for iSlice = 1:nSlices
%     for iMeas = 1:nMeas
%         psmadNormSmooth(:,iMeas) = fastsmooth(psmadNorm(:,iMeas), w, type, ends);
%         sox2NormSmooth(:,iMeas) = fastsmooth(sox2Norm(:,iMeas), w, type, ends);
%     end
% end

xNormMat = repmat(xNorm, 1, nMeas);

%%%
%zMat = repmat(psmad_z_slices_chosen_for_pi_calcs(1):psmad_z_slices_chosen_for_pi_calcs(end),numel(xNorm),1);
% plot3(xiMat,zMat,data,'k')
% hold on
% plot3(xiMat,zMat,psmadSmooth,'k','Linewidth',2)
% title('pSmad')
% xlabel('x/L')
% ylabel('z-slice')
% zlabel('Fluorescence')
% grid on

% % Calculate the P(g_i|x)
% % See G. Tka ik, J. O. Dubuis, M. D. Petkova, and T. Gregor, “Positional Information, Positional Error, and Readout Precision in Morphogenesis: A Mathematical Framework,” Genetics, vol. 199, no. 1, pp. 39–59, Jan. 2015.
% 
% % Eq. 7
% % for i = 1:1090
% %     Pgx1(i) = (1/sqrt(2*pi*psmadSmoothVar(i)))*exp(-(psmadSmooth_pi(i,1)-mean(psmadSmooth_pi(i,:)))^2/(2*psmadSmoothVar(i)))
% % end
% 
% %% Fit data to distribution (kernel)
% slices = length(psmad_z_slices_chosen_for_pi_calcs);
% pd = cell(slices,1);
% for i = 1:slices
%     pd(i) = histfit(psmadSmooth(:,i),floor(sqrt(length(psmadSmooth(:,i)))),'kernel');
% end