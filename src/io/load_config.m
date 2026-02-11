function config = load_config(filepath)
% LOAD_CONFIG Load experiment configuration from JSON file
%
% Loads configuration from a JSON file and merges with defaults for any
% missing fields. Validates parameter ranges and types.
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

    if nargin >= 1 && ~isempty(filepath)
        if ~exist(filepath, 'file')
            error('load_config:fileNotFound', 'Config file not found: %s', filepath);
        end

        text = fileread(filepath);
        user_config = jsondecode(text);

        % SEC-001/CR-013: Warn on unknown config fields before merging
        known_fields = fieldnames(config);
        user_fields = fieldnames(user_config);
        unknown = setdiff(user_fields, known_fields);
        for i = 1:length(unknown)
            warning('load_config:unknownField', 'Unknown config field: %s', unknown{i});
        end

        % Only merge known fields (reject unknown field injection)
        for i = 1:length(known_fields)
            if isfield(user_config, known_fields{i})
                config.(known_fields{i}) = user_config.(known_fields{i});
            end
        end
    end

    % Validation runs unconditionally (defense-in-depth for defaults too)

    % SEC-001: Whitelist allowed fitness functions (prevents arbitrary feval execution)
    ALLOWED_FITNESS = {'evaluate_makespan'};
    assert(ischar(config.fitness_function), 'fitness_function must be a string');
    if ~ismember(config.fitness_function, ALLOWED_FITNESS)
        error('load_config:invalidFunction', ...
            'Fitness function "%s" not in allowed list: {%s}', ...
            config.fitness_function, strjoin(ALLOWED_FITNESS, ', '));
    end

    % Type validation
    assert(isnumeric(config.population_size) && isscalar(config.population_size), ...
        'population_size must be a numeric scalar');
    assert(isnumeric(config.max_generations) && isscalar(config.max_generations), ...
        'max_generations must be a numeric scalar');
    assert(isnumeric(config.num_runs) && isscalar(config.num_runs), ...
        'num_runs must be a numeric scalar');
    assert(ischar(config.results_dir), 'results_dir must be a string');
    assert(ischar(config.problem_file), 'problem_file must be a string');

    % Range validation
    assert(config.population_size > 0, 'population_size must be positive');
    assert(config.max_generations > 0, 'max_generations must be positive');
    assert(config.num_runs > 0, 'num_runs must be positive');
    assert(config.selection_ratio > 0 && config.selection_ratio <= 1, ...
        'selection_ratio must be in (0, 1]');

    % Path traversal validation
    assert(isempty(regexp(config.results_dir, '^\s*/')) && ...
           isempty(regexp(config.results_dir, '\.\.')), ...
        'results_dir must be a relative path without ".." traversal');
    assert(isempty(regexp(config.problem_file, '^\s*/')) && ...
           isempty(regexp(config.problem_file, '\.\.')), ...
        'problem_file must be a relative path without ".." traversal');
end
