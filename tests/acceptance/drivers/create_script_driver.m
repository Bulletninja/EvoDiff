function driver = create_script_driver()
% CREATE_SCRIPT_DRIVER Layer 3 driver: CLI execution (integration validation)
%
% Each action: saves input to temp .mat -> writes temp .m script ->
% runs via system('octave ...') -> loads output from temp .mat.
% Uses SCRIPT_OK sentinel in stdout to verify successful execution.
% Verification functions are shared with function driver via verify_helpers().

    this_dir = fileparts(mfilename('fullpath'));
    root = fileparts(fileparts(fileparts(this_dir)));

    % Solver actions (via CLI)
    driver.optimize = @(problem, opts) script_optimize(problem, opts, root);
    driver.evaluate_schedule = @(schedule) script_evaluate(schedule, root);
    driver.create_random_schedule = @(problem) script_random_schedule(problem, root);

    % Problem loading (via CLI)
    driver.load_taillard = @() script_load_taillard(root);
    driver.load_taillard_instance = @(n) script_load_taillard_instance(n, root);
    driver.small_instance = @do_small_instance;
    driver.problem_dimensions = @(problem) size(problem.P);
    driver.problem_bounds = @(problem) struct('lower', problem.lb, 'upper', problem.ub);

    % Configuration (via CLI)
    driver.load_defaults = @() script_load_config('', root);
    driver.load_config_file = @(path) script_load_config(path, root);
    driver.load_quick_test = @() script_load_config('config/quick_test.json', root);

    % Experiment (via CLI)
    driver.run_experiment = @(problems, config) script_run_experiment(problems, config, root);

    % Verification helpers (shared)
    h = verify_helpers();
    driver.verify_equals = h.verify_equals;
    driver.verify_within_bounds = h.verify_within_bounds;
    driver.verify_improves_over_time = h.verify_improves_over_time;
    driver.verify_is_valid_schedule = h.verify_is_valid_schedule;
    driver.verify_less_than = h.verify_less_than;
    driver.verify_has_field = h.verify_has_field;
    driver.verify_has_size = h.verify_has_size;
    driver.verify_is_true = h.verify_is_true;
end


%% Script execution helpers

function run_octave_script(script_file, root)
    cmd = sprintf('octave --no-gui --norc "%s" 2>&1', script_file);
    [status, output] = system(cmd);
    if status ~= 0 || isempty(strfind(output, 'SCRIPT_OK'))
        error('Script failed (status=%d):\n%s', status, output);
    end
end

