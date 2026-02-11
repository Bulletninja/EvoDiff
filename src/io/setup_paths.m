function setup_paths()
% SETUP_PATHS Add project directories to MATLAB/Octave path
%
% Call this function before running any scripts to ensure
% all project functions are accessible.

    root = fileparts(fileparts(mfilename('fullpath')));

    addpath(fullfile(root, 'src'));
    addpath(fullfile(root, 'src', 'core'));
    addpath(fullfile(root, 'src', 'experiment'));
    addpath(fullfile(root, 'src', 'io'));
    addpath(fullfile(root, 'scripts'));
    addpath(fullfile(root, 'tests'));
    addpath(fullfile(root, 'data'));
    addpath(fullfile(root, 'config'));

    fprintf('EvoDiff paths configured. Root: %s\n', root);
end
