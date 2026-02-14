function config = load_config(filepath)
% LOAD_CONFIG Load experiment configuration from JSON file
%
% Loads configuration from a JSON file and merges with defaults for any
% missing fields. Validates parameter ranges and types. Supports a
% 'variants' array for configurable algorithm comparison.
%
% Args:
%   filepath - Path to JSON config file (optional, uses defaults if omitted)
%
% Returns:
%   config - Struct with all configuration fields including .variants

    config = struct();
    config.population_size  = 500;
    config.max_generations  = 100;
    config.num_runs         = 30;
    config.selection_ratio  = 0.5;
    config.fitness_function = 'evaluate_makespan';
    config.problem_file     = 'data/taillard_20x5.json';
    config.random_seed      = [];
    config.results_dir      = 'results/';

    % Default variants: normal + selective (backward compatible)
    default_variant_normal = struct( ...
        'name', 'normal', ...
        'selective', false, ...
        'selection_ratio', 0.5, ...
        'init_method', 'neh', ...
        'crossover', 'ox1', ...
        'local_search', true, ...
        'local_search_interval', 10, ...
        'population_reduction', true);
    default_variant_selective = struct( ...
        'name', 'selective', ...
        'selective', true, ...
        'selection_ratio', 0.5, ...
        'init_method', 'neh', ...
        'crossover', 'ox1', ...
        'local_search', true, ...
        'local_search_interval', 10, ...
        'population_reduction', true);
    config.variants = [default_variant_normal, default_variant_selective];

    if nargin >= 1 && ~isempty(filepath)
        if ~exist(filepath, 'file')
            error('load_config:fileNotFound', 'Config file not found: %s', filepath);
        end

        text = fileread(filepath);
        user_config = jsondecode(text);

        % SEC-001/CR-013: Warn on unknown config fields before merging
        known_fields = {'population_size', 'max_generations', 'num_runs', ...
            'selection_ratio', 'fitness_function', 'problem_file', ...
            'random_seed', 'results_dir', 'variants', ...
            'selective', 'log_interval', 'save_results'};
        user_fields = fieldnames(user_config);
        unknown = setdiff(user_fields, known_fields);
        for i = 1:length(unknown)
            warning('load_config:unknownField', 'Unknown config field: %s', unknown{i});
        end

        % Merge scalar fields (not variants)
        scalar_fields = {'population_size', 'max_generations', 'num_runs', ...
            'selection_ratio', 'fitness_function', 'problem_file', ...
            'random_seed', 'results_dir'};
        for i = 1:length(scalar_fields)
            if isfield(user_config, scalar_fields{i})
                config.(scalar_fields{i}) = user_config.(scalar_fields{i});
            end
        end

        % Parse variants array
        if isfield(user_config, 'variants')
            raw_variants = user_config.variants;
            if isstruct(raw_variants)
                config.variants = raw_variants(:)';
            end
        end
    end

    % Validation runs unconditionally

    % SEC-001: Whitelist allowed fitness functions
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
    % CR-107: de_flowshop requires NP >= 2 for parent pair selection
    assert(config.population_size >= 2, 'population_size must be at least 2');
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

    % Variant validation
    ALLOWED_INIT = {'random', 'neh'};
    ALLOWED_CROSSOVER = {'column_diff', 'ox1'};
    assert(isstruct(config.variants) && ~isempty(config.variants), ...
        'variants must be a non-empty struct array');
    for v = 1:length(config.variants)
        assert(isfield(config.variants(v), 'name') && ischar(config.variants(v).name), ...
            sprintf('Variant %d must have a string "name" field', v));
        if isfield(config.variants(v), 'init_method')
            assert(ismember(config.variants(v).init_method, ALLOWED_INIT), ...
                sprintf('Variant %d: init_method must be one of: %s', v, strjoin(ALLOWED_INIT, ', ')));
        end
        if isfield(config.variants(v), 'crossover')
            assert(ismember(config.variants(v).crossover, ALLOWED_CROSSOVER), ...
                sprintf('Variant %d: crossover must be one of: %s', v, strjoin(ALLOWED_CROSSOVER, ', ')));
        end
        if isfield(config.variants(v), 'jade_p')
            assert(config.variants(v).jade_p > 0 && config.variants(v).jade_p <= 1, ...
                sprintf('Variant %d: jade_p must be in (0, 1]', v));
        end
        if isfield(config.variants(v), 'jade_c')
            assert(config.variants(v).jade_c > 0 && config.variants(v).jade_c <= 1, ...
                sprintf('Variant %d: jade_c must be in (0, 1]', v));
        end
    end
end
