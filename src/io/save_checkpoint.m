function save_checkpoint(filepath, FS, last_completed_problem)
% SAVE_CHECKPOINT Save experiment state to file for resume capability
%
% Args:
%   filepath               - Full path to checkpoint file
%   FS                     - The FS struct array with all problem data
%   last_completed_problem - Index of last completed problem

    checkpoint = struct();
    checkpoint.FS = FS;
    checkpoint.last_completed_problem = last_completed_problem;
    checkpoint.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    checkpoint.version = '1.0';

    save(filepath, '-struct', 'checkpoint');
end
