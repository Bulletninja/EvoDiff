# EvoDiff Codebase Audit — Parallel Specialist Architecture

> **Pattern**: DAG workflow (parallel analysis) + Swiss Cheese synthesis + filesystem-as-memory
> **Evidence**: Multi-agent-ai-architectures.md — Swiss cheese model (92.1% success), filesystem-as-memory (Manus/Anthropic/LangChain), reversible compaction, span of control = 3
> **Anti-patterns avoided**: Telephone game (42% of failures), context degradation, bag-of-agents

## Architecture

```
ORCHESTRATOR (this context)
|
+- PHASE 0: Context Bootstrap ─────────────────────────────
|  IF .claude/audit/session_brief.md EXISTS:
|    Read it → prior findings + implementation state
|    Read progress.json → incomplete tasks
|    Decision: re-audit or resume
|  ELSE:
|    Fresh audit → Phase 1
|
+- PHASE 1: Parallel Specialist Agents (DAG) ──────────────
|  3 agents launched SIMULTANEOUSLY via Task tool
|  Each agent: reads code → analyzes → WRITES JSON to filesystem
|
|  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
|  │ CODE REVIEW      │  │ SECURITY REVIEW  │  │ CONGRUENCE AUDIT │
|  │ Algorithm,       │  │ feval/system,    │  │ 4-layer bounds,  │
|  │ Octave idioms,   │  │ file I/O,        │  │ driver parity,   │
|  │ numerics         │  │ temp files       │  │ contracts        │
|  │                  │  │                  │  │                  │
|  │ Context:         │  │ Context:         │  │ Context:         │
|  │ src/ only        │  │ I/O boundaries   │  │ src/ + tests/    │
|  │                  │  │                  │  │                  │
|  │ WRITES JSON to:  │  │ WRITES JSON to:  │  │ WRITES JSON to:  │
|  │ .claude/audit/   │  │ .claude/audit/   │  │ .claude/audit/   │
|  │ code_review      │  │ security_review  │  │ congruence_audit │
|  │ _findings.json   │  │ _findings.json   │  │ _findings.json   │
|  └──────────────────┘  └──────────────────┘  └──────────────────┘
|
+- PHASE 2: Synthesis (Swiss Cheese cross-reference) ──────
|  Read the 3 JSON files FROM FILESYSTEM (not agent return text)
|  Cross-reference: finding in 2+ agents = confirmed
|  WRITE: action_plan.json, session_brief.md, AUDIT_REPORT.md
|
+- PHASE 3: Report ────────────────────────────────────────
   Present prioritized findings with convergences highlighted
```

## Why This Architecture (Evidence-Based)

| Decision | Evidence | Source |
|----------|----------|--------|
| 3 parallel agents | Context pollution degrades mixed-concern analysis | Anthropic: "irrelevant information dilutes attention" |
| Max 3 agents | Coordination overhead exceeds benefit beyond 3 | Microsoft: max 3; DeepMind: 3-5 optimal |
| Orthogonal specialists | Swiss cheese: different failure modes catch different bugs | 92.1% success, 67pp error reduction |
| **JSON to filesystem** | **Avoids telephone-game (42% of multi-agent failures)** | **MAST Taxonomy; Manus, Anthropic, LangChain** |
| **session_brief.md** | **Reversible compaction: raw > compaction > lossy summary** | **Manus context hierarchy** |
| **Separate storage/presentation** | **JSON = storage, brief = compiled view, report = presentation** | **Google ADK three-tier state model** |
| Debate synthesis | Cross-validation catches false positives + negatives | Financial analysis: inner critic caught 87.8% of errors |

## Project Context

**EvoDiff**: Differential Evolution for flow shop scheduling. ~800 LOC Octave/MATLAB, ~400 LOC tests.

```
src/core/         de_flowshop.m, evaluate_makespan.m, random_permutation.m, permutation_mutate.m
src/experiment/   run_experiment.m, generate_report.m
src/io/           load_config.m, load_problems.m, save_results.m, save_checkpoint.m, load_checkpoint.m, find_latest_checkpoint.m
tests/            11 unit tests + test_acceptance.m bridge
tests/acceptance/ 4-layer Farley acceptance testing (specs/, dsl/, drivers/)
config/           default.json, quick_test.json
data/             taillard_20x5.json (10 benchmark instances)
```

Key abstractions: `Prob` struct (`.P` processing times, `.lb`/`.ub` bounds), `de_flowshop()` returns 6 values, FunctionDriver + ScriptDriver with same acceptance specs.

