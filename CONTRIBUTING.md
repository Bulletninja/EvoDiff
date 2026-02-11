# Contributing to EvoDiff

## Reporting Bugs

Open an issue with:
1. Steps to reproduce
2. Expected vs actual behavior
3. MATLAB/Octave version
4. Error message and stack trace

## Adding a New Problem Type

1. Create a JSON file in `data/` following the format of `taillard_20x5.json`
2. Load it with `problems = load_problems('data/your_file.json')`
3. Run the experiment: `results = run_experiment(problems, config)`

## Adding a New Operator

1. Create a function in `src/core/` (e.g., `order_crossover.m`)
2. Match the signature: `offspring = order_crossover(parent1, parent2, M, N)`
3. Add tests in `tests/test_order_crossover.m`
4. Update `de_flowshop.m` to support it via config

## Code Style

- **Language**: All code, comments, and variable names in English
- **Naming**: `snake_case` for functions and variables
- **Functions**: One function per file, filename matches function name
- **Documentation**: Every function has a header comment with Args/Returns
- **Tests**: Every new function has a corresponding `test_*.m` file

## Running Tests

```matlab
setup_paths();
run_tests('verbose');
```

All tests must pass before submitting changes.

## Pull Request Process

1. Fork and create a feature branch
2. Write tests for new functionality
3. Ensure `run_tests()` passes (all tests, 0 failures)
4. Submit PR with a clear description of changes
