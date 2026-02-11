function [best_individual, best_fitness, num_evals, difflb, diffub, best_per_gen] = de_flowshop(Prob, NP, max_generations, f, selective, selection_ratio)
% DE_FLOWSHOP Differential Evolution for permutation-based flow shop scheduling
%
% Minimizes makespan using a permutation-based DE with custom mutation.
%
% Args:
%   Prob            - Problem struct with fields: .P (processing times), .lb, .ub
%   NP              - Population size
%   max_generations - Maximum number of generations
%   f               - Fitness function name (string, e.g. 'evaluate_makespan')
%   selective       - If true, only mutate a fraction of population
%   selection_ratio - Fraction of population to mutate when selective (default 0.5)
%
% Returns:
%   best_individual - Best solution found (M x N matrix)
%   best_fitness    - Fitness value of best solution
%   num_evals       - Total number of fitness evaluations
%   difflb          - Difference from lower bound
%   diffub          - Difference from upper bound
%   best_per_gen    - Best fitness at each generation

% CR-009: default selection_ratio to 0.5 for backward compatibility
if nargin < 6 || isempty(selection_ratio)
    selection_ratio = 0.5;
end

J = Prob.P;
[M, N] = size(J);

% CR-010: input validation
assert(NP >= 2, 'Population size must be at least 2');
assert(max_generations >= 1, 'max_generations must be at least 1');
assert(M > 0 && N > 0, 'Processing times matrix must not be empty');

best_per_gen = zeros(1, max_generations);

generation = 1;

% Initialize population: each column is a flattened job matrix
population = zeros(M*N, NP);
for i = 1:NP
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

% Pre-allocate offspring matrix
ui  = zeros(M*N, NP);

% Shuffling indices
rot = (0:1:NP-1);

% CR-102: Selective breeding (truncation selection) — only the top fraction
% breeds. Bottom (mid+1:NP) are never mutated but can be displaced by
% offspring of the elite via sort. This is intentional: it concentrates
% search effort on promising regions while maintaining diversity in the tail.
mid = NP;
if selective
    mid = ceil(selection_ratio * NP);
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

    % Generate offspring via permutation mutation
    for i = 1:mid
        ui(:,i) = permutation_mutate(mp1(:,i), mp2(:,i), M, N);
    end

    % CR-101: Standard DE selection — offspring replaces its actual parent at a1(i)
    for i = 1:mid
        fitness_tmp = f(reshape(ui(:,i), M, N));
        num_evals = num_evals + 1;
        if fitness_tmp <= parent_fitness(i)
            population(:, a1(i)) = ui(:,i);
            fitness(a1(i)) = fitness_tmp;
            if fitness_tmp < best_fitness
                best_fitness = fitness_tmp;
                best_individual = ui(:,i);
            end
        end
    end

    % Record best AFTER this generation's selection
    best_per_gen(generation) = best_fitness;

    [fitness, sort_idx] = sort(fitness);
    population = population(:, sort_idx);

    generation = generation + 1;
end

best_individual = reshape(best_individual, M, N);

difflb = best_fitness - Prob.lb;
diffub = best_fitness - Prob.ub;
end