% SEC-002: Escape single quotes to prevent code injection in generated .m files
function safe = escape_octave_string(s)
    safe = strrep(s, '''', '''''');
end

function write_preamble(fid, root, input_file)
    fprintf(fid, 'cd(''%s'');\n', escape_octave_string(root));
    fprintf(fid, 'setup_paths();\n');
    if ~isempty(input_file)
        fprintf(fid, 'load(''%s'');\n', escape_octave_string(input_file));
    end
end

function write_epilogue(fid, output_file, varname)
    fprintf(fid, 'save(''%s'', ''%s'');\n', escape_octave_string(output_file), varname);
    fprintf(fid, 'fprintf(''SCRIPT_OK\\n'');\n');
end

% SEC-004: Clean up temp files after use
function cleanup_temp_files(varargin)
    for i = 1:length(varargin)
        if exist(varargin{i}, 'file'), delete(varargin{i}); end
    end
end


%% CLI domain actions

function result = script_optimize(problem, opts, root)
    base = tempname();
    input_file = [base '_in.mat'];
    output_file = [base '_out.mat'];
    script_file = [base '_run.m'];

    save(input_file, 'problem', 'opts');

    fid = fopen(script_file, 'w');
    write_preamble(fid, root, input_file);
    fprintf(fid, 'selective = false;\n');
    fprintf(fid, 'if isfield(opts, ''selective''), selective = opts.selective; end\n');
    fprintf(fid, 'selection_ratio = 0.5;\n');
    fprintf(fid, 'if isfield(opts, ''selection_ratio''), selection_ratio = opts.selection_ratio; end\n');
    fprintf(fid, '[best_ind, best_fit, num_evals, difflb, diffub, best_per_gen] = de_flowshop(problem, opts.population_size, opts.max_generations, ''evaluate_makespan'', selective, selection_ratio);\n');
    fprintf(fid, 'result.best_schedule = best_ind;\n');
    fprintf(fid, 'result.best_makespan = best_fit;\n');
    fprintf(fid, 'result.num_evaluations = num_evals;\n');
    fprintf(fid, 'result.diff_lower_bound = difflb;\n');
    fprintf(fid, 'result.diff_upper_bound = diffub;\n');
    fprintf(fid, 'result.best_per_generation = best_per_gen;\n');
    write_epilogue(fid, output_file, 'result');
    fclose(fid);

    run_octave_script(script_file, root);
    loaded = load(output_file);
    result = loaded.result;
    cleanup_temp_files(input_file, output_file, script_file);
end

function result = script_evaluate(schedule, root)
    base = tempname();
    input_file = [base '_in.mat'];
    output_file = [base '_out.mat'];
    script_file = [base '_run.m'];

    save(input_file, 'schedule');

    fid = fopen(script_file, 'w');
    write_preamble(fid, root, input_file);
    fprintf(fid, 'result = evaluate_makespan(schedule);\n');
    write_epilogue(fid, output_file, 'result');
    fclose(fid);

    run_octave_script(script_file, root);
    loaded = load(output_file);
    result = loaded.result;
    cleanup_temp_files(input_file, output_file, script_file);
end

function schedule = script_random_schedule(problem, root)
    base = tempname();
    input_file = [base '_in.mat'];
    output_file = [base '_out.mat'];
    script_file = [base '_run.m'];

    save(input_file, 'problem');

    fid = fopen(script_file, 'w');
    write_preamble(fid, root, input_file);
    fprintf(fid, 'flat = random_permutation(problem.P);\n');
    fprintf(fid, '[M, N] = size(problem.P);\n');
    fprintf(fid, 'schedule = reshape(flat, M, N);\n');
    write_epilogue(fid, output_file, 'schedule');
    fclose(fid);

    run_octave_script(script_file, root);
    loaded = load(output_file);
    schedule = loaded.schedule;
    cleanup_temp_files(input_file, output_file, script_file);
end

function problems = script_load_taillard(root)
    base = tempname();
    output_file = [base '_out.mat'];
    script_file = [base '_run.m'];

    fid = fopen(script_file, 'w');
    write_preamble(fid, root, '');
    fprintf(fid, 'problems = load_problems(''data/taillard_20x5.json'');\n');
    write_epilogue(fid, output_file, 'problems');
    fclose(fid);

    run_octave_script(script_file, root);
    loaded = load(output_file);
    problems = loaded.problems;
    cleanup_temp_files(output_file, script_file);
end

function problem = script_load_taillard_instance(n, root)
    base = tempname();
    output_file = [base '_out.mat'];
    script_file = [base '_run.m'];

    fid = fopen(script_file, 'w');
    write_preamble(fid, root, '');
    fprintf(fid, 'problems = load_problems(''data/taillard_20x5.json'');\n');
    fprintf(fid, 'problem = problems(%d);\n', n);
    write_epilogue(fid, output_file, 'problem');
    fclose(fid);

    run_octave_script(script_file, root);
    loaded = load(output_file);
    problem = loaded.problem;
    cleanup_temp_files(output_file, script_file);
end

function config = script_load_config(filepath, root)
    base = tempname();
    output_file = [base '_out.mat'];
    script_file = [base '_run.m'];

    fid = fopen(script_file, 'w');
    write_preamble(fid, root, '');
    if isempty(filepath)
        fprintf(fid, 'config = load_config();\n');
    else
        fprintf(fid, 'config = load_config(''%s'');\n', escape_octave_string(filepath));
    end
    write_epilogue(fid, output_file, 'config');
    fclose(fid);

    run_octave_script(script_file, root);
    loaded = load(output_file);
    config = loaded.config;
    cleanup_temp_files(output_file, script_file);
end

function exp_results = script_run_experiment(problems, config, root)
    base = tempname();
    input_file = [base '_in.mat'];
    output_file = [base '_out.mat'];
    script_file = [base '_run.m'];

    save(input_file, 'problems', 'config');

    fid = fopen(script_file, 'w');
    write_preamble(fid, root, input_file);
    fprintf(fid, 'exp_results = run_experiment(problems, config);\n');
    write_epilogue(fid, output_file, 'exp_results');
    fclose(fid);

    run_octave_script(script_file, root);
    loaded = load(output_file);
    exp_results = loaded.exp_results;
    cleanup_temp_files(input_file, output_file, script_file);
end
