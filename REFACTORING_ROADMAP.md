# EvoDiff Refactoring Roadmap

## Overview

This document provides a **concrete, step-by-step refactoring plan** with code examples, test cases, and validation criteria. Follow phases sequentially to ensure stability.

---

## PHASE 1: FOUNDATION & BUG FIXES (Week 1)

### 1.1 Create Project Structure

**Goal**: Organize code into logical modules

**Action**:
```bash
mkdir -p src/{core,algorithms,problems,operators,utils}
mkdir -p tests
mkdir -p config
mkdir -p data
mkdir -p docs
```

**Structure**:
```
EvoDiff/
├── src/
│   ├── core/           # Base classes
│   ├── algorithms/     # DE implementations
│   ├── problems/       # Problem definitions
│   ├── operators/      # Genetic operators
│   └── utils/          # Helpers
├── tests/              # Unit tests
├── config/             # Configuration files
├── data/               # Benchmark problems
└── docs/               # Documentation
```

---

### 1.2 Extract Benchmark Data

**Current** (InitFlowshop.m:15-183):
```matlab
FS(1).P=[54 83 15 71 77 ...];
FS(1).lb=1232;
FS(1).ub=1278;
% ... repeated 10 times, 170 lines total
```

**Refactored** (data/taillard_20x5.json):
```json
{
  "problem_set": "Taillard Flowshop 20x5",
  "num_problems": 10,
  "problems": [
    {
      "id": 1,
      "machines": 5,
      "jobs": 20,
      "processing_times": [
        [54, 83, 15, 71, 77, 36, 53, 38, 27, 87, 76, 91, 14, 29, 12, 77, 32, 87, 68, 94],
        [79, 3, 11, 99, 56, 70, 99, 60, 5, 56, 3, 61, 73, 75, 47, 14, 21, 86, 5, 77],
        [16, 89, 49, 15, 89, 45, 60, 23, 57, 64, 7, 1, 63, 41, 63, 47, 26, 75, 77, 40],
        [66, 58, 31, 68, 78, 91, 13, 59, 49, 85, 85, 9, 39, 41, 56, 40, 54, 77, 51, 31],
        [58, 56, 20, 85, 53, 35, 53, 41, 69, 13, 86, 72, 8, 49, 47, 87, 58, 18, 68, 28]
      ],
      "lower_bound": 1232,
      "upper_bound": 1278
    }
    // ... 9 more problems
  ]
}
```

**Loader** (src/utils/load_taillard_problems.m):
```matlab
function problems = load_taillard_problems(filename)
    % Load Taillard benchmark problems from JSON
    %
    % Args:
    %   filename: Path to JSON file
    %
    % Returns:
    %   problems: Struct array with fields P, lb, ub, id

    if ~exist(filename, 'file')
        error('File not found: %s', filename);
    end

    % Read JSON
    json_str = fileread(filename);
    data = jsondecode(json_str);

    % Convert to struct array
    num_problems = data.num_problems;
    problems = struct('id', {}, 'P', {}, 'lb', {}, 'ub', {});

    for i = 1:num_problems
        prob = data.problems(i);
        problems(i).id = prob.id;
        problems(i).P = cell2mat(prob.processing_times);
        problems(i).lb = prob.lower_bound;
        problems(i).ub = prob.upper_bound;
    end
end
```

**Benefits**:
- Separates data from code
- Easy to add new benchmarks
- Version controllable
- Can use MAT files for faster loading

---

### 1.3 Fix Critical Bug: Best Individual Tracking

**Current** (EvoDif_Programa.m:107-114):
```matlab
for i=1:mid
    val_tmp = feval(f, reshape(ui(:,i), M, N));
    nfeval = nfeval+1;
    if (val_tmp <= val(i))
        poblacion(:,i) = ui(:,i);
        val(i) = val_tmp;
        % BUG: Best not updated here!
    end
end
mejorinditeracion = mejorindividuo;  % Line 115: Wrong!
```

