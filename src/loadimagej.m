function loadimagej

% For MATLAB-ImageJ integration, add appropriate directory to MATLAB path.
if ismac
    addpath('/Applications/Fiji.app/scripts');
elseif ispc
    tilde = getenv('userprofile');
    addpath(fullfile(tilde,'Fiji.app','scripts'));
end

%%% Ensure MATLAB is using Java 8.


ImageJ;

end