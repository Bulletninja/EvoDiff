# EvoDiff Testing Guide - TDD Workflow

## Quick Start

### Run all tests once
```matlab
run_tests()
```

### Run tests continuously (auto-rerun on file changes)
```matlab
watch_tests()
```

### Run specific tests
```matlab
run_tests('pattern', 'makespan')
```

### Verbose output
```matlab
run_tests('verbose')
```

---

## Test-Driven Development (TDD) Workflow

### 1. **Write a Test First** (Red)

Before implementing a feature or fixing a bug, write a test that fails:

```matlab
% tests/test_new_feature.m
function test_new_feature()
    fprintf('  Testing new feature...\n');

    % This will fail initially
    result = my_new_function(input);
    expected = 42;
    assert(result == expected, 'Feature should return 42');

    fprintf('  Test passed!\n');
end
```

Run tests: `run_tests()` → **Test fails ✗**

### 2. **Make It Pass** (Green)

Implement the minimum code to make the test pass:

```matlab
% my_new_function.m
function result = my_new_function(input)
    result = 42;  % Simplest implementation
end
```

Run tests: `run_tests()` → **Test passes ✓**

### 3. **Refactor** (Refactor)

Improve the code while keeping tests green:

```matlab
% my_new_function.m
function result = my_new_function(input)
    % Now implement properly
    result = calculate_properly(input);
end
```

Run tests: `run_tests()` → **Still passes ✓**

### 4. **Repeat**

Continue the cycle for each new feature or bug fix.

---

## Continuous Testing

### Option A: MATLAB-based watcher (cross-platform)

```matlab
% Start watching (checks every 3 seconds)
watch_tests()

% Custom interval
watch_tests('interval', 5)
```

**How it works:**
- Polls file system every N seconds
- Detects changes to .m files
- Automatically runs test suite
- Beeps on test failure (if terminal supports it)

**Pros:**
- Works on all platforms
- No external dependencies
- Can customize easily

**Cons:**
- Polling-based (slight delay)
- Uses MATLAB process continuously

### Option B: Shell script watcher (Linux/Mac, more efficient)

```bash
# Start watching
./watch_tests.sh
```

**How it works:**
- Uses `inotifywait` (Linux) or `fswatch` (Mac)
- Event-driven file watching (instant response)
- Runs tests in batch mode

**Pros:**
- Instant detection
- More efficient (event-driven)
- Doesn't keep MATLAB running

**Cons:**
- Requires external tools
- Platform-specific

**Installation:**
```bash
# Linux
sudo apt-get install inotify-tools

# macOS
brew install fswatch
```

---

## Current Test Coverage

### ✓ Implemented Tests

