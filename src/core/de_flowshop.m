function [best_individual, best_fitness, num_evals, difflb, diffub, best_per_gen, pop_snapshots] = de_flowshop(Prob, NP, max_generations, f, selective, selection_ratio, variant)
% DE_FLOWSHOP Differential Evolution for permutation-based flow shop scheduling
%
% Minimizes makespan using a permutation-based DE with configurable
% initialization, crossover, local search, and population reduction.
%
% Args:
%   Prob            - Problem struct with fields: .P (processing times), .lb, .ub
%   NP              - Population size
%   max_generations - Maximum number of generations
%   f               - Fitness function name (string, e.g. 'evaluate_makespan')
%   selective       - If true, only mutate a fraction of population
%   selection_ratio - Fraction of population to mutate when selective (default 0.5)
%   variant         - (Optional) Struct controlling algorithm configuration:
%                     .init_method: 'random' | 'neh' (default: 'neh')
%                     .crossover:   'column_diff' | 'ox1' (default: 'ox1')
%                     .local_search: true | false (default: true)
%                     .local_search_interval: integer (default: 10)
%                     .population_reduction: true | false (default: true)
%                     .selective: overrides 5th arg if present
%                     .selection_ratio: overrides 6th arg if present
%
% Returns:
%   best_individual - Best solution found (M x N matrix)
%   best_fitness    - Fitness value of best solution
%   num_evals       - Total number of fitness evaluations
%   difflb          - Difference from lower bound
%   diffub          - Difference from upper bound
%   best_per_gen    - Best fitness at each generation
%   pop_snapshots   - (Optional) Cell array of population matrices per generation

% CR-009: default selection_ratio to 0.5 for backward compatibility
if nargin < 6 || isempty(selection_ratio)
    selection_ratio = 0.5;
end

% Variant defaults (full hybrid)
init_method = 'neh';
crossover_op = 'ox1';
use_local_search = true;
ls_interval = 10;
use_pop_reduction = true;
use_jade = false;
jade_c = 0.1;
jade_p = 0.1;

% Override from variant struct if provided
if nargin >= 7 && isstruct(variant)
    if isfield(variant, 'selective')
        selective = variant.selective;
    end
    if isfield(variant, 'selection_ratio')
        selection_ratio = variant.selection_ratio;
    end
    if isfield(variant, 'init_method')
        init_method = variant.init_method;
    end
    if isfield(variant, 'crossover')
        crossover_op = variant.crossover;
    end
    if isfield(variant, 'local_search')
        use_local_search = variant.local_search;
    end
    if isfield(variant, 'local_search_interval')
        ls_interval = variant.local_search_interval;
    end
    if isfield(variant, 'population_reduction')
        use_pop_reduction = variant.population_reduction;
    end
    if isfield(variant, 'jade')
        use_jade = variant.jade;
    end
    if isfield(variant, 'jade_c')
        jade_c = variant.jade_c;
    end
    if isfield(variant, 'jade_p')
        jade_p = variant.jade_p;
    end
end

J = Prob.P;
[M, N] = size(J);

% CR-010: input validation
assert(NP >= 2, 'Population size must be at least 2');
assert(max_generations >= 1, 'max_generations must be at least 1');
assert(M > 0 && N > 0, 'Processing times matrix must not be empty');

best_per_gen = zeros(1, max_generations);

% Optional population snapshots (only when 7th output requested)
capture_snapshots = (nargout >= 7);
if capture_snapshots
    pop_snapshots = cell(max_generations + 1, 1);
else
    pop_snapshots = {};
end

generation = 1;

% Initialize population: each column is a flattened job matrix
population = zeros(M*N, NP);
if strcmp(init_method, 'neh')
    % ALG-001: seed first member with NEH heuristic
    population(:,1) = neh_heuristic(J);
    start_idx = 2;
else
    start_idx = 1;
end
for i = start_idx:NP
    population(:,i) = random_permutation(J);
end

fitness          = zeros(NP, 1);
best_individual  = zeros(M*N, 1);
num_evals        = 0;

% Convert string to function handle for performance (CR-016)
if ischar(f)
    f = str2func(f);
end

% Initial evaluation
for i = 1:NP
    fitness(i) = f(reshape(population(:,i), M, N));
end
num_evals = num_evals + NP;

% Sort population by fitness
[fitness, sort_idx] = sort(fitness);
population = population(:, sort_idx);
best_fitness = fitness(1);
best_individual = population(:, 1);

% Snapshot gen 0 (initial population)
if capture_snapshots
    pop_snapshots{1} = population;
end

% Pre-allocate offspring matrix
ui  = zeros(M*N, NP);

% ALG-005: linear population reduction parameters
NP_init = NP;
NP_min = max(4, round(NP * 0.1));

% Shuffling indices
rot = (0:1:NP-1);

% CR-102: Selective breeding (truncation selection)
mid = NP;
if selective
    mid = ceil(selection_ratio * NP);
end

% ALG-003: JADE adaptive parameters
if use_jade
    mu_CR = 0.5;
    mu_F = 0.5;
    archive = zeros(M*N, 0);  % empty archive
    archive_max = NP_init;
