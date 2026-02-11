description: "Security review: code injection, unsafe I/O, temp file risks"

# EvoDiff Security Review

You are reviewing an Octave/MATLAB research tool for security issues. **This is NOT a web app** — focus on scientific computing security: code injection, file I/O, command execution, deserialization.

## Scope

Default: all code with I/O or execution boundaries. If `$ARGUMENTS` provided, scope to those files.

Files to read:
- `src/core/de_flowshop.m` — uses `feval(f, ...)` with config-provided function name
- `src/io/load_config.m` — reads and parses JSON from user-specified path
- `src/io/load_problems.m` — reads and parses JSON from user-specified path
- `src/io/save_results.m` — writes .mat files
- `tests/acceptance/drivers/create_script_driver.m` — uses `system()`, creates temp files
- `setup_paths.m` — modifies Octave path

## Focus Areas

**Code Injection via feval:**
- `feval(f, ...)` in de_flowshop.m where `f = config.fitness_function`
- Trace: config JSON -> load_config -> config.fitness_function -> de_flowshop arg -> feval
- If attacker controls config file, they control which function executes

**Command Injection via system():**
- ScriptDriver: `system(sprintf('octave --no-gui --norc "%s"', script_file))`
- Could script_file path contain shell metacharacters?
- tempname() predictability

**File Path Handling:**
- load_problems(filepath), load_config(filepath) — path traversal?
- fileread() with user-provided paths
- Symlinks, `../` sequences, special characters

**Temp File Security (ScriptDriver):**
- Creates .m scripts and .mat files via tempname()
- TOCTOU race between write and execute
- No cleanup after use
- .m scripts contain executable code on disk

**Deserialization:**
- load() for .mat files
- jsondecode() with potentially malformed JSON
- cell2mat() type confusion

## Process

1. Read files focusing on I/O boundaries
2. Trace every external input to its execution point
3. Assess realistic risk (this is a local research tool, not a server)
4. Report with evidence and practical fix suggestions

## Output Format

For each finding:

### SEC-NNN: {Title}
**Location**: {file}:{line}
**Severity**: CRITICAL / HIGH / MEDIUM / LOW
**Category**: CodeInjection | CommandInjection | PathTraversal | TempFile | Deserialization | InfoDisclosure
**Evidence**: {code snippet}
**Attack Vector**: {how exploitable, given local research context}
**Realistic Risk**: {actual vs theoretical risk}
**Fix**: {remediation}
