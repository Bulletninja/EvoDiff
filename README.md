# EvoDiff

Differential Evolution for Flow Shop Scheduling Optimization in MATLAB/Octave.

Solves permutation-based flow shop scheduling problems using a custom DE variant with permutation-aware mutation operators. Tested on Taillard benchmark instances (20 jobs, 5 machines).

## Quick Start

```matlab
setup_paths();

% Run a quick validation (1 problem, 3 runs, ~2 seconds)
QuickTest

% Or run with custom config
config = load_config('config/quick_test.json');
problems = load_problems(config.problem_file);
[best_ind, best_val, ~, ~, ~, ~] = de_flowshop(problems(1), 100, 20, 'evaluate_makespan', false);
fprintf('Best makespan: %d\n', best_val);
```

## Installation

```bash
git clone https://github.com/yourusername/EvoDiff.git
cd EvoDiff
```

Then in MATLAB/Octave:

```matlab
setup_paths();
run_tests();  % Verify everything works
```

Requirements: MATLAB R2016b+ or GNU Octave 4.0+

## Project Structure

```
EvoDiff/
  src/
    core/
      de_flowshop.m          # Main DE algorithm
      evaluate_makespan.m    # Fitness function
      permutation_mutate.m   # Mutation operator
      random_permutation.m   # Solution generator
    experiment/
      run_experiment.m       # Multi-run orchestrator
      generate_report.m      # LaTeX tables + plots
    io/
      load_problems.m        # JSON data loader
      load_config.m          # Configuration loader
      save_results.m         # Result serialization
  scripts/
    InitFlowshop.m           # Full benchmark runner
    InitFlowshop_verbose.m   # With checkpointing
    QuickTest.m              # Fast validation
  config/
    default.json             # Full experiment config
    quick_test.json          # Fast test config
  data/
    taillard_20x5.json       # 10 Taillard instances
  tests/                     # 10 unit/integration tests
  legacy/                    # Archived DE variants
```

## Configuration

All parameters are controlled via JSON config files:

```json
{
  "population_size": 500,
  "max_generations": 100,
  "num_runs": 30,
  "selective": false,
  "fitness_function": "evaluate_makespan",
  "problem_file": "data/taillard_20x5.json",
  "random_seed": null
}
```

Set `random_seed` to an integer for reproducible results.

## Benchmarks

Taillard 20x5 flow shop instances (10 problems):

| Problem | Lower Bound | Upper Bound |
|---------|------------|-------------|
| 1       | 1232       | 1278        |
| 2       | 1290       | 1359        |
| 3       | 1073       | 1081        |
| 4       | 1268       | 1293        |
| 5       | 1198       | 1236        |
| 6       | 1180       | 1195        |
| 7       | 1226       | 1239        |
| 8       | 1170       | 1206        |
| 9       | 1206       | 1230        |
| 10      | 1082       | 1108        |

## Running Tests

```matlab
run_tests()                          % Run all 10 tests
run_tests('verbose')                 % With stack traces on failure
run_tests('pattern', 'makespan')     % Run specific tests
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Citation

If you use EvoDiff in academic work, please cite:

```bibtex
@software{evodiff,
  title  = {EvoDiff: Differential Evolution for Flow Shop Scheduling},
  url    = {https://github.com/yourusername/EvoDiff},
  year   = {2026}
}
```

## License

[MIT](LICENSE)
