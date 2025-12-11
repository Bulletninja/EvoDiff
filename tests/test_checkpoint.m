function test_checkpoint()
% TEST_CHECKPOINT - Test checkpoint save/load functionality
%
% Tests:
%   1. save_checkpoint creates file
%   2. load_checkpoint reads correct data
%   3. find_latest_checkpoint finds most recent

    fprintf('  Testing checkpoint functionality...\n');

    % Setup - create temp directory
    test_dir = fullfile(tempdir(), 'evodiff_test_checkpoints');
    if ~exist(test_dir, 'dir')
        mkdir(test_dir);
    end

    % Clean any old test files
    old_files = dir(fullfile(test_dir, 'checkpoint_*.mat'));
    for k = 1:length(old_files)
        delete(fullfile(test_dir, old_files(k).name));
    end

    %% Test 1: save_checkpoint creates file
    fprintf('    [1/4] Save checkpoint test...');

    % Create mock FS struct
    FS_mock = struct();
    FS_mock(1).P = [1 2 3; 4 5 6];
    FS_mock(1).lb = 10;
    FS_mock(1).stats.errlb = [1, 2, 3];

    % Save checkpoint
    checkpoint_file = fullfile(test_dir, 'checkpoint_problem_01.mat');
    save_checkpoint(checkpoint_file, FS_mock, 1);

    assert(exist(checkpoint_file, 'file') == 2, 'Checkpoint file should exist');
    fprintf(' done\n');

    %% Test 2: load_checkpoint reads correct data
    fprintf('    [2/4] Load checkpoint test...');

    [loaded_FS, loaded_problem] = load_checkpoint(checkpoint_file);

    assert(loaded_problem == 1, 'Problem number should be 1');
    assert(loaded_FS(1).lb == 10, 'Lower bound should be 10');
    assert(isequal(loaded_FS(1).stats.errlb, [1, 2, 3]), 'Stats should match');
    fprintf(' done\n');

    %% Test 3: find_latest_checkpoint finds most recent
    fprintf('    [3/4] Find latest checkpoint test...');

    % Create a second checkpoint
    pause(0.1);  % Ensure different timestamp
    checkpoint_file2 = fullfile(test_dir, 'checkpoint_problem_03.mat');
    FS_mock(1).lb = 30;  % Different value
    save_checkpoint(checkpoint_file2, FS_mock, 3);

    [latest_file, latest_problem] = find_latest_checkpoint(test_dir);

    assert(latest_problem == 3, 'Should find problem 3 as latest');
    assert(~isempty(strfind(latest_file, 'problem_03')), 'Should find correct file');
    fprintf(' done\n');

    %% Test 4: No checkpoint returns empty
    fprintf('    [4/4] No checkpoint test...');

    empty_dir = fullfile(tempdir(), 'evodiff_empty_test');
    if ~exist(empty_dir, 'dir')
        mkdir(empty_dir);
    end

    [latest_file, latest_problem] = find_latest_checkpoint(empty_dir);

    assert(isempty(latest_file), 'Should return empty for no checkpoints');
    assert(latest_problem == 0, 'Should return 0 for no checkpoints');
    fprintf(' done\n');

    % Cleanup
    rmdir(test_dir, 's');
    if exist(empty_dir, 'dir')
        rmdir(empty_dir, 's');
    end

    fprintf('  All checkpoint tests passed!\n');
end


%% Helper functions to test (will be in separate file later)

function save_checkpoint(filepath, FS, last_completed_problem)
% SAVE_CHECKPOINT - Save experiment state to file
%
% Args:
%   filepath: Full path to checkpoint file
%   FS: The FS struct array with all problem data
%   last_completed_problem: Index of last completed problem (1-10)

    checkpoint = struct();
    checkpoint.FS = FS;
    checkpoint.last_completed_problem = last_completed_problem;
    checkpoint.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    checkpoint.version = '1.0';

    save(filepath, '-struct', 'checkpoint');
end


function [FS, last_completed_problem] = load_checkpoint(filepath)
% LOAD_CHECKPOINT - Load experiment state from file
%
% Args:
%   filepath: Full path to checkpoint file
%
% Returns:
%   FS: The FS struct array
%   last_completed_problem: Index of last completed problem

    if ~exist(filepath, 'file')
        error('Checkpoint file not found: %s', filepath);
    end

    checkpoint = load(filepath);
    FS = checkpoint.FS;
    last_completed_problem = checkpoint.last_completed_problem;
end


function [latest_file, latest_problem] = find_latest_checkpoint(results_dir)
% FIND_LATEST_CHECKPOINT - Find checkpoint with highest problem number
%
% Args:
%   results_dir: Directory containing checkpoint files
%
% Returns:
%   latest_file: Full path to latest checkpoint (empty if none)
%   latest_problem: Problem number from latest checkpoint (0 if none)

    latest_file = '';
    latest_problem = 0;

    % Look for checkpoint files
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

    % Find highest problem number
    [latest_problem, idx] = max(problem_nums);
    latest_file = fullfile(results_dir, files(idx).name);
end
