function test_checkpoint()
% TEST_CHECKPOINT - Test checkpoint save/load functionality
%
% Tests production functions: save_checkpoint, load_checkpoint,
% find_latest_checkpoint from src/io/.

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

    % Save checkpoint (production function from src/io/)
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
