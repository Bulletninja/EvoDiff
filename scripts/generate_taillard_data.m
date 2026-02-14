% Generate Taillard benchmark data from published seeds
% Reference: Taillard (1993), "Benchmarks for basic scheduling problems"

function generate_taillard_data()
    % Taillard's RNG parameters
    m = 2147483647; a = 16807; b = 127773; c = 2836;

    % Seeds for ta011-ta020 (20 jobs, 10 machines)
    seeds_20x10 = [587595453, 1401007982, 873136276, 268827376, 1634173168, ...
                   691823909, 73807235, 1273398721, 2065119309, 1672900551];

    % Seeds for ta021-ta030 (20 jobs, 20 machines)
    seeds_20x20 = [479340445, 268827376, 1958948863, 918272953, 555010963, ...
                   2010851491, 1519833303, 1748670931, 1923497586, 1829909967];

    % Seeds for ta001-ta010 (20 jobs, 5 machines) — for verification
    seeds_20x5 = [873654221, 379008056, 1866992158, 216771124, 495070989, ...
                  402959317, 1369363414, 2021925980, 573109518, 88325120];

    % Verify against existing data first
    fprintf('Verifying 20x5 generation against existing data...\n');
    verify_20x5(seeds_20x5, m, a, b, c);

    % Generate 20x10
    fprintf('Generating 20x10 data (ta011-ta020)...\n');
    problems_20x10 = generate_set(seeds_20x10, 20, 10, 11, m, a, b, c);
    write_json('data/taillard_20x10.json', problems_20x10, 20, 10, ...
        'Taillard benchmark instances for 20-job, 10-machine flow shop scheduling');

    % Generate 20x20
    fprintf('Generating 20x20 data (ta021-ta030)...\n');
    problems_20x20 = generate_set(seeds_20x20, 20, 20, 21, m, a, b, c);
    write_json('data/taillard_20x20.json', problems_20x20, 20, 20, ...
        'Taillard benchmark instances for 20-job, 20-machine flow shop scheduling');

    fprintf('Done.\n');
end

function problems = generate_set(seeds, N, M, id_offset, m, a, b, c)
    problems = {};
    for k = 1:length(seeds)
        seed = seeds(k);
        P = zeros(M, N);
        for i = 1:M
            for j = 1:N
                [seed, val] = taillard_unif(seed, 1, 99, m, a, b, c);
                P(i, j) = val;
            end
        end
        problems{k}.id = id_offset + k - 1;
        problems{k}.machines = M;
        problems{k}.jobs = N;
        problems{k}.P = P;
    end
end

function [seed, val] = taillard_unif(seed, low, high, m, a, b, c)
    k_val = floor(seed / b);
    seed = a * mod(seed, b) - k_val * c;
    if seed < 0
        seed = seed + m;
    end
    value_0_1 = seed / m;
    val = low + floor(value_0_1 * (high - low + 1));
end

function verify_20x5(seeds, m, a, b, c)
    % Generate ta001 and compare with existing JSON
    seed = seeds(1);
    P = zeros(5, 20);
    for i = 1:5
        for j = 1:20
            [seed, val] = taillard_unif(seed, 1, 99, m, a, b, c);
            P(i, j) = val;
        end
    end

    % Load existing
    existing = jsondecode(fileread('data/taillard_20x5.json'));
    pt = existing.problems(1).processing_times;
    if iscell(pt)
        P_existing = zeros(length(pt), length(pt{1}));
        for row = 1:length(pt)
            P_existing(row, :) = pt{row}(:)';
        end
    else
        P_existing = pt;
    end

    if isequal(P, P_existing)
        fprintf('  VERIFIED: Generated ta001 matches existing data.\n');
    else
        fprintf('  MISMATCH!\n');
        fprintf('  Generated P(1,1:5): %s\n', mat2str(P(1, 1:5)));
        fprintf('  Existing  P(1,1:5): %s\n', mat2str(P_existing(1, 1:5)));
        error('Verification failed');
    end
end

function write_json(filepath, problems, N, M, description)
    fid = fopen(filepath, 'w');
    fprintf(fid, '{\n');
    fprintf(fid, '  "description": "%s",\n', description);
    fprintf(fid, '  "source": "Taillard, E. (1993). Benchmarks for basic scheduling problems",\n');
    fprintf(fid, '  "problems": [\n');

    for k = 1:length(problems)
        p = problems{k};
        fprintf(fid, '    {\n');
        fprintf(fid, '      "id": %d,\n', p.id);
        fprintf(fid, '      "machines": %d,\n', p.machines);
        fprintf(fid, '      "jobs": %d,\n', p.jobs);
        fprintf(fid, '      "processing_times": [\n');
        for i = 1:M
            fprintf(fid, '        [');
            for j = 1:N
                fprintf(fid, '%d', p.P(i, j));
                if j < N
                    fprintf(fid, ', ');
                end
            end
            fprintf(fid, ']');
            if i < M
                fprintf(fid, ',');
            end
            fprintf(fid, '\n');
        end
        fprintf(fid, '      ],\n');
        fprintf(fid, '      "lower_bound": 0,\n');
        fprintf(fid, '      "upper_bound": 0\n');
        fprintf(fid, '    }');
        if k < length(problems)
            fprintf(fid, ',');
        end
        fprintf(fid, '\n');
    end

    fprintf(fid, '  ]\n');
    fprintf(fid, '}\n');
    fclose(fid);
    fprintf('  Written: %s\n', filepath);
end