1. **test_makespan.m** - Makespan calculation
   - Input mutation check (Bug #2 validation)
   - Known results verification
   - Edge cases (single job, single machine)
   - Lower bound properties

2. **test_best_tracking.m** - Best individual tracking
   - Bug #1 fix validation
   - Monotonicity check (best should improve)
   - Consistency check (returned best matches actual)

3. **test_permutation.m** - Permutation operations
   - Valid permutation generation
   - Randomness verification
   - Size preservation

### 📝 Tests Needed (TODO)

Add these as you refactor:

4. **test_population.m** - Population management (when Population class exists)
5. **test_flowshop_problem.m** - Problem class (when created)
6. **test_crossover.m** - Crossover operators
7. **test_mutation.m** - Mutation operators
8. **test_integration.m** - Full DE runs on small problems
9. **test_regression.m** - Validate against Taillard benchmarks

---

## Writing New Tests

### Test File Template

```matlab
function test_my_feature()
% TEST_MY_FEATURE - Description of what's being tested
%
% Tests:
%   1. Basic functionality
%   2. Edge cases
%   3. Error handling

    fprintf('  Testing my feature...\n');

    %% Test 1: Basic case
    fprintf('    [1/3] Basic test...');

    % Setup
    input = create_test_input();

    % Execute
    result = my_function(input);

    % Verify
    expected = 42;
    assert(result == expected, ...
        sprintf('Expected %d, got %d', expected, result));

    fprintf(' ✓\n');

    %% Test 2: Edge case
    fprintf('    [2/3] Edge case...');

    % ... similar structure ...

    fprintf(' ✓\n');

    %% Test 3: Error handling
    fprintf('    [3/3] Error test...');

    try
        my_function(invalid_input);
        error('Should have thrown error');
    catch ME
        % Expected error
        assert(contains(ME.message, 'Invalid input'), ...
            'Should throw meaningful error');
    end

    fprintf(' ✓\n');

    fprintf('  All tests passed!\n');
end
```

### Best Practices

1. **One test file per module**
   - `test_makespan.m` for `Makespan.m`
   - `test_population.m` for `Population.m`

2. **Use descriptive names**
   - `test_makespan_input_mutation` ✓
   - `test1` ✗

3. **Test one thing at a time**
   - Each `assert` should test a single property
   - Multiple tests per file is fine

4. **Include edge cases**
   - Empty inputs
   - Single element
   - Large inputs
   - Invalid inputs

5. **Use meaningful error messages**
   ```matlab
   % Good
   assert(result == expected, ...
       sprintf('Expected %d, got %d', expected, result));

   % Bad
   assert(result == expected);
   ```

6. **Keep tests fast**
   - Use small problem sizes
   - Mock expensive operations
   - Save integration tests for separate suite

---

## Integration with Development

### Typical TDD Session

```bash
# Terminal 1: Run continuous tests
matlab -r "watch_tests()"

# Terminal 2: Edit code
vim Makespan.m

# Watch Terminal 1 automatically show test results
```

### Before Committing

Always run full test suite:

```matlab
results = run_tests('verbose');
if results.success
    fprintf('✅ Safe to commit\n');
else
    fprintf('⚠️  Fix failing tests before committing\n');
end
```

### Git Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Run tests before allowing commit

echo "Running tests..."
matlab -batch "results = run_tests(); exit(~results.success)" 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Commit aborted."
    echo "Fix tests or use 'git commit --no-verify' to skip"
    exit 1
fi

echo "✅ Tests passed"
exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

## Debugging Failed Tests

### Verbose Mode

```matlab
run_tests('verbose')
```

Shows full stack traces for failures.

### Run Single Test

```matlab
% Run just one test file
test_makespan()

% Or use pattern matching
run_tests('pattern', 'makespan')
```

### Interactive Debugging

```matlab
% Add breakpoint in test
dbstop in test_makespan at 15

% Run test
test_makespan()

% Debug interactively
% Use: dbstep, dbcont, dbquit
```

---

## Performance Testing

For performance-critical code, add timing tests:

```matlab
%% Performance test
fprintf('    [P] Performance test...');

input = create_large_input(1000);

tic;
result = my_function(input);
elapsed = toc;

% Should complete in under 1 second
assert(elapsed < 1.0, ...
    sprintf('Too slow: %.2f seconds', elapsed));

fprintf(' ✓ (%.3f sec)\n', elapsed);
```

---

## Regression Testing

After bug fixes, add regression tests:

```matlab
function test_bug_123_regression()
% Regression test for Bug #123: Best tracking failure
% Ensure this specific bug never resurfaces

    % Setup that triggered bug
    [setup from bug report]

    % Execute
    result = run_scenario();

    % Verify fix
    assert(result.best_tracked == true, ...
        'Bug #123 regression: best not tracked');
end
```

---

## CI/CD Integration

If using CI/CD (GitHub Actions, etc.):

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: matlab-actions/setup-matlab@v1
      - name: Run tests
        uses: matlab-actions/run-command@v1
        with:
          command: "results = run_tests(); exit(~results.success)"
```

---

## Summary

**TDD Benefits:**
- ✅ Catch bugs early
- ✅ Confidence in refactoring
- ✅ Living documentation
- ✅ Easier debugging
- ✅ Better design

**Quick Commands:**
- `run_tests()` - Run once
- `watch_tests()` - Continuous
- `run_tests('pattern', 'name')` - Specific test
- `run_tests('verbose')` - Detailed output

**Next Steps:**
1. Write test for new feature (Red)
2. Implement feature (Green)
3. Refactor (Refactor)
4. Repeat

Happy testing! 🧪✨
