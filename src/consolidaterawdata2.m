oworkdir = pwd;

% Starting point for data (relative to this script location).
root = fullfile('..','..','..','data','img','sw','wt');

%% First split point: E12.5, E13.5.
root12 = fullfile(root,'E12.5');
root13 = fullfile(root,'E13.5');

roots = {root12,root13};
nRoots = numel(roots);

%%
cochleaDirs = {};
nCochleae = 0;
for iR = 1:nRoots
    d = dir(roots{iR});
    % All viable cochleae are stored in directories with names beginning with
    % an integer followed by an underscore.
    nObjs = numel(d);
    for iO = 1:nObjs
        if ~isempty(str2double(d(iO).name(1))) && ...
                ~isnan(str2double(d(iO).name(1))) && ...
                d(iO).isdir
            nCochleae = nCochleae + 1;
            cochleaDirs{nCochleae} = fullfile(roots{iR},d(iO).name);
        end
    end
end
% Key loop outputs: 
%   > cochleaDirs: cell array of all cochlea directories (all ages)
%   > nC: total number of cochlea (all ages)

% Section counter.
idx = 0;

data = initializesectionstruct;
% Excel data files are stored uniformly under an age's root directory.
excelSubDir = fullfile('tif-orient','sep-ch','mip','despeckle','quant-prof');
for iCoch = 1:nCochleae
    disp([num2str(iCoch),'/',num2str(nCochleae)])
    % Sort through each object in the cochlea's Excel directory.
    d = dir(fullfile(cochleaDirs{iCoch},excelSubDir,'*_pse.xlsx'));
%     d(1:2) = []; % Remove '.' and '..'
    nBooks = numel(d);
    for iB = 1:nBooks
        NewData = initializesectionstruct;
        
        [~,fname,fext] = fileparts(fullfile(d(iB).name));
        
        if fname(1) == 'A'
            % Skip apical sections (for now).
            continue
        end
        % Section counter.
        idx = idx + 1;
        
        xlsxFile = fullfile(cochleaDirs{iCoch},excelSubDir,d(iB).name);
        %% Store section ID information.        
        SectionID = getsectionid(xlsxFile);
        
        NewData.age =           SectionID.age;
        NewData.cochlea_idx =   SectionID.cochlea_idx;
        NewData.section_ab =    SectionID.section_ab;
        NewData.section_idx =   SectionID.section_idx;        
        %% Extract profile data from Excel sheets.
        try
            SectionExcelData = getsectionexceldata(xlsxFile);
        catch
            continue % to next iteration of for loop
        end
            
        NewData.length = SectionExcelData.length;

        % Only parse channels with existing data for this section.
        channels = fieldnames(SectionExcelData);
        channels = channels(1:end-1); % Remove length field
        nChannels = numel(channels);
        chIdx = 0;
        usedChannels = {};
        for iCh = 1:nChannels
            if ~isempty(SectionExcelData.(channels{iCh}))
                chIdx = chIdx + 1;
                usedChannels{chIdx} = channels{iCh};
            end
        end
        channels = usedChannels;
        
        % Scale to 16 bit (if necessary).
        nChannels = numel(channels);
        bitDepths = zeros(nChannels,1);
        for iCh = 1:nChannels
            [scaledProf,oDepth] = ...
                scaleto16bit(SectionExcelData.(channels{iCh}));
            NewData.(channels{iCh}) = scaledProf;
            bitDepths(iCh) = oDepth;
            NewData.origional_bit_depth = oDepth;
        end
        assert(numel(unique(bitDepths)) == 1, ...
            'More than one bit depth detected in this section');
        NewData.origional_bit_depth = unique(bitDepths);
        %% Store image location for each channel.
        % Find the relative location for the image file for this channel of
        % this section.

        % Sort through each object in the cochlea's despeckled image
        % directory.
        imgSubDir = fullfile('tif-orient','sep-ch','mip','despeckle','_data_');
        img_d = dir(fullfile(cochleaDirs{iCoch},imgSubDir,'*.tif'));        
        nTifs = numel(img_d);
        
        for iCh = 1:nChannels
            for iT = 1:nTifs
                % Find the image matching this channel and section
                % e.g. '..\_data_\B11_ch1-topro3_mip_despeckled.tif'
                
                % if this object matches the current channel, section_ab,
                % and section_idx, add the relative filename to the
                % corresponding channel metadata.img_file field
                % 
                % otherwise, go to the next object.
                % 
                % should have some error checking to make sure an image is
                % selected
                
                % match *_sec-img.tif, make sure no x at beginning

                [~,img_name,img_ext] = fileparts(img_d(iT).name);
                str = img_name(2:end);
                
                expression = '^\d+(?=_)';
                [startIdx,endIdx] = regexp(str,expression);
                section_idx = str(startIdx:endIdx);
                
                expression = channels{iCh};
                [startIdx,endIdx] = regexp(str,expression);
                channel = str(startIdx:endIdx);
                
                str = img_name;
                expression = '_sec-img';
                [startIdx,endIdx] = regexp(str,expression);
                
                if ~isempty(startIdx) && ...
                        ~isempty(endIdx) && ...
                        ~isempty(channel) && ...
                        NewData.section_ab == img_name(1) && ...
                        NewData.section_idx == str2double(section_idx) && ...
                        img_name(1) ~= 'x'
                    % this should mean we have a direct hit.
                    % now save this filename to the right spot
                    NewData.([channels{iCh},'_img_file']) = ...
                        fullfile(cochleaDirs{iCoch},imgSubDir,[img_name,img_ext]);
                    
                end
                
                if ~isempty(NewData.([channels{iCh},'_img_file']))
                   info = imfinfo(NewData.([channels{iCh},'_img_file']));
                    assert(NewData.origional_bit_depth == info.BitDepth, ...
                        'Incorrect bit depth inferred.')
                    W = info.Width;
                    H = info.Height;

                    if max([W,H]) < 724
                        NewData.origional_resolution = 512;
                        NewData.img_scale = 1.6028;
                    elseif max([W,H]) >= 724 && ...
                            max([W,H]) < 1448
                        NewData.origional_resolution = 1024;
                        NewData.img_scale = 3.2055;
                    else
                        error('Unexpected resolution')

                    end
                end    

                         
            end
        end
        
        % *_pse.roi
        pse_d = dir(fullfile(cochleaDirs{iCoch},imgSubDir,'*_pse.roi'));
        nPSE = numel(pse_d);
        for iPSE = 1:nPSE
            [~,pse_name,pse_ext] = fileparts(pse_d(iPSE).name);
            
            str = pse_name(2:end);
            expression = '^\d+(?=_)';
            [startIdx,endIdx] = regexp(str,expression);
            section_idx = str(startIdx:endIdx);
                
                if NewData.section_ab == pse_name(1) && ...
                        NewData.section_idx == str2double(section_idx) && ...
                        pse_name(1) ~= 'x'
                    NewData.pse_roi = ...
                        ReadImageJROI(fullfile(cochleaDirs{iCoch},imgSubDir,[pse_name,pse_ext]));
                end
        end
        
        % *_nuc.roi
        nuc_d = dir(fullfile(cochleaDirs{iCoch},imgSubDir,'*_nuc.roi'));
        nNUC = numel(nuc_d);
        for iNUC = 1:nNUC
            [~,nuc_name,nuc_ext] = fileparts(nuc_d(iNUC).name);
                
            str = nuc_name(2:end);
            expression = '^\d+(?=_)';
            [startIdx,endIdx] = regexp(str,expression);
            section_idx = str(startIdx:endIdx);
                
                if NewData.section_ab == nuc_name(1) && ...
                        NewData.section_idx == str2double(section_idx)% && ...
