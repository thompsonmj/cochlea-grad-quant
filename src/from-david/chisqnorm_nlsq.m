function [C, a] = chisqnorm(imgdir, type);
%CHISQNORM Do chi square normalization of a group of images, and returns
%the normalized concentration and optimized parameter a (for each image).
%   [C, a] = chisqnorm(imgdir) does chi square normalization over a group of
%   images (in jpeg format) stored in directory imgdir, and return an array
%   c of normalized intensities (concentration).  The optimization is made by
%   the whole image region. 
%
%   [C, a] = chisqnorm(imgdir, 1) performs chi square normalization based
%   on maximum embryo region.
%
%   [C, a] = chisqnorm(imgdir, 2) performs chi square normalization based
%   on average mebryo region.

fprintf('Reading image files at %s.\n', imgdir);
I = readimg(imgdir);
emb_shape = double(imread('shape.jpg'));
% By default, the blank is not removed.
if nargin == 1
    type = 0;
end 
size(I)

size(emb_shape)

fprintf('Searching for A that minimize chi-squares.\n');

% Determine the initial value of parameter A by SVD.
[nx, ny, nn] = size(I);
I2 = reshape(I, nx*ny, nn);
[U, S] = svd(I2');
lb = -10*ones(nn,1);
ub = 10*ones(nn,1);
clear('I2');    % To save memory.
E = im2bw(emb_shape,0.1);
a = fminunc(@(A) msdsum2(A, I, type, E), U(:,1));
% Searching for vector A that minimize the chi squares. 
% if type == 2
%     options = optimset('DiffMaxChange',5e-1,'DiffMinChange',1e-1,'Display','iter','TolX',1e-4,'LargeScale','off','HessUpdate','dfp');
%     % Determine the avearge embryo region.
%     E = avgembryo(I);
%     image(E*100); title('Ellipse region');
%     pause
%     a = fminsearch(@(A) msdsum2(A, I, type, E), U(:,1));
% else
%     E = maxembryo(I);
%     a = fminsearch(@(A) msdsum2(A, I, type, E), U(:,1));
% end

% Calculate the concentration based on the optimized A. 
fprintf('Calculating concentration based on the optimized parameters.\n');
C = conc_dmu(I, a,type,E);

end

%-------------------------------------------------------------------------


function y = msdsum2(a, I, type, E)
%MSDSUM2 Calculate the sum of mean square deviation between intensity and
%noralized concentration of a group of images.
%   y = msdsum2(a, I) calculates the sum of mean square deviation
%   between the intensity of a group images (I, 3D array) and the concentrations,
%   which is normalized based the parameter param.
%   
%   y = msdsum2(a, I, 0) calculates the sum of mean square deviation of
%   the whole image.
%   
%   y = msdsum2(a, I, 1, E) calculates the sum of mean square deviation of the
%   maximum embryo region, which is specified by a binary matrix E.  In
%   this case, E is returned by function maxembryo().
%
%   y = msdsum2(a, I, 2, E) calculates the sum of mean square deviation of the
%   avearge embryo region, which is specified by a binary matrix E.  In
%   this case, E is returned by function avgembryo().
if nargin < 3
   error('Not enough input arguments.');
end

[nx, ny, nn] = size(I);

% Set up the array A and B, which has the same size as I.
for n = 1:nn
    I_n = I(:,:,n);
    % Choose B so that the mean of the concentration of each image is zero.
    if type == 0
        B(:,:,n) = ones(nx, ny) * mean(mean(I_n));
    else
        B(:,:,n) = ones(nx, ny) * mean(I_n(find(E)));
    end
    A(:,:,n) = ones(nx, ny) * a(n);
end

% Get the mean concentration of each pixel over all images.
c_mean = repmat(mean(((I - B) ./ A), 3), [1, 1, nn]);

% Get mean square deviation of whole images.
y = (I - A .* c_mean - B).^2;

% If type = 1, only consider the embryo region and discard the blank region when
% calculating mean square deviation.
if type ~= 0
    y = y.* repmat(E, [1, 1, nn]);
end

y = sum(sum(sum(y)))

end

%-------------------------------------------------------------------------

function C = conc_dmu(I, a,type,E)
%CONC Calculate the concentration (C), based on the intensity (I) and paramter a
%optimized by fminsearch.

[nx, ny, nn] = size(I);

B = ones(size(I));
A = ones(size(I));

for n = 1:nn
    I_n = I(:,:,n);
    % Choose B so that the mean of the concentration of each image is zero.
    if type == 0
        B(:,:,n) = ones(nx, ny) * mean(mean(I_n));
    else
        B(:,:,n) = ones(nx, ny) * mean(I_n(find(E)));
    end
    A(:,:,n) = ones(nx, ny) * a(n);
end

% for n = 1:nn
%     B(:,:,n) = ones(nx, ny) * mean(mean(I(:,:,n)));
%     A(:,:,n) = ones(nx, ny) * a(n);
% end

C_in = (I - B) ./ A;

C_in = -C_in - min(min(-mean(C_in,3)));

% mean_C_in = mean(C_in,3);
% 
% isort = sort(mean_C_in(find(E)),'ascend');
% isort(1:10000)
% mean_min_intens = mean(isort(1:80000))
% 
% C_in = C_in - mean_min_intens;
%

C = C_in;
end
%---------------------function to read in an image directory------------
function I = readimg(imgdir)
%READIMG Read images and output as an array.
%   I = readimg(imgdir) reads images in jpeg format in the directory
%   specified by imgdir, and output as an array I.  

files = dir(fullfile(imgdir,'*.tif'));

I = 0;

for n = 1:length(files)
    m = double(imread(sprintf('%s/%s', imgdir, files(n).name)));
    if (I == 0)
        I = m ;
    else
        I = cat(3, I, m); 
    end
end
end