**Fixed** (src/algorithms/differential_evolution.m):
```matlab
% Initialize tracking
global_best_fitness = Inf;
global_best_individual = [];

% Selection loop
for i=1:mid
    offspring_fitness = evaluate_fitness(offspring(:,i), problem);
    num_evaluations = num_evaluations + 1;

    % Replace if better
    if offspring_fitness <= population_fitness(i)
        population(:,i) = offspring(:,i);
        population_fitness(i) = offspring_fitness;

        % Update global best
        if offspring_fitness < global_best_fitness
            global_best_fitness = offspring_fitness;
            global_best_individual = offspring(:,i);
        end
    end
end

% Return global best (not sorted best)
best_individual = global_best_individual;
best_fitness = global_best_fitness;
```

**Test** (tests/test_best_tracking.m):
```matlab
function test_best_tracking()
    % Test that best individual is correctly tracked

    % Create simple problem
    problem.P = [1 2 3; 4 5 6];
    problem.evaluate = @(x) sum(x(:));

    % Run DE
    [best_ind, best_fit, ~] = differential_evolution(problem, ...
        'population_size', 10, 'generations', 5);

    % Verify best was actually tracked
    assert(~isempty(best_ind), 'Best individual should not be empty');
    assert(best_fit < Inf, 'Best fitness should be updated');

    % Re-evaluate best to confirm
    actual_fit = problem.evaluate(best_ind);
    assert(abs(actual_fit - best_fit) < 1e-10, ...
        'Returned fitness must match best individual');

    fprintf('✓ Best tracking test passed\n');
end
```

---

### 1.4 Fix Critical Bug: Makespan Input Mutation

**Current** (Makespan.m):
```matlab
function C = Makespan(O)
    [M, N] = size(O);
    O(1,:) = cumsum(O(1,:));  % MUTATES INPUT!
    O(:,1) = cumsum(O(:,1));
    % ...
end
```

**Fixed** (src/problems/flowshop_makespan.m):
```matlab
function makespan = flowshop_makespan(processing_times)
    % Calculate flowshop makespan using dynamic programming
    %
    % Args:
    %   processing_times: M×N matrix (machines × jobs)
    %
    % Returns:
    %   makespan: Total completion time (scalar)
    %
    % Algorithm: O(M*N) dynamic programming
    % Note: Creates local copy to avoid mutating input

    % Input validation
    validateattributes(processing_times, {'numeric'}, ...
        {'2d', 'positive', 'finite'}, mfilename, 'processing_times', 1);

    % Create local copy (MATLAB copy-on-write handles efficiency)
    C = processing_times;
    [M, N] = size(C);

    % DP: Cumulative sums for first row/column
    C(1,:) = cumsum(C(1,:));
    C(:,1) = cumsum(C(:,1));

    % DP: Fill rest of matrix
    for j = 2:N
        for i = 2:M
            C(i,j) = C(i,j) + max(C(i-1,j), C(i,j-1));
        end
    end

    makespan = C(M, N);
end
```

**Test** (tests/test_makespan.m):
```matlab
function test_makespan()
    % Test makespan calculation

    % Test 1: Input not mutated
    P = [10 20 30; 15 25 35];
    P_original = P;
    makespan = flowshop_makespan(P);
    assert(isequal(P, P_original), 'Input should not be modified');

    % Test 2: Known result
    % 2 machines, 3 jobs
    % Job 1: M1=10, M2=15 → M2 finishes at 10+15=25
    % Job 2: M1=20 (starts at 10, ends 30), M2=25 (starts at max(30,25)=30, ends 55)
    % Job 3: M1=30 (starts at 30, ends 60), M2=35 (starts at max(60,55)=60, ends 95)
    expected = 95;
    assert(makespan == expected, 'Makespan should be 95, got %d', makespan);

    % Test 3: Single job
    P_single = [10; 20; 30];
    expected_single = 60;  % Sum of all operations
    assert(flow_makespan(P_single) == expected_single);

    % Test 4: Single machine
    P_machine = [10 20 30];
    expected_machine = 60;  % Sum of all jobs
    assert(flowshop_makespan(P_machine) == expected_machine);

    fprintf('✓ All makespan tests passed\n');
end
```

---

### 1.5 Create Configuration System

**Current**: Hardcoded parameters everywhere