%                         nuc_name(1) ~= 'x'
                    NewData.nuc_roi = ...
                        ReadImageJROI(fullfile(cochleaDirs{iCoch},imgSubDir,[nuc_name,nuc_ext]));
                end
        end
        
        %% Store sampled nuclear intensity data.
        % Applies only to P-Smad, Sox2, and TOPRO3.
%         nucSampleChannels = {'psmad','sox2','topro3'};
%         nucSampleDataFields = {'psmad_nuc','sox2_nuc','topro3_nuc'};
%         for iNSC = 1:numel(nucSampleChannels)
%             if ~isempty(NewData.(nucSampleChannels{iNSC}))
%                 NewData.(nucSampleDataFields{iNSC}) = ...
%                     getchannelsamplednucleardata();
%             end
%         end
%         % make subfunction called getchannelsamplednucleardata.m
%         channelsInThisSection

        % If there's a *_nuc.roi file corresponding to this entry, 
%         try
%             if ~isempty(NewData.nuc_roi)
%                 for iCh = 1:nChannels
%                     assert( ~isempty(NewData.([channels{iCh},'_img_file'])), ...
%                         'Missing image for ',channels{iCh},' channel.' )
% 
%                     [ NewData.x_nuc, yyy ] = ...
%                         edtoroicurve( ...
%                         NewData.nuc_roi, ...
%                         NewData.pse_roi, ...
%                         NewData.img_scale, ...
%                         NewData.([channels{iCh},'_img_file']) );
% 
%                     [ NewData.([channels{iCh},'_nuc']), ~ ] = scaleto16bit(yyy);
% 
%                 end
%             end
%         catch 
%             disp(['Projection error for ',NewData.age,' ',NewData.cochlea_idx,NewData.section_ab,NewData.section_idx,' ',channels{iCh}])
%         end
        
        %% Add temp data to output data.
        data(idx) = NewData;
    end
end
%% Flag select sections
data = addflagstoselectsections(data);
%% Save
dataDir = fullfile('..','..','..','data');
cd(dataDir)

DandT = datestr(datetime,'yyyy-mm-dd_HH-MM-SS');

fileName = ['cochlea-data_',DandT,'.mat'];

save(fileName,'data','-v7.3')

cd(oworkdir)