end

while generation <= max_generations
    % CR-003: select parent pairs via rotation with safe offset
    offset = randi(NP - 1);
    a1  = randperm(NP);
    rt  = rem(rot + offset, NP);
    a2  = a1(rt + 1);

    % Parent vectors (indexing creates copies; no need for old_population)
    mp1 = population(:, a1);
    mp2 = population(:, a2);

    % CR-006: store actual parent fitness for standard DE selection
    parent_fitness = fitness(a1(1:mid));

    % ALG-003: JADE per-generation success tracking
    if use_jade
        S_CR = [];
        S_F = [];
    end

    % Generate offspring and select
    for i = 1:mid
        if use_jade
            % Sample CR_i ~ N(mu_CR, 0.1), clamp to [0, 1]
            CR_i = mu_CR + 0.1 * randn();
            CR_i = max(0, min(1, CR_i));
            % Sample F_i ~ Cauchy(mu_F, 0.1), clamp to (0, 2]
            F_i = mu_F + 0.1 * tan(pi * (rand() - 0.5));
            while F_i <= 0
                F_i = mu_F + 0.1 * tan(pi * (rand() - 0.5));
            end
            F_i = min(F_i, 2);

            % DE/current-to-pbest/1 for permutations:
            % Pick pbest from top p fraction
            p_count = max(1, round(jade_p * NP));
            pbest_idx = randi(p_count);  % population is sorted, so 1:p_count are best

            % Build donor from 3 sources: current, pbest, archive+pop random
            current = mp1(:,i);
            pbest = population(:, pbest_idx);

            % Random from population ∪ archive (different from current)
            pool_size = NP + size(archive, 2);
            r_idx = randi(pool_size);
            while r_idx == a1(i)
                r_idx = randi(pool_size);
            end
            if r_idx <= NP
                x_r = population(:, r_idx);
            else
                x_r = archive(:, r_idx - NP);
            end

            % Permutation-adapted current-to-pbest:
            % Use OX1 between current and pbest (weighted by F_i via segment size)
            % Then apply CR_i-controlled inheritance from donor x_r
            seg_len = max(1, round(F_i * N));
            ui(:,i) = jade_permutation_crossover(current, pbest, x_r, CR_i, seg_len, M, N);
        else
            if strcmp(crossover_op, 'ox1')
                ui(:,i) = order_crossover(mp1(:,i), mp2(:,i), M, N);
            else
                ui(:,i) = permutation_mutate(mp1(:,i), mp2(:,i), M, N);
            end
        end

        % CR-101: Standard DE selection — offspring replaces its actual parent at a1(i)
        fitness_tmp = f(reshape(ui(:,i), M, N));
        num_evals = num_evals + 1;
        if fitness_tmp <= parent_fitness(i)
            % ALG-003: archive replaced individual and record successful params
            if use_jade
                if size(archive, 2) < archive_max
                    archive = [archive, population(:, a1(i))];
                else
                    archive(:, randi(archive_max)) = population(:, a1(i));
                end
                S_CR = [S_CR, CR_i];
                S_F = [S_F, F_i];
            end
            population(:, a1(i)) = ui(:,i);
            fitness(a1(i)) = fitness_tmp;
            if fitness_tmp < best_fitness
                best_fitness = fitness_tmp;
                best_individual = ui(:,i);
            end
        end
    end

    % ALG-003: JADE parameter adaptation
    if use_jade && ~isempty(S_CR)
        mu_CR = (1 - jade_c) * mu_CR + jade_c * mean(S_CR);
        % Lehmer mean for F (weighted toward larger successful values)
        mu_F = (1 - jade_c) * mu_F + jade_c * (sum(S_F.^2) / sum(S_F));
    end

    % ALG-002: local search on best individual at configured interval
    if use_local_search && mod(generation, ls_interval) == 0
        [ls_perm, ls_ms, ls_evals] = local_search_insert(J, best_individual, M, N);
        num_evals = num_evals + ls_evals;
        if ls_ms < best_fitness
            best_fitness = ls_ms;
            best_individual = ls_perm;
            population(:, end) = ls_perm;
            fitness(end) = ls_ms;
        end
    end

    % Record best AFTER this generation's selection
    best_per_gen(generation) = best_fitness;

    [fitness, sort_idx] = sort(fitness);
    population = population(:, sort_idx);

    % Snapshot this generation's population
    if capture_snapshots
        pop_snapshots{generation + 1} = population;
    end

    % ALG-005: linear population reduction
    if use_pop_reduction
        NP_new = round(NP_init - generation * (NP_init - NP_min) / max_generations);
        NP_new = max(NP_new, 4);
        if NP_new < NP
            population = population(:, 1:NP_new);
            fitness = fitness(1:NP_new);
            NP = NP_new;
            rot = (0:1:NP-1);
            if selective
                mid = ceil(selection_ratio * NP);
            else
                mid = NP;
            end
        end
    end

    generation = generation + 1;
end

best_individual = reshape(best_individual, M, N);

difflb = best_fitness - Prob.lb;
diffub = best_fitness - Prob.ub;
end