**Refactored** (config/default_config.yaml):
```yaml
# EvoDiff Configuration
experiment:
  name: "Taillard 20x5 Benchmark"
  num_runs: 30
  random_seed: null  # null = random, or integer for reproducibility

algorithm:
  name: "Differential Evolution"
  population_size: 500
  max_generations: 100

  # Termination criteria
  termination:
    max_generations: 100
    fitness_threshold: 1e-5
    convergence_generations: 20  # Stop if no improvement for N gens
    max_time_seconds: 3600

  # Selective breeding
  selective_breeding: false
  selection_ratio: 0.5  # If selective, breed top 50%

  # DE parameters (if using classical DE)
  F: 0.8
  CR: 0.9
  strategy: "DE/best/1"  # or "DE/rand/1", etc.

problem:
  type: "flowshop"
  data_file: "data/taillard_20x5.json"

output:
  save_results: true
  results_dir: "results/"
  save_plots: true
  plots_dir: "plots/"
  verbose: true
  log_interval: 10  # Print every N generations
```

**Loader** (src/utils/config.m):
```matlab
classdef Config
    % Configuration manager for EvoDiff

    properties
        experiment
        algorithm
        problem
        output
    end

    methods
        function obj = Config(yaml_file)
            % Load configuration from YAML file
            if nargin < 1
                yaml_file = 'config/default_config.yaml';
            end

            % Read YAML (requires YAML toolbox or manual parsing)
            data = ReadYaml(yaml_file);

            obj.experiment = data.experiment;
            obj.algorithm = data.algorithm;
            obj.problem = data.problem;
            obj.output = data.output;
        end

        function validate(obj)
            % Validate configuration values
            assert(obj.algorithm.population_size > 0, ...
                'Population size must be positive');
            assert(obj.algorithm.max_generations > 0, ...
                'Max generations must be positive');
            assert(obj.experiment.num_runs > 0, ...
                'Number of runs must be positive');
        end
    end
end
```

---

## PHASE 2: CORE ABSTRACTIONS (Week 2)

### 2.1 Create Problem Base Class

**New** (src/core/Problem.m):
```matlab
classdef (Abstract) Problem < handle
    % Abstract base class for optimization problems

    properties (Abstract, Constant)
        problem_type  % 'continuous', 'discrete', 'permutation'
    end

    properties (Abstract)
        dimension      % Problem dimension
        lower_bound    % Known lower bound (if available)
        upper_bound    % Known upper bound (if available)
    end

    methods (Abstract)
        fitness = evaluate(obj, solution)
        % Evaluate fitness of a solution

        solution = random_solution(obj)
        % Generate a random valid solution

        is_valid = validate_solution(obj, solution)
        % Check if solution is valid
    end

    methods
        function [fitness, violation] = evaluate_with_constraints(obj, solution)
            % Evaluate fitness and constraint violations
            if ~obj.validate_solution(solution)
                fitness = Inf;
                violation = Inf;
            else
                fitness = obj.evaluate(solution);
                violation = 0;
            end
        end
    end
end
```

---

### 2.2 Create Flowshop Problem Class

**New** (src/problems/FlowshopProblem.m):
```matlab
classdef FlowshopProblem < Problem
    % Flowshop scheduling problem

    properties (Constant)
        problem_type = 'permutation'
    end

    properties
        processing_times  % M×N matrix (machines × jobs)
        num_machines
        num_jobs
        dimension        % N (number of jobs)
        lower_bound
        upper_bound
        problem_id
    end

    methods
        function obj = FlowshopProblem(processing_times, varargin)
            % Constructor
            %
            % Args:
            %   processing_times: M×N matrix
            %   varargin: Optional 'lower_bound', 'upper_bound', 'id'

            p = inputParser;
            addRequired(p, 'processing_times', @isnumeric);
            addParameter(p, 'lower_bound', NaN, @isnumeric);
            addParameter(p, 'upper_bound', NaN, @isnumeric);
            addParameter(p, 'id', 0, @isnumeric);
            parse(p, processing_times, varargin{:});

            obj.processing_times = processing_times;
            [obj.num_machines, obj.num_jobs] = size(processing_times);
            obj.dimension = obj.num_jobs;
            obj.lower_bound = p.Results.lower_bound;
            obj.upper_bound = p.Results.upper_bound;
            obj.problem_id = p.Results.id;
        end

        function makespan = evaluate(obj, job_order)
            % Evaluate makespan for given job order
            %
            % Args:
            %   job_order: 1×N vector of job indices (permutation of 1:N)
            %
            % Returns:
            %   makespan: Total completion time

            % Validate input
            if ~obj.validate_solution(job_order)
                error('Invalid job order');
            end

            % Rearrange jobs according to order
            ordered_times = obj.processing_times(:, job_order);

            % Calculate makespan
            makespan = flowshop_makespan(ordered_times);
        end

        function job_order = random_solution(obj)
            % Generate random valid job order
            job_order = randperm(obj.num_jobs);
        end

        function is_valid = validate_solution(obj, job_order)
            % Check if job order is valid permutation
            %
            % Valid if:
            % - Vector of length N
            % - Contains each job 1:N exactly once

            is_valid = false;

            if ~isvector(job_order) || length(job_order) ~= obj.num_jobs
                return;
            end

            if ~all(ismember(1:obj.num_jobs, job_order))
                return;
            end

            if length(unique(job_order)) ~= obj.num_jobs
                return;
            end

            is_valid = true;
        end

        function [error_lb, error_ub] = evaluate_error(obj, makespan)
            % Calculate error relative to bounds
            error_lb = makespan - obj.lower_bound;
            error_ub = makespan - obj.upper_bound;
        end
    end
end
```

