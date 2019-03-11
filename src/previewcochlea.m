% PREVIEWCOCHLEA is used to generate a summary figure of the nuclear channel
% for all imaged cryosections in a single cochlea organ. Images must be
% located in a single directory and be ordered numerically from base ->
% apex.

% Select preview folder.
previewDir = uigetdir;
contents = dir(previewDir);

nPics = size(contents,1) - 2; % Exclude '.' and '..'.

% Store file names of all contents in this directory.
fname = strings(nPics,1);
for iImg = 3:nPics + 2
    fname(iImg - 2) = string(contents(iImg).name);
end

% Sort numerically.
[fnameSorted,pieces] = sortit(fname); % Add-on function.
picIdx = zeros(nPics,1);
for iImg = 1:nPics
    picIdx(iImg) = str2double(pieces{iImg}{1});
end

picIdx = sort(picIdx);

for iImg = 1:nPics-1
    if picIdx(iImg+1) - picIdx(iImg) > 1
        fnameSortedFront = fnameSorted(1:iImg);
        fnameSortedBack = fnameSorted(iImg+1:end);
        fnameSortedFront = [ fnameSortedFront;...
        string(picIdx(iImg)+1:picIdx(iImg+1)-1)' ];
        fnameSorted = [fnameSortedFront;fnameSortedBack];       
        
        picIdxFront = picIdx(1:iImg);
        picIdxBack = picIdx(iImg+1:end);
        picIdxFront = [picIdxFront;[picIdx(iImg)+1:picIdx(iImg+1)-1]'];
        picIdx = [picIdxFront;picIdxBack];
    end
end

nImg = size(fnameSorted,1);

% Set dimensions for subplots.
if nImg <= 6
    subxdim = 1;
    subydim = nPics;
else
    subxdim = ceil(nImg/6);
    subydim = 6;
end

% Plot images in subplot intermingled with indicators of missing sections.
figure
h = {};
for iImg = 1:nImg
    f = char(fullfile(previewDir,fnameSorted(iImg)));
    if isfile(f)
        img = imread(f);
        h = [h;subplot(subxdim,subydim,iImg)];
        imagesc(img)
    else
        h = [h;subplot(subxdim,subydim,iImg)];
        imagesc(sparse(eye(100)));
    end
    
    [x,name,xx] = fileparts(fullfile(previewDir,fnameSorted(iImg)));
    title(name,'Interpreter','none')
    axis off
end

% Scale subplot images to original aspect ratio.
images = {};
for iImg = 1:nImg
    f = char(fullfile(previewDir,fnameSorted(iImg)));
    if isfile(f)
        img = imread(f);
        images = [images;img];
    else
        img = sparse(eye(100));
    end
    daspect(h(iImg), [size(img,1)/min(size(img)), size(img,2)/min(size(img)), 1])
end

% For some reason this is necessary.
for iImg = 1:nImg
    daspect(h(iImg), [1 1 1])
end

