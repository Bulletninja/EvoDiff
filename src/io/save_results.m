function save_results(results, config)
% SAVE_RESULTS Save experiment results to MAT file
%
% Args:
%   results - Struct array from run_experiment()
%   config  - Config struct from load_config()

    results_dir = config.results_dir;
    if ~exist(results_dir, 'dir'), mkdir(results_dir); end

    timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
    filename = fullfile(results_dir, sprintf('results_%s.mat', timestamp));

    save(filename, 'results', 'config');
    fprintf('Results saved to: %s\n', filename);
end