---

## Execution

### Phase 0: Context Bootstrap

Check if a prior audit exists:

1. Check if `.claude/audit/session_brief.md` exists
2. **If it exists**: Read it. Also read `.claude/audit/progress.json` if present.
   - If there are incomplete tasks in progress.json → ask the user: **re-audit** or **resume implementation**?
   - If all tasks are complete → inform user prior audit is done, offer re-audit
3. **If it does not exist**: Fresh audit. Proceed to Phase 1.

### Phase 1: Prepare + Launch Parallel Agents

First, create the output directory:

```
mkdir -p .claude/audit
```

Then capture the current git ref (short SHA) — agents will embed this in their JSON output. Run:

```
git rev-parse --short HEAD
```

**CRITICAL**: Launch ALL THREE agents simultaneously in a SINGLE message with 3 parallel Task tool calls. Do NOT run sequentially. Use `subagent_type: "general-purpose"` for each.

Each agent:
- Gets its specialist prompt (see Agent Prompts below)
- **The git_ref value must be interpolated into each agent's prompt** so they can embed it in their JSON
- Reads its scoped files
- **WRITES structured JSON** to `.claude/audit/{name}_findings.json` using the Write tool
- Returns a condensed summary (~1000-2000 tokens) to the orchestrator

### Phase 2: Synthesis

