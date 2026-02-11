function results = run_acceptance_tests(driver_type)
% RUN_ACCEPTANCE_TESTS Runner: driver selection + spec discovery
%
% Usage:
%   run_acceptance_tests('function')  - Direct function calls (fast, reference)
%   run_acceptance_tests('script')    - CLI execution (integration validation)

    if nargin < 1
        driver_type = 'function';
    end

    setup_paths();

    % Create driver (Layer 3)
    switch driver_type
        case 'function'
            driver = create_function_driver();
        case 'script'
            driver = create_script_driver();
        otherwise
            error('Unknown driver type: %s. Use ''function'' or ''script''.', driver_type);
    end

    % Build context (Layer 2)
    ctx = create_context(driver);

    % Discover specs (Layer 1)
    runner_dir = fileparts(mfilename('fullpath'));
    spec_files = dir(fullfile(runner_dir, 'specs', 'spec_*.m'));

    total_pass = 0;
    total_fail = 0;
    all_details = {};

    fprintf('\n========================================\n');
    fprintf('Acceptance Tests (%s driver)\n', driver_type);
    fprintf('========================================\n\n');

    for i = 1:length(spec_files)
        spec_name = spec_files(i).name(1:end-2);
        fprintf('  %s\n', spec_name);

        tic;
        [np, nf, res] = feval(spec_name, ctx);
        elapsed = toc;

        total_pass = total_pass + np;
        total_fail = total_fail + nf;
        all_details{end+1} = struct('spec', spec_name, 'results', {res});

        for j = 1:length(res)
            if strcmp(res{j}.status, 'PASS')
                fprintf('    PASS: %s\n', res{j}.name);
            else
                fprintf('    FAIL: %s — %s\n', res{j}.name, res{j}.message);
            end
        end
        fprintf('    (%.2fs)\n\n', elapsed);
    end

    fprintf('========================================\n');
    fprintf('Acceptance Results (%s driver):\n', driver_type);
    fprintf('  Passed: %d\n', total_pass);
    fprintf('  Failed: %d\n', total_fail);
    fprintf('========================================\n\n');

    results.passed = total_pass;
    results.failed = total_fail;
    results.details = all_details;
    results.success = (total_fail == 0);
end