**Test** (tests/test_flowshop_problem.m):
```matlab
function test_flowshop_problem()
    % Test FlowshopProblem class

    % Create problem
    P = [10 20 30; 15 25 35];
    prob = FlowshopProblem(P, 'lower_bound', 90, 'upper_bound', 100);

    % Test properties
    assert(prob.num_machines == 2);
    assert(prob.num_jobs == 3);
    assert(prob.dimension == 3);

    % Test random solution
    sol = prob.random_solution();
    assert(prob.validate_solution(sol));

    % Test evaluation
    makespan = prob.evaluate([1 2 3]);
    assert(makespan == 95);  % Known result

    % Test invalid solutions
    assert(~prob.validate_solution([1 2]));  % Too short
    assert(~prob.validate_solution([1 2 2]));  % Duplicate
    assert(~prob.validate_solution([1 2 4]));  % Invalid job

    fprintf('✓ FlowshopProblem tests passed\n');
end
```

---

### 2.3 Create Population Class

**New** (src/core/Population.m):
```matlab
classdef Population < handle
    % Population manager for evolutionary algorithms

    properties
        individuals      % N×D matrix (N individuals, D dimensions)
        fitness_values   % N×1 vector of fitness values
        size             % Population size (N)
        dimension        % Problem dimension (D)
        best_index       % Index of best individual
        best_fitness     % Fitness of best
        best_individual  % Copy of best individual
    end

    methods
        function obj = Population(size, dimension)
            % Constructor
            obj.size = size;
            obj.dimension = dimension;
            obj.individuals = zeros(size, dimension);
            obj.fitness_values = inf(size, 1);
            obj.best_fitness = Inf;
        end

        function initialize_random(obj, problem)
            % Initialize with random solutions
            for i = 1:obj.size
                obj.individuals(i,:) = problem.random_solution();
            end
        end

        function evaluate_all(obj, problem)
            % Evaluate all individuals
            for i = 1:obj.size
                obj.fitness_values(i) = problem.evaluate(obj.individuals(i,:));
            end
            obj.update_best();
        end

        function update_best(obj)
            % Update best individual tracking
            [min_fit, min_idx] = min(obj.fitness_values);
            if min_fit < obj.best_fitness
                obj.best_fitness = min_fit;
                obj.best_index = min_idx;
                obj.best_individual = obj.individuals(min_idx, :);
            end
        end

        function sort_by_fitness(obj)
            % Sort population by fitness (ascending)
            [obj.fitness_values, sort_idx] = sort(obj.fitness_values);
            obj.individuals = obj.individuals(sort_idx, :);
            obj.best_index = 1;
        end

        function diversity = calculate_diversity(obj)
            % Calculate population diversity (mean pairwise distance)
            if obj.size < 2
                diversity = 0;
                return;
            end
            diversity = mean(pdist(obj.individuals, 'hamming'));
        end

        function replace(obj, index, new_individual, new_fitness)
            % Replace individual at index
            obj.individuals(index, :) = new_individual;
            obj.fitness_values(index) = new_fitness;

            % Update best if necessary
            if new_fitness < obj.best_fitness
                obj.best_fitness = new_fitness;
                obj.best_index = index;
                obj.best_individual = new_individual;
            end
        end
    end
end
```

