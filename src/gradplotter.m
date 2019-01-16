% Plot gradients onto an already opened figure after manually importing a cryosection's .mat file.
figure
set(gca, 'FontSize', 28);
xticks([0,1]);
yticks([0,1]);
hold on

% Use x     from E12_1.xNorm{iSection} index with iSection
% Use pSmad from E12_1.smoothNorm.psmad{iSection,1}(:,iSlice)
% Use Sox2  from E12_1.smoothNorm.sox2{iSection,1}(:,iSlice)

% Scale x to section 3. (determined after manual inspection).
% E12_1.smoothNorm.sox2{3,1}(:,8) => max at x=375/1092=0.3434
% [maxSliceVal,maxSliceValInd] = max(E12_1.smoothNorm.sox2{iSection,1}(:,iSlice);
% dist = maxSliceValInd/max(E12_1.x{iSection,1})
% dist = maxSliceValInd - 375;
% shift = -dist;
% E12_1.xNormShift.sox2{iSection,1}(:,iSlice) = E12_1.x{iSection,1} + shift;

% E12_1.xNormShift.sox2{iSection,1}(:,iSlice) = E12_1.x{iSection,1} - 100;

%1: -330
%2: -70
%3: +0
%4: +60

count = 1;
% for iSection = 1:nSections
%     nSlices = size(E12_1.raw.psmad{iSection,1},2);
iSection = 4;
    for iSlice = 5:nSlices-5
        E12_1.xNormShift.sox2{iSection,1}(:,iSlice) = E12_1.xNorm{iSection,1};
        E12_1.xNormShift.psmad{iSection,1}(:,iSlice) = E12_1.xNorm{iSection,1};
        plot(E12_1.xNormShift.psmad{iSection,1}(:,iSlice), E12_1.smoothNorm.psmad{iSection,1}(:,iSlice),'c')
        plot(E12_1.xNormShift.sox2{iSection,1}(:,iSlice), E12_1.smoothNorm.sox2{iSection,1}(:,iSlice),'m')
        count = count + 1;
        disp(count)
    end
% end


% count = 1;
% % for iSection = 1:nSections
% %     nSlices = size(E12_1.raw.psmad{iSection,1},2);
% iSection = 3;
%     for iSlice = 4:nSlices-3
%         %plot(E12_1.xNorm{iSection}, E12_1.smoothNorm.psmad{iSection,1}(:,iSlice),'r')
%         plot(E12_1.xNorm{iSection}, E12_1.smoothNorm.sox2{iSection,1}(:,iSlice),'b')
%         count = count + 1;
%         disp(count)
%     end
% % end

