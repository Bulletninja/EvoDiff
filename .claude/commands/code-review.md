description: "Code review: algorithm correctness, Octave idioms, performance"

# EvoDiff Code Review

You are reviewing an Octave/MATLAB scientific computing codebase. **Read first, then analyze.**

## Scope

Default: all production code. If `$ARGUMENTS` provided, scope to those files.

Production files to read:
- `src/core/de_flowshop.m` — main DE algorithm
- `src/core/evaluate_makespan.m` — fitness function (makespan DP)
- `src/core/random_permutation.m` — random job permutation
- `src/core/permutation_mutate.m` — mutation operator
- `src/experiment/run_experiment.m` — multi-problem orchestrator
- `src/experiment/generate_report.m` — LaTeX/plot output
- `src/io/load_config.m` — JSON config with defaults
- `src/io/load_problems.m` — JSON problem loader
- `src/io/save_results.m` — MAT file saver

## Focus Areas

**Algorithm Correctness:**
- DE population init, mutation, selection, elitism
- Permutation validity after mutation (still valid column permutation?)
- Fitness tracking: best_per_gen correctly recorded?
- Greedy selection: offspring replaces parent only if fitness <= parent
- Stopping criterion: generation < max_generations AND best_fitness > 1e-5
- Selective breeding: top-50% when selective=true

**Octave/MATLAB Idioms:**
- Copy-on-write semantics (does C_mat = O create independent copy?)
- 1-based indexing correctness
- reshape/size consistency (M*N flattening/unflattening)
- Variable shadowing (function name reused as variable)
- Pre-allocation before loops

**Performance:**
- Unnecessary copies or redundant computations
- Vectorization opportunities
- Memory allocation in hot loops
- Sort stability assumptions

**Error Handling:**
- Missing input validation (NP=0? max_generations=0? empty Prob.P?)
- Edge cases: single job, single machine, 1-generation run

## Process

1. Read ALL files listed above
2. Trace the main algorithm: init -> eval -> sort -> mutate -> select -> repeat
3. Check each function's docstring contract vs actual behavior
4. Report findings with exact file:line, evidence, severity, suggested fix

## Output Format

For each finding:

### CR-NNN: {Title}
**Location**: {file}:{line}
**Severity**: CRITICAL / HIGH / MEDIUM / LOW
**Category**: Algorithm | Performance | ErrorHandling | Idiom
**Evidence**: {code snippet}
**Issue**: {description}
**Fix**: {suggested fix}