---

### 2.4 Refactor EvoDif_Programa to Use New Classes

**Before** (EvoDif_Programa.m:1-134): Procedural with 134 lines

**After** (src/algorithms/PermutationDE.m):
```matlab
classdef PermutationDE < handle
    % Differential Evolution for Permutation Problems

    properties
        config          % Configuration object
        problem         % Problem object
        population      % Population object
        statistics      % Statistics tracker
        num_evaluations % Total function evaluations
    end

    methods
        function obj = PermutationDE(problem, config)
            % Constructor
            obj.problem = problem;
            obj.config = config;
            obj.num_evaluations = 0;
            obj.statistics = Statistics();
        end

        function [best_solution, best_fitness, stats] = run(obj)
            % Main optimization loop

            % Initialize population
            pop_size = obj.config.algorithm.population_size;
            obj.population = Population(pop_size, obj.problem.dimension);
            obj.population.initialize_random(obj.problem);
            obj.population.evaluate_all(obj.problem);
            obj.num_evaluations = pop_size;

            % Evolution loop
            max_gen = obj.config.algorithm.termination.max_generations;
            for gen = 1:max_gen
                obj.evolve_one_generation();
                obj.statistics.record_generation(gen, obj.population.best_fitness);

                if should_terminate(obj, gen)
                    break;
                end

                if mod(gen, obj.config.output.log_interval) == 0
                    obj.print_progress(gen);
                end
            end

            % Return results
            best_solution = obj.population.best_individual;
            best_fitness = obj.population.best_fitness;
            stats = obj.statistics.get_summary();
        end

        function evolve_one_generation(obj)
            % Perform one generation of evolution

            % Determine how many individuals to breed
            num_breed = obj.get_num_breed();

            % Sort population for selective breeding
            if obj.config.algorithm.selective_breeding
                obj.population.sort_by_fitness();
            end

            % Generate offspring
            for i = 1:num_breed
                % Select parents
                [parent1, parent2] = obj.select_parents(i);

                % Create offspring
                offspring = obj.mutate(parent1, parent2);

                % Evaluate
                offspring_fitness = obj.problem.evaluate(offspring);
                obj.num_evaluations = obj.num_evaluations + 1;

                % Selection: Replace if better
                if offspring_fitness <= obj.population.fitness_values(i)
                    obj.population.replace(i, offspring, offspring_fitness);
                end
            end

            % Re-sort for next generation
            if obj.config.algorithm.selective_breeding
                obj.population.sort_by_fitness();
            end
        end

        function num_breed = get_num_breed(obj)
            % Calculate how many individuals should breed
            if obj.config.algorithm.selective_breeding
                ratio = obj.config.algorithm.selection_ratio;
                num_breed = ceil(ratio * obj.population.size);
            else
                num_breed = obj.population.size;
            end
        end

        function [parent1, parent2] = select_parents(obj, individual_idx)
            % Select two parent individuals
            % For now, use random selection from population
            N = obj.population.size;
            indices = randperm(N, 2);
            parent1 = obj.population.individuals(indices(1), :);
            parent2 = obj.population.individuals(indices(2), :);
        end

        function offspring = mutate(obj, parent1, parent2)
            % Apply permutation mutation operator
            % (Current CruzayMutacion2 logic)
            offspring = permutation_mutation(parent1, parent2);
        end

        function should_stop = should_terminate(obj, generation)
            % Check termination criteria
            term = obj.config.algorithm.termination;

            % Max generations
            if generation >= term.max_generations
                should_stop = true;
                return;
            end

            % Fitness threshold
            if obj.population.best_fitness <= term.fitness_threshold
                should_stop = true;
                return;
            end

            % Convergence (no improvement for N generations)
            if obj.statistics.generations_without_improvement >= term.convergence_generations
                should_stop = true;
                return;
            end

            should_stop = false;
        end

        function print_progress(obj, generation)
            % Print current progress
            if obj.config.output.verbose
                fprintf('Gen %4d | Best: %.2f | Median: %.2f | Diversity: %.4f\n', ...
                    generation, ...
                    obj.population.best_fitness, ...
                    median(obj.population.fitness_values), ...
                    obj.population.calculate_diversity());
            end
        end
    end
end
```

