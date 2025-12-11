# EvoDiff

Differential Evolution metaheuristic for Flow Shop Scheduling optimization, tested on Taillard benchmarks.

## Quick Start

```matlab
% 1. Configure paths
setup_paths()

% 2. Run experiments
InitFlowshop
```

## Project Structure

```
EvoDiff/
├── src/            # Core algorithm functions
│   ├── EvoDif_Programa.m    # Main DE algorithm
│   ├── Makespan.m           # Fitness function
│   ├── CruzayMutacion2.m    # Genetic operators
│   └── ...
├── scripts/        # Entry points & experiments
│   ├── InitFlowshop.m       # Main benchmark runner
│   └── ScriptPruebas.m      # Test experiments
├── data/           # Benchmark data (Taillard 20x5)
├── results/        # Generated outputs (gitignored)
│   ├── figures/    # Convergence plots
│   ├── tables/     # LaTeX tables
│   └── solutions/  # Best solutions found
├── tests/          # Unit tests
└── docs/           # Documentation
```

## Algorithm

Implements Differential Evolution (DE) for permutation-based Flow Shop Scheduling:

- **Representation**: Job permutation (1×N vector)
- **Operators**: Custom crossover/mutation preserving valid permutations
- **Fitness**: Makespan (total completion time)
- **Benchmarks**: Taillard instances (20 jobs, 5 machines)

## Running Tests

```matlab
run_tests()           % Run all tests
run_tests('verbose')  % With detailed output
```

## Documentation

See `docs/` for:
- `ALGORITHM_ANALYSIS.md` - Algorithm deep dive
- `ARCHITECTURE_ANALYSIS.md` - Code structure analysis
- `REFACTORING_ROADMAP.md` - Improvement plan

## Requirements

- MATLAB R2016b+ or GNU Octave 4.0+

## License

Academic/Research use.
