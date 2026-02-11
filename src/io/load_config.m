function config = load_config(filepath)
% LOAD_CONFIG Load experiment configuration from JSON file
%
% Loads configuration from a JSON file and merges with defaults for any
% missing fields. Validates parameter ranges.
%
% Args:
%   filepath - Path to JSON config file (optional, uses defaults if omitted)
%
% Returns:
%   config - Struct with all configuration fields

    config = struct();
    config.population_size  = 500;
    config.max_generations  = 100;
    config.num_runs         = 30;
    config.selective        = false;
    config.selection_ratio  = 0.5;
    config.fitness_function = 'evaluate_makespan';
    config.problem_file     = 'data/taillard_20x5.json';
    config.random_seed      = [];
    config.log_interval     = 10;
    config.save_results     = true;
    config.results_dir      = 'results/';

    if nargin < 1 || isempty(filepath)
        return;
    end

    if ~exist(filepath, 'file')
        error('load_config:fileNotFound', 'Config file not found: %s', filepath);
    end

    text = fileread(filepath);
    user_config = jsondecode(text);

    fields = fieldnames(user_config);
    for i = 1:length(fields)
        config.(fields{i}) = user_config.(fields{i});
    end

    assert(config.population_size > 0, 'population_size must be positive');
    assert(config.max_generations > 0, 'max_generations must be positive');
    assert(config.num_runs > 0, 'num_runs must be positive');
    assert(config.selection_ratio > 0 && config.selection_ratio <= 1, ...
        'selection_ratio must be in (0, 1]');
end