---

## PHASE 3: IMPROVED REPRESENTATION (Week 3)

### 3.1 Switch from Matrix to Job-Order Encoding

**Current Problem**: Stores full M×N matrix (100 elements) per individual

**Solution**: Store only job order (N elements)

**Benefits**:
- 5× memory reduction
- No reshape operations
- Clearer semantics
- Faster copying

**Implementation**:

Update Population class:
```matlab
% Before: individuals is (NP × M*N)
obj.individuals = zeros(size, dimension);  % (500 × 100)

% After: individuals is (NP × N)
obj.individuals = zeros(size, problem.num_jobs);  % (500 × 20)
```

Update FlowshopProblem.random_solution:
```matlab
% Before: Returns flattened matrix (100×1)
J = permutarTrabajos(J);

% After: Returns job order (20×1)
job_order = randperm(obj.num_jobs);
```

Update evaluation:
```matlab
% Before: Reshape then evaluate
val = feval(f, reshape(poblacion(:,i), M, N));

% After: Direct evaluation
job_order = obj.population.individuals(i,:);
fitness = obj.problem.evaluate(job_order);
```

**Performance Impact**: Estimated 2-3× speedup

---

## PHASE 4: TESTING & VALIDATION (Week 4)

### 4.1 Create Test Suite

**Test categories**:
1. Unit tests for each class
2. Integration tests for full runs
3. Regression tests against known results
4. Performance benchmarks

**Example integration test** (tests/test_integration.m):
```matlab
function test_integration()
    % Test full DE run on simple problem

    % Create 2×3 problem
    P = [10 20 30; 15 25 35];
    problem = FlowshopProblem(P);

    % Configure
    config = struct();
    config.algorithm.population_size = 20;
    config.algorithm.termination.max_generations = 10;
    config.algorithm.selective_breeding = false;
    config.output.verbose = false;

    % Run
    de = PermutationDE(problem, config);
    [best_sol, best_fit, stats] = de.run();

    % Verify
    assert(problem.validate_solution(best_sol), 'Solution must be valid');
    assert(best_fit == problem.evaluate(best_sol), 'Fitness must match');
    assert(length(stats.best_per_generation) == 10, 'Should track 10 generations');

    fprintf('✓ Integration test passed\n');
end
```

---

## PHASE 5: PERFORMANCE OPTIMIZATION (Week 5)

### 5.1 Add Parallel Evaluation

**Current**: Sequential loop (50,000 serial evaluations)

**Optimized**: Parallel batch evaluation

```matlab
function evaluate_all(obj, problem)
    % Evaluate all individuals in parallel
    N = obj.size;
    fitness_values = zeros(N, 1);

    parfor i = 1:N
        fitness_values(i) = problem.evaluate(obj.individuals(i,:));
    end

    obj.fitness_values = fitness_values;
    obj.update_best();
end
```

**Impact**: 4-8× speedup on multi-core CPUs

---

### 5.2 Eliminate Sorting Overhead

**Current**: Sorts all 500 individuals every generation

**Optimized**: Only track best, partial sort when needed

```matlab
% Remove from main loop
% obj.population.sort_by_fitness();

% Only sort when selective breeding is enabled
if obj.config.algorithm.selective_breeding && mod(gen, 10) == 0
    obj.population.sort_by_fitness();
end
```

**Impact**: Eliminates ~450,000 operations per run

---

## PHASE 6: ADVANCED FEATURES (Week 6)

### 6.1 Implement True Crossover

**Add**: Order Crossover (OX) operator

```matlab
function offspring = order_crossover(parent1, parent2)
    % Order Crossover for permutations
    N = length(parent1);

    % Select two crossover points
    points = sort(randperm(N, 2));

    % Copy segment from parent1
    offspring = zeros(1, N);
    offspring(points(1):points(2)) = parent1(points(1):points(2));

    % Fill remaining with parent2's order
    p2_idx = 1;
    for i = 1:N
        if offspring(i) == 0  % Empty slot
            % Find next job from parent2 not already in offspring
            while ismember(parent2(p2_idx), offspring)
                p2_idx = p2_idx + 1;
            end
            offspring(i) = parent2(p2_idx);
            p2_idx = p2_idx + 1;
        end
    end
end
```

