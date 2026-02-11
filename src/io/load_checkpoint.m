function [FS, last_completed_problem] = load_checkpoint(filepath)
% LOAD_CHECKPOINT Load experiment state from file
%
% Args:
%   filepath - Full path to checkpoint file
%
% Returns:
%   FS                     - The FS struct array
%   last_completed_problem - Index of last completed problem

    if ~exist(filepath, 'file')
        error('load_checkpoint:fileNotFound', 'Checkpoint file not found: %s', filepath);
    end

    checkpoint = load(filepath);

    assert(isfield(checkpoint, 'FS'), 'Invalid checkpoint: missing FS field');
    assert(isfield(checkpoint, 'last_completed_problem'), ...
        'Invalid checkpoint: missing last_completed_problem field');
    assert(isnumeric(checkpoint.last_completed_problem) && ...
        isscalar(checkpoint.last_completed_problem) && ...
        checkpoint.last_completed_problem >= 0, ...
        'Invalid checkpoint: last_completed_problem must be a non-negative numeric scalar');

    % CR-112/SEC-006: Deep validation of FS struct fields
    assert(isstruct(checkpoint.FS), 'Invalid checkpoint: FS must be a struct array');
    for k = 1:length(checkpoint.FS)
        assert(isfield(checkpoint.FS(k), 'P') && isnumeric(checkpoint.FS(k).P), ...
            'Invalid checkpoint: FS(%d).P must be numeric', k);
        assert(isfield(checkpoint.FS(k), 'lb') && isnumeric(checkpoint.FS(k).lb), ...
            'Invalid checkpoint: FS(%d).lb must be numeric', k);
        assert(isfield(checkpoint.FS(k), 'ub') && isnumeric(checkpoint.FS(k).ub), ...
            'Invalid checkpoint: FS(%d).ub must be numeric', k);
    end

    FS = checkpoint.FS;
    last_completed_problem = checkpoint.last_completed_problem;
end
