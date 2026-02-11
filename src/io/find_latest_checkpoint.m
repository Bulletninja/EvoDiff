function [latest_file, latest_problem] = find_latest_checkpoint(results_dir)
% FIND_LATEST_CHECKPOINT Find checkpoint with highest problem number
%
% Args:
%   results_dir - Directory containing checkpoint files
%
% Returns:
%   latest_file    - Full path to latest checkpoint (empty if none)
%   latest_problem - Problem number from latest checkpoint (0 if none)

    latest_file = '';
    latest_problem = 0;

    pattern = fullfile(results_dir, 'checkpoint_problem_*.mat');
    files = dir(pattern);

    if isempty(files)
        return;
    end

    % Extract problem numbers from all files and find max
    problem_nums = zeros(length(files), 1);
    for k = 1:length(files)
        [~, name, ~] = fileparts(files(k).name);
        tokens = regexp(name, 'checkpoint_problem_(\d+)', 'tokens');
        if ~isempty(tokens)
            problem_nums(k) = str2double(tokens{1}{1});
        end
    end

    [latest_problem, idx] = max(problem_nums);
    latest_file = fullfile(results_dir, files(idx).name);
end
