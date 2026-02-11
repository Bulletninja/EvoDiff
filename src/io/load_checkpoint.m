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
    assert(isnumeric(checkpoint.last_completed_problem), ...
        'Invalid checkpoint: last_completed_problem must be numeric');

    FS = checkpoint.FS;
    last_completed_problem = checkpoint.last_completed_problem;
end