After all 3 agents return, **read the 3 JSON files from the filesystem** (do NOT rely on agent return text — that's the telephone game anti-pattern). Parse the JSON and:

1. **Cross-reference by file + line proximity** (same file, lines within 10 of each other):
   - Finding in 3/3 agents → `ALL_THREE` confidence (highest)
   - Finding in 2/3 agents → `TWO_OF_THREE` confidence
   - Single agent only → normal confidence
2. **Deduplicate**: Same issue reported differently → merge, keep most specific description
3. **Conflict**: Agents disagree on severity → use the HIGHER severity, flag the disagreement
4. **Priority sort**: CRITICAL security > CRITICAL correctness > HIGH > MEDIUM > LOW

Then **write three output files**:

#### 2a. Write `.claude/audit/action_plan.json`

```json
{
  "timestamp": "ISO-8601",
  "git_ref": "short SHA from Phase 1",
  "total_findings": 0,
  "swiss_cheese_convergences": [
    {
      "confidence": "ALL_THREE or TWO_OF_THREE",
      "finding_ids": ["CR-003", "SEC-001", "CON-007"],
      "description": "unified description of the converged issue"
    }
  ],
  "prioritized_actions": [
    {
      "priority": 1,
      "severity": "CRITICAL",
      "source_findings": ["CR-001"],
      "description": "what to fix",
      "files": ["src/core/de_flowshop.m"],
      "status": "pending"
    }
  ]
}
```

#### 2b. Write `.claude/audit/session_brief.md`

This is the **reversible compaction** layer — a ~2k token compiled view that any future session can read to recover full context. Template:

```markdown
# EvoDiff Audit Session Brief

## Project
Permutation-based DE for flowshop scheduling (Octave/MATLAB). ~800 LOC src, ~400 LOC tests.

## Last Audit
- **Date**: {today}
- **Git ref**: {short SHA}
- **Scope**: {full or specific paths}
- **Findings**: {N} total ({C} critical, {H} high, {M} medium, {L} low)
- **Swiss Cheese convergences**: {N} all-agent, {N} two-agent

## Top Findings
{bulleted list of CRITICAL and HIGH findings, one line each}

## Implementation Progress
{if implementation has started: list completed/remaining tasks}
{if audit only: "No implementation started yet."}

## Structured Data
- Findings: `.claude/audit/code_review_findings.json`, `security_review_findings.json`, `congruence_audit_findings.json`
- Action plan: `.claude/audit/action_plan.json`
- Progress: `.claude/audit/progress.json` (created when implementation begins)
```

#### 2c. Write `AUDIT_REPORT.md` in project root

Human-readable report with executive summary, Swiss Cheese convergences highlighted, and all findings prioritized. This is the presentation layer.

### Phase 3: Report

Present findings to the user:
1. Executive summary (total counts by severity)
2. Swiss Cheese convergences first (these are highest confidence)
3. Then remaining findings by priority
4. Ask user if they want to proceed with implementation

---

## Agent Prompts

### Agent 1: Code Review Specialist

```
You are a code review specialist for an Octave/MATLAB scientific computing project. Your job is to analyze the codebase and WRITE your findings as structured JSON to a file.

PROJECT: /Users/luis/projects/EvoDiff
TECH STACK: GNU Octave / MATLAB
DOMAIN: Differential Evolution for permutation flow shop scheduling

READ THESE FILES (all production code):
- src/core/de_flowshop.m — main DE algorithm
- src/core/evaluate_makespan.m — fitness function
- src/core/random_permutation.m — random job permutation
- src/core/permutation_mutate.m — mutation operator
- src/experiment/run_experiment.m — multi-problem orchestrator
- src/experiment/generate_report.m — LaTeX/plot output
- src/io/load_config.m — JSON config with defaults
- src/io/load_problems.m — JSON problem loader
- src/io/save_results.m — MAT file saver
- src/io/save_checkpoint.m, load_checkpoint.m, find_latest_checkpoint.m — checkpoint I/O

FOCUS AREAS:

Algorithm Correctness:
- DE population initialization, mutation, selection, elitism
- Permutation validity: after mutation, is result still a valid column permutation?
- Fitness tracking: is best_per_gen correctly recorded every generation?
- Greedy selection: offspring replaces parent only if fitness <= parent fitness
- Stopping criterion correctness
- Selective breeding: selection_ratio controls what fraction breeds

Octave/MATLAB Idioms:
- Copy-on-write: functions that appear to mutate inputs
- 1-based indexing correctness throughout
- reshape/size consistency (M*N flattening and unflattening)
- Variable shadowing (function name reused as variable name)
- Pre-allocation patterns (zeros before loops)

Numerical/Performance:
- Unnecessary copies or redundant computations
- Vectorization opportunities (for-loops that could be matrix ops)
- Memory allocation in hot loops

Error Handling:
- Missing input validation (what if NP=0? max_generations=0? empty Prob.P?)
- Edge cases: single job, single machine, 1-generation run

PROCESS:
1. Read ALL production source files listed above
2. Trace the main algorithm flow: population init -> eval -> sort -> mutate -> select -> repeat
3. Check each function's contract (docstring) vs actual behavior
4. For each finding: exact file:line, code evidence, severity, fix

OUTPUT — CRITICAL INSTRUCTION:
You MUST use the Write tool to save your findings as JSON to this exact path:

  /Users/luis/projects/EvoDiff/.claude/audit/code_review_findings.json

Use this exact JSON schema:

{
  "agent": "code_review",
  "timestamp": "{current ISO-8601 timestamp}",
  "git_ref": "{GIT_REF}",
  "scope": "full",
  "summary": { "critical": 0, "high": 0, "medium": 0, "low": 0 },
  "findings": [
    {
      "id": "CR-001",
      "title": "Short description of the issue",
      "file": "src/core/de_flowshop.m",
      "line": 85,
      "severity": "CRITICAL",
      "category": "Algorithm",
      "evidence": "the relevant code snippet (keep short, 1-3 lines)",
      "issue": "what is wrong and why it matters",
      "fix": "specific suggested fix"
    }
  ]
}

Fill in the summary counts to match your findings array. Update the timestamp to now.

After writing the JSON file, return a condensed text summary (~1000-2000 tokens) listing only: finding ID, severity, one-line description for each finding. The JSON file is the authoritative record; the summary is just for the orchestrator's context.
```

### Agent 2: Security Review Specialist

```
You are a security review specialist for an Octave/MATLAB scientific computing project. Your job is to analyze the codebase for security issues and WRITE your findings as structured JSON to a file.

PROJECT: /Users/luis/projects/EvoDiff
TECH STACK: GNU Octave / MATLAB
NOTE: This is NOT a web app. No OWASP web categories apply. Focus on scientific computing security: code injection, file I/O, deserialization, command execution.

READ THESE FILES:
- All src/ files (production code, including src/io/ checkpoint files)
- tests/acceptance/drivers/create_script_driver.m (uses system() calls)
- setup_paths.m, run_tests.m

FOCUS AREAS:

Code Injection via feval/eval:
- Any feval(), eval(), evalc(), str2func() with user-controlled or config-controlled strings
- Trace: config.fitness_function -> passed as 'f' to de_flowshop -> str2func(f) or feval(f, ...)
- If attacker controls config JSON, they control which function executes
- Check load_config whitelist: is it comprehensive? Can it be bypassed?

Command Injection via system():
- ScriptDriver uses system(sprintf('octave --no-gui --norc "%s"', script_file))
- Are script file paths sanitizable? Shell metacharacters?
- Temp file names from tempname() — predictable?

File Path Handling:
- load_problems(filepath), load_config(filepath) — path traversal?
- Check for path traversal validation (.. sequences, absolute paths)
- fileread() calls with user-provided paths
- Symlinks, very long paths

Temp File Security (ScriptDriver):
- Creates temp .m script files and .mat data files
- tempname() uniqueness — TOCTOU race conditions?
- Cleanup after use (SEC-004 pattern)
- .m script files contain executable Octave code written to disk

Deserialization:
- load() for .mat files — malformed .mat handling?
- jsondecode() — malformed JSON handling?
- Checkpoint load validation — are loaded fields validated?

addpath Security:
- What directories are on the path? Could function shadowing occur?
- Are data/ or config/ directories excluded from path?

PROCESS:
1. Read all source files, focusing on I/O boundaries
2. Trace every external input: file paths, JSON content, config values, system commands
3. For each input, trace flow through code to execution points
4. Assess realistic risk (this is a local research tool, not a server)

OUTPUT — CRITICAL INSTRUCTION:
You MUST use the Write tool to save your findings as JSON to this exact path:

  /Users/luis/projects/EvoDiff/.claude/audit/security_review_findings.json

Use this exact JSON schema:

{
  "agent": "security_review",
  "timestamp": "{current ISO-8601 timestamp}",
  "git_ref": "{GIT_REF}",
  "scope": "full",
  "summary": { "critical": 0, "high": 0, "medium": 0, "low": 0 },
  "input_surface": [
    {
      "entry_point": "load_config(filepath)",
      "input_type": "file path",
      "validated": true,
      "flows_to": "fileread -> jsondecode -> config struct",
      "risk": "LOW"
    }
  ],
  "trust_boundaries": [
    "Config JSON --[parsed]--> load_config --[fitness_function]--> de_flowshop --[str2func]--> function execution"
  ],
  "findings": [
    {
      "id": "SEC-001",
      "title": "Short description",
      "file": "src/core/de_flowshop.m",
      "line": 30,
      "severity": "MEDIUM",
      "category": "CodeInjection",
      "evidence": "code snippet (1-3 lines)",
      "attack_vector": "how exploitable given local research context",
      "realistic_risk": "actual vs theoretical risk assessment",
      "fix": "recommended remediation"
    }
  ]
}

Fill in the summary counts to match your findings array. Update the timestamp to now.

After writing the JSON file, return a condensed text summary (~1000-2000 tokens) listing: finding ID, severity, one-line description, and the input surface map. The JSON file is the authoritative record.
```

### Agent 3: Congruence Audit Specialist

```
You are a code congruence auditor specializing in Dave Farley's 4-layer acceptance testing architecture. Your job is to detect architectural inconsistencies and WRITE your findings as structured JSON to a file.

PROJECT: /Users/luis/projects/EvoDiff
ARCHITECTURE: 4-layer acceptance testing (SPEC -> DSL -> DRIVER -> SYSTEM)

READ THESE FILES (read ALL of them completely):
- tests/acceptance/specs/spec_*.m (all spec files — Layer 1)
- tests/acceptance/dsl/create_context.m (Layer 2)
- tests/acceptance/drivers/create_function_driver.m (Layer 3)
- tests/acceptance/drivers/create_script_driver.m (Layer 3)
- tests/acceptance/run_acceptance_tests.m (runner)
- tests/test_acceptance.m (bridge)
- src/core/de_flowshop.m, src/core/evaluate_makespan.m, src/core/random_permutation.m, src/core/permutation_mutate.m (production)
- src/io/load_config.m, src/io/load_problems.m (production)
- src/experiment/run_experiment.m (production)

CONGRUENCE VIOLATION TYPES:

Layer Boundary Violations:
- SPEC_LEAK: Spec mentions production function name or struct field in executable code (not comments)
- DSL_LOGIC: DSL contains business logic instead of pure delegation
- DRIVER_BYPASS: Spec calls production code directly instead of through ctx

Contract Violations:
- SIGNATURE_IGNORED: Driver accepts parameter but ignores it
- CONTRACT_BREACH: Method's name promises X, implementation does Y
- RETURN_MISMATCH: driver.optimize() output struct missing fields specs expect
- CONFIG_DRIFT: Config field names in specs don't match load_config output
- DATA_FLOW_BREAK: Config value loaded but never reaches its destination

Pattern Inconsistencies:
- DRIVER_DIVERGENCE: FunctionDriver and ScriptDriver produce different results
- MISSING_METHOD: Method in one driver but not the other
- SEMANTIC_MISMATCH: Same method name, different behavior
- VERIFY_DIVERGENCE: Verification helpers differ between drivers
- PATTERN_DIVERGENCE: Similar operations use different patterns

Coverage Violations:
- UNTESTED_CONTRACT: Production behavior not covered by any spec
- TRACEABILITY_GAP: Unit test concern not mapped to acceptance spec
- DEAD_METHOD: Driver method exists but no spec uses it

Test Reality:
- REALITY_MISMATCH: Test models behavior that can't occur in production
- ISOLATION_LEAK: Spec depends on state from another spec

Congruence Principles (from Code Congruence Audit Template):
1. "Don't Ask for What You Already Know" — if the system already has X, don't pass X as parameter
2. "Same Interface = Same Semantics" — parameter means same thing in all implementations
3. "Test What Users Actually Do" — tests model real usage, not shortcuts

6-PASS PROCESS:
1. LAYER BOUNDARIES: Grep spec files for production function names and struct fields. Match in executable code = SPEC_LEAK
2. DRIVER PARITY: Compare FunctionDriver and ScriptDriver method-by-method. Same methods? Same signatures? Same output contracts?
3. CONTRACT MAP: For each driver method, trace: spec call -> ctx delegation -> driver method -> production function. Verify chain is complete.
4. DSL PURITY: Read create_context.m. Every line should be ctx.X = driver.Y. Any logic/computation = DSL_LOGIC violation.
5. COVERAGE: Map each unit test to acceptance spec assertions. Flag gaps.
6. PARAMETER REALITY: For each driver function parameter, trace usage. Flag unused.

OUTPUT — CRITICAL INSTRUCTION:
You MUST use the Write tool to save your findings as JSON to this exact path:

  /Users/luis/projects/EvoDiff/.claude/audit/congruence_audit_findings.json

Use this exact JSON schema:

{
  "agent": "congruence_audit",
  "timestamp": "{current ISO-8601 timestamp}",
  "git_ref": "{GIT_REF}",
  "scope": "full",
  "summary": { "critical": 0, "medium": 0, "low": 0 },
  "layer_boundary_audit": [
    {
      "file": "tests/acceptance/specs/spec_solution_search.m",
      "production_name_found": "evaluate_makespan",
      "line": 42,
      "violation": "SPEC_LEAK"
    }
  ],
  "driver_parity": [
    {
      "method": "optimize",
      "function_driver": "present, passes 6 args",
      "script_driver": "present, passes 6 args",
      "match": true,
      "issue": null
    }
  ],
  "contract_chains": [
    {
      "spec_call": "ctx.optimize(problem, opts)",
      "ctx_method": "optimize",
      "driver_method": "do_optimize",
      "production_function": "de_flowshop",
      "chain_complete": true
    }
  ],
  "coverage_traceability": [
    {
      "unit_test": "test_makespan (5 assertions)",
      "acceptance_spec": "spec_schedule_evaluation (4 assertions)",
      "covered": true,
      "gap": null
    }
  ],
  "findings": [
    {
      "id": "CON-001",
      "title": "Short description",
      "component_a": { "file": "path/a.m", "line": 10, "code": "snippet A" },
      "component_b": { "file": "path/b.m", "line": 20, "code": "snippet B" },
      "violation_type": "SIGNATURE_IGNORED",
      "severity": "MEDIUM",
      "gap": "the inconsistency",
      "resolution": "proposed fix"
    }
  ]
}

Fill in the summary counts to match your findings. Update the timestamp to now.

After writing the JSON file, return a condensed text summary (~1000-2000 tokens) listing: finding ID, violation type, severity, one-line description, plus the driver parity and coverage traceability summaries. The JSON file is the authoritative record.
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Document Evidence | Instead |
|--------------|-------------------|---------|
| Reading agent return text instead of JSON files | "Telephone game" — 42% of failures | Read `.claude/audit/*.json` files directly |
| Single agent for all concerns | Context pollution degrades analysis | 3 parallel specialists with orthogonal focus |
| Fixing during audit | "Parallelize review, serialize generation" | Audit first, fix separately |
| No persistent state | Context degradation across sessions | JSON files + session_brief.md |
| Skipping synthesis | Misses cross-agent convergences | Always cross-reference the 3 JSON files |
| Reporting style as CRITICAL | Dilutes real findings | Reserve CRITICAL for security + correctness |
| >3 agents | 17.2x error amplification | Hard ceiling: 3 specialists per coordinator |
