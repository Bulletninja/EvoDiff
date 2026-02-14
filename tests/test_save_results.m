function test_save_results()
% TEST_SAVE_RESULTS - Unit tests for save_results.m

    fprintf('  Testing save_results...\n');

    addpath(genpath('src'));

    %% Test 1: Creates directory and saves .mat file
    fprintf('    [1/4] Creates dir and saves file...');
    tmp_dir = [tempname() '_test_save'];
    config = struct('results_dir', tmp_dir);
    results = struct('best', 42, 'data', [1 2 3]);

    save_results(results, config);

    assert(exist(tmp_dir, 'dir') == 7, 'Should create results directory');
    files = dir(fullfile(tmp_dir, 'results_*.mat'));
    assert(length(files) == 1, sprintf('Should create exactly 1 .mat file, got %d', length(files)));
    fprintf(' done\n');

    %% Test 2: Saved file contains both results and config
    fprintf('    [2/4] File contains results and config...');
    loaded = load(fullfile(tmp_dir, files(1).name));
    assert(isfield(loaded, 'results'), 'Saved file must contain results');
    assert(isfield(loaded, 'config'), 'Saved file must contain config');
    assert(loaded.results.best == 42, 'Results data should match');
    fprintf(' done\n');

    %% Test 3: Works with existing directory (no error)
    fprintf('    [3/4] Works with existing dir...');
    save_results(results, config);
    files2 = dir(fullfile(tmp_dir, 'results_*.mat'));
    assert(length(files2) >= 1, 'Should still have .mat files');
    fprintf(' done\n');

    %% Test 4: Filename contains timestamp
    fprintf('    [4/4] Filename has timestamp...');
    assert(~isempty(regexp(files(1).name, 'results_\d{4}-\d{2}-\d{2}_\d{6}\.mat')), ...
        'Filename should match results_YYYY-MM-DD_HHMMSS.mat pattern');
    fprintf(' done\n');

    % Cleanup
    rmdir(tmp_dir, 's');

    fprintf('  All save_results tests passed!\n');
end
