function setup_paths()
    % SETUP_PATHS Add project directories to MATLAB/Octave path
    %
    % Usage:
    %   setup_paths()
    %
    % Call this function before running any scripts to ensure
    % all project functions are accessible.

    % Get the directory where this file is located
    root = fileparts(mfilename('fullpath'));

    % Add source code directory
    addpath(fullfile(root, 'src'));

    % Add scripts directory
    addpath(fullfile(root, 'scripts'));

    % Add tests directory
    addpath(fullfile(root, 'tests'));

    % Add data directory (for loading .mat files)
    addpath(fullfile(root, 'data'));

    fprintf('EvoDiff paths configured. Root: %s\n', root);
end
