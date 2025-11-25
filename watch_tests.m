function watch_tests(varargin)
% WATCH_TESTS - Continuous test runner that watches for file changes
%
% Usage:
%   watch_tests()              - Watch all .m files, run all tests
%   watch_tests('interval', 2) - Check every 2 seconds (default: 3)
%
% This function monitors source files and test files for changes.
% When a change is detected, it automatically runs the test suite.
%
% Press Ctrl+C to stop watching.

    % Parse arguments
    interval = 3;  % Default check interval in seconds
    for i = 1:2:length(varargin)
        if strcmp(varargin{i}, 'interval')
            interval = varargin{i+1};
        end
    end

    fprintf('========================================\n');
    fprintf('EvoDiff Continuous Test Watcher\n');
    fprintf('========================================\n');
    fprintf('Watching for changes every %d seconds...\n', interval);
    fprintf('Press Ctrl+C to stop\n\n');

    % Get initial file modification times
    last_check = containers.Map();
    files_to_watch = [
        dir('*.m');
        dir('tests/*.m')
    ];

    % Initialize timestamps
    for i = 1:length(files_to_watch)
        if ~files_to_watch(i).isdir
            fullpath = fullfile(files_to_watch(i).folder, files_to_watch(i).name);
            last_check(fullpath) = files_to_watch(i).datenum;
        end
    end

    % Run tests once at startup
    fprintf('Running initial tests...\n');
    run_tests();

    % Watch loop
    iteration = 0;
    while true
        pause(interval);
        iteration = iteration + 1;

        % Refresh file list
        files_to_watch = [
            dir('*.m');
            dir('tests/*.m')
        ];

        changed_files = {};

        % Check for modifications
        for i = 1:length(files_to_watch)
            if files_to_watch(i).isdir
                continue;
            end

            fullpath = fullfile(files_to_watch(i).folder, files_to_watch(i).name);
            current_time = files_to_watch(i).datenum;

            % New file or modified file
            if ~isKey(last_check, fullpath) || last_check(fullpath) < current_time
                changed_files{end+1} = files_to_watch(i).name;
                last_check(fullpath) = current_time;
            end
        end

        % If changes detected, run tests
        if ~isempty(changed_files)
            fprintf('\n========================================\n');
            fprintf('[%s] Changes detected:\n', datestr(now, 'HH:MM:SS'));
            for i = 1:length(changed_files)
                fprintf('  - %s\n', changed_files{i});
            end
            fprintf('========================================\n\n');

            % Clear changed functions from memory
            for i = 1:length(changed_files)
                fname = changed_files{i}(1:end-2);  % Remove .m
                if exist(fname, 'file')
                    clear(fname);
                end
            end

            % Run tests
            results = run_tests();

            % Bell sound on failure (if supported)
            if ~results.success
                fprintf('\a');  % Bell character
            end
        else
            % Show we're still watching
            if mod(iteration, 10) == 0
                fprintf('[%s] Still watching... (checked %d times)\n', ...
                    datestr(now, 'HH:MM:SS'), iteration);
            end
        end
    end
end
