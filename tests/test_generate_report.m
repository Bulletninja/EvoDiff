function test_generate_report()
% TEST_GENERATE_REPORT - Unit tests for generate_report.m

    fprintf('  Testing generate_report...\n');

    addpath(genpath('src'));

    % Build minimal results struct matching run_experiment output format
    P = [54 83 15 71 77; 79 3 11 99 56; 16 89 49 15 89];
    num_runs = 2;
    max_gen = 5;

    results(1).P = P;
    results(1).lb = 300;
    results(1).ub = 350;
    results(1).variants(1).name = 'normal';
    results(1).variants(1).stats.vals = repmat(linspace(400, 360, max_gen), num_runs, 1);
    results(1).variants(1).stats.errlb = [60; 65];
    results(1).variants(1).stats.errub = [10; 15];
    results(1).variants(1).stats.nfevals = [500; 500];
    results(1).variants(2).name = 'selective';
    results(1).variants(2).stats.vals = repmat(linspace(410, 370, max_gen), num_runs, 1);
    results(1).variants(2).stats.errlb = [70; 75];
    results(1).variants(2).stats.errub = [20; 25];
    results(1).variants(2).stats.nfevals = [500; 500];

    tmp_dir = [tempname() '_test_report'];
    mkdir(tmp_dir);
    config = struct();
    config.results_dir = tmp_dir;
    config.population_size = 20;
    config.max_generations = max_gen;
    config.fitness_function = 'evaluate_makespan';
    config.selection_ratio = 0.5;
    v1 = struct('name', 'normal', 'selective', false, 'selection_ratio', 0.5, ...
        'init_method', 'neh', 'crossover', 'ox1', 'local_search', false, ...
        'local_search_interval', 10, 'population_reduction', false);
    v2 = struct('name', 'selective', 'selective', true, 'selection_ratio', 0.5, ...
        'init_method', 'neh', 'crossover', 'ox1', 'local_search', false, ...
        'local_search_interval', 10, 'population_reduction', false);
    config.variants = [v1, v2];

    %% Test 1: Creates tables and figures directories
    fprintf('    [1/4] Creates output dirs...');
    generate_report(results, config);

    tables_dir = fullfile(tmp_dir, 'tables');
    figures_dir = fullfile(tmp_dir, 'figures');
    assert(exist(tables_dir, 'dir') == 7, 'Should create tables/ directory');
    assert(exist(figures_dir, 'dir') == 7, 'Should create figures/ directory');
    fprintf(' done\n');

    %% Test 2: Per-problem LaTeX table created
    fprintf('    [2/4] LaTeX table created...');
    tex_file = fullfile(tables_dir, 'taillard_1.tex');
    assert(exist(tex_file, 'file') == 2, 'Should create taillard_1.tex');
    tex_content = fileread(tex_file);
    assert(~isempty(strfind(tex_content, '\begin{table}')), 'Should contain LaTeX table env');
    assert(~isempty(strfind(tex_content, 'Lower Bound')), 'Should contain Lower Bound row');
    assert(~isempty(strfind(tex_content, '300')), 'Should contain LB value 300');
    assert(~isempty(strfind(tex_content, '350')), 'Should contain UB value 350');
    fprintf(' done\n');

    %% Test 3: Cross-variant comparison table
    fprintf('    [3/4] Variant comparison table...');
    comp_file = fullfile(tables_dir, 'variant_comparison.tex');
    assert(exist(comp_file, 'file') == 2, 'Should create variant_comparison.tex');
    comp_content = fileread(comp_file);
    assert(~isempty(strfind(comp_content, 'normal')), 'Should contain variant name normal');
    assert(~isempty(strfind(comp_content, 'selective')), 'Should contain variant name selective');
    assert(~isempty(strfind(comp_content, 'ARPD')), 'Should contain ARPD summary');
    fprintf(' done\n');

    %% Test 4: Convergence plot created
    fprintf('    [4/4] Convergence plot...');
    conv_file = fullfile(figures_dir, 'convergence_1.png');
    assert(exist(conv_file, 'file') == 2, 'Should create convergence_1.png');
    fprintf(' done\n');

    % Cleanup
    rmdir(tmp_dir, 's');

    fprintf('  All generate_report tests passed!\n');
end