---

### 6.2 Add Local Search

**Add**: 2-opt improvement heuristic

```matlab
function improved = local_search_2opt(job_order, problem, max_iterations)
    % 2-opt local search for flowshop
    current = job_order;
    current_fitness = problem.evaluate(current);

    improved = false;
    for iter = 1:max_iterations
        % Try all pairwise swaps
        N = length(current);
        for i = 1:N-1
            for j = i+1:N
                % Swap jobs i and j
                neighbor = current;
                neighbor([i j]) = neighbor([j i]);

                % Evaluate
                neighbor_fitness = problem.evaluate(neighbor);

                % Accept if better
                if neighbor_fitness < current_fitness
                    current = neighbor;
                    current_fitness = neighbor_fitness;
                    improved = true;
                end
            end
        end

        if ~improved
            break;  % Local optimum reached
        end
    end
end
```

---

## VALIDATION CHECKLIST

After each phase, verify:

### Phase 1: Foundation
- [ ] All benchmark data loaded correctly
- [ ] Best tracking bug fixed (run test_best_tracking.m)
- [ ] Makespan doesn't mutate input (run test_makespan.m)
- [ ] Configuration loads from YAML

### Phase 2: Abstractions
- [ ] FlowshopProblem class tests pass
- [ ] Population class tests pass
- [ ] PermutationDE produces same results as old code

### Phase 3: Representation
- [ ] New encoding uses 5× less memory
- [ ] Performance improved by 2-3×
- [ ] Results match old implementation

### Phase 4: Testing
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Regression tests match published Taillard results

### Phase 5: Optimization
- [ ] Parallel evaluation works correctly
- [ ] Overall speedup of 4-8×
- [ ] Memory usage reduced

### Phase 6: Features
- [ ] Order crossover produces valid permutations
- [ ] Local search improves solutions
- [ ] Results competitive with literature

---

## MIGRATION STRATEGY

### Backward Compatibility

Keep old code working during transition:

```matlab
% run_old_version.m
addpath('legacy/');
InitFlowshop;

% run_new_version.m
addpath('src/');
config = Config('config/default_config.yaml');
problems = load_taillard_problems(config.problem.data_file);
run_experiments(problems, config);
```

### Validation

Compare old vs new:
```matlab
% Run both versions on same problems
results_old = run_old_version();
results_new = run_new_version();

% Compare
assert(abs(results_old.best_fitness - results_new.best_fitness) < 1e-10);
```

---

## SUCCESS METRICS

Track improvements:

| Metric | Before | Target | Validation |
|--------|--------|--------|------------|
| Lines of code | ~500 | ~800 (with tests) | wc -l src/**/*.m |
| Test coverage | 0% | >80% | Run test suite |
| Memory per individual | 800 bytes | 160 bytes | memory_profiler |
| Execution time | 60s | <10s | tic/toc |
| Best makespan (FS1) | ~1250 | <1240 | Compare with literature |
| Code clarity | Low | High | Code review |

---

## TIMELINE

| Week | Phase | Deliverables |
|------|-------|--------------|
| 1 | Foundation | Data separation, bug fixes, config system |
| 2 | Abstractions | Problem/Population/DE classes |
| 3 | Representation | Job-order encoding, performance gains |
| 4 | Testing | Full test suite, validation |
| 5 | Optimization | Parallelization, sorting elimination |
| 6 | Features | Crossover, local search, final tuning |

---

## NEXT STEPS

1. **Start with Phase 1, Step 1.2**: Extract Taillard data to JSON
2. **Validate**: Ensure data loads correctly
3. **Commit**: Git commit after each successful step
4. **Test**: Run old code to ensure compatibility
5. **Document**: Update README with new structure

**Command to start**:
```bash
cd /home/user/EvoDiff
git checkout -b refactor/phase1-foundation
mkdir -p {src,tests,config,data,docs}/{core,algorithms,problems,operators,utils}
```
