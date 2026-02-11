function [best_individual, best_fitness, num_evals, difflb, diffub, best_per_gen] = de_flowshop(Prob, NP, max_generations, f, selective)
% DE_FLOWSHOP Differential Evolution for permutation-based flow shop scheduling
%
% Minimizes makespan using a permutation-based DE with custom mutation.
%
% Args:
%   Prob            - Problem struct with fields: .P (processing times), .lb, .ub
%   NP              - Population size
%   max_generations - Maximum number of generations
%   f               - Fitness function name (string, e.g. 'evaluate_makespan')
%   selective       - If true, only mutate top 50% of population
%
% Returns:
%   best_individual - Best solution found (M x N matrix)
%   best_fitness    - Fitness value of best solution
%   num_evals       - Total number of fitness evaluations
%   difflb          - Difference from lower bound
%   diffub          - Difference from upper bound
%   best_per_gen    - Best fitness at each generation

J = Prob.P;
[M, N] = size(J);
best_per_gen = zeros(1, max_generations);

generation = 1;

% Initialize population: each column is a flattened job matrix
population = zeros(M*N, NP);
for i = 1:NP
    population(:,i) = random_permutation(J);
end

fitness          = zeros(NP, 1);
best_individual  = zeros(M*N, 1);
best_ind_iter    = zeros(M*N, 1);
num_evals        = 0;

% Initial evaluation
best_idx = 1;
fitness(1) = feval(f, reshape(population(:,best_idx), M, N));
num_evals = num_evals + 1;
for i = 2:NP
    fitness(i) = feval(f, reshape(population(:,i), M, N));
    num_evals = num_evals + 1;
end

% Sort population by fitness
[fitness, sort_idx] = sort(fitness);
population = population(:, sort_idx);
best_fitness = fitness(1);
best_ind_iter = population(:, best_idx);
best_individual = best_ind_iter;

% Pre-allocate mutation matrices
mp1 = zeros(M*N, NP);
mp2 = zeros(M*N, NP);
ui  = zeros(M*N, NP);

% Shuffling indices
rot = (0:1:NP-1);

% Selective breeding: mutate only top half if enabled
mid = NP;
if selective
    mid = ceil(0.5 * NP);
end

while (generation < max_generations) && (best_fitness > 1.e-5)
    best_per_gen(generation) = fitness(1);

    old_population = population;

    % Shuffle population to select parents
    ind = randperm(4);
    a1  = randperm(NP);
    rt  = rem(rot + ind(1), NP);
    a2  = a1(rt + 1);
    rt  = rem(rot + ind(2), NP);
    a3  = a2(rt + 1);
    rt  = rem(rot + ind(3), NP);
    a4  = a3(rt + 1);
    rt  = rem(rot + ind(4), NP);
    a5  = a4(rt + 1);

    mp1 = old_population(:, a1);
    mp2 = old_population(:, a2);

    % Generate offspring via permutation mutation
    for i = 1:mid
        ui(:,i) = permutation_mutate(mp1(:,i), mp2(:,i), M, N);
    end

    % Selection: keep offspring if better than parent
    for i = 1:mid
        fitness_tmp = feval(f, reshape(ui(:,i), M, N));
        num_evals = num_evals + 1;
        if fitness_tmp <= fitness(i)
            population(:,i) = ui(:,i);
            fitness(i) = fitness_tmp;
            if fitness_tmp < best_fitness
                best_fitness = fitness_tmp;
                best_individual = ui(:,i);
            end
        end
    end
    best_ind_iter = best_individual;

    if rem(generation, 100) == 0
        fprintf('Generation: %d, Best: %f, Median %f, Mean %f\n', ...
            generation, fitness(1), median(fitness), mean(fitness));
    end

    [fitness, sort_idx] = sort(fitness);
    population = population(:, sort_idx);

    generation = generation + 1;
end

best_per_gen(max_generations) = fitness(1);

best_individual = reshape(best_individual, M, N);
best_fitness = fitness(1);

difflb = best_fitness - Prob.lb;
diffub = best_fitness - Prob.ub;
end
