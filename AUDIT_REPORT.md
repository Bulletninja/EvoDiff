# EvoDiff Codebase Audit Report v2

**Date**: 2026-02-11
**Git ref**: c6b15d3 (post-v1 fixes)
**Methodology**: 3 parallel specialist agents + Swiss Cheese synthesis
**Agents**: Code Review (CR), Security Review (SEC), Congruence Audit (CON)
**Scope**: Full codebase (~800 LOC production, ~400 LOC tests, acceptance infrastructure)

---

## Executive Summary

| Severity | Count | Agents |
|----------|-------|--------|
| CRITICAL | 1 | CR |
| HIGH | 2 | CR |
| MEDIUM | 11 | CR(5) + SEC(3) + CON(3) |
| LOW | 18 | CR(7) + SEC(7) + CON(4) |
| **Total** | **32** | |

**Swiss Cheese convergences** (same issue caught by 2+ agents = highest confidence):
1. **CR-112 + SEC-006**: load_checkpoint deserializes .mat without deep type validation
2. **CON-001 + CON-006**: driver.run_experiment pass-through leaks production struct to specs

**Context**: This is audit v2, run after v1's 62 findings were all fixed and committed. The codebase is significantly cleaner — no CRITICAL security issues remain, the DE algorithm has proper selection/mutation, and configs are properly validated. The remaining CRITICAL (CR-101) is a subtle index-mismatch in the selection replacement logic.

---

## CRITICAL Findings

### 1. CR-101: DE Selection Replaces Wrong Individual
**Location**: `src/core/de_flowshop.m`:102
**Agent**: Code Review
**Confidence**: HIGH

Offspring `i` is mutated from parent `a1(i)` and compared against `parent_fitness(i) = fitness(a1(i))`. On acceptance, it replaces position `i` — not position `a1(i)`. This means:
- A strong individual at position `i` can be silently overwritten by an offspring that beat a different, weaker parent
- The actual parent at `a1(i)` is never replaced, violating standard DE greedy selection

**Fix**: `population(:, a1(i)) = ui(:,i); fitness(a1(i)) = fitness_tmp;`

---

## HIGH Findings

### 2. CR-102: Selective Mode Freezes Bottom Population
**Location**: `src/core/de_flowshop.m`:73
**Agent**: Code Review

When `selective=true`, only positions `1:mid` are mutated. Population is sorted each generation, so `mid+1:NP` always contain the worst individuals — never challenged, frozen from initialization. Effectively shrinks the working population.

**Fix**: Use `randperm(NP, mid)` for mutation targets, or document as intentional.

---

### 3. CR-103: permutation_mutate Returns Clone When Parents Identical
**Location**: `src/core/permutation_mutate.m`:21
**Agent**: Code Review

When both parents have the same column order (common in converged populations), `c = find(any(p ~= m, 1))` is empty and no mutation occurs. This eliminates exploration entirely, accelerating premature convergence.

**Fix**: Add fallback swap when `c` is empty.

---

## Swiss Cheese Convergences

### Convergence 1: Checkpoint Deserialization (CR-112 + SEC-006)
**Files**: `src/io/load_checkpoint.m`:15
**Agents**: Code Review + Security Review (2/3)
**Severity**: MEDIUM

Both agents independently identified that `load()` deserializes .mat files with only field-existence assertions. No deep type validation on FS struct fields (.P, .lb, .ub). A corrupted or crafted checkpoint could inject non-numeric data into the DE algorithm.

**Fix**: Add `assert(isnumeric(FS(i).P))` etc. after loading.

---

### Convergence 2: run_experiment Pass-Through (CON-001 + CON-006)
**Files**: Both drivers' `run_experiment` + `spec_experiment_orchestration.m`
**Agent**: Congruence Audit (related findings)
**Severity**: MEDIUM

Every other driver method (`do_optimize`, `evaluate_schedule`, etc.) translates production structs into domain-named fields. `run_experiment` is the sole exception — a bare `@(problems, config) run_experiment(problems, config)` that returns raw production output. This causes the experiment spec to directly access `.stats.vals`, `.stats.nfevals` — a SPEC_LEAK that couples Layer 1 to production layout.

**Fix**: Add struct translation wrapper in both drivers.

---

## MEDIUM Findings

### Algorithm/Validation (5)

| ID | Title | Location |
|----|-------|----------|
| CR-104 | evaluate_makespan no input validation | `evaluate_makespan.m`:13 |
| CR-105 | generate_report hardcodes '20x5' | `generate_report.m`:32 |
| CR-106 | File handle leak in generate_report | `generate_report.m`:21 |
| CR-107 | load_config allows pop_size=1, de_flowshop needs >=2 | `load_config.m`:72 |
| CR-108 | run_experiment loses all progress on single failure | `run_experiment.m`:46 |

### Security (3)

| ID | Title | Location | Status |
|----|-------|----------|--------|
| SEC-003 | Function shadowing via addpath on scripts/tests | `setup_paths.m`:13 | ACCEPTABLE |
| SEC-005 | Executable .m in world-readable temp | `create_script_driver.m`:90 | ACCEPTABLE |
| SEC-006 | Checkpoint deserialization without deep validation | `load_checkpoint.m`:15 | **OPEN** |

### Congruence (3)

| ID | Title | Type |
|----|-------|------|
| CON-001 | Experiment spec leaks production struct layout | SPEC_LEAK |
| CON-004 | Checkpoint has zero acceptance coverage | TRACEABILITY_GAP |
| CON-006 | driver.run_experiment breaks translation pattern | CONTRACT_BREACH |

---

## LOW Findings (18)

### Code Review (7)
CR-109 (stale ui columns), CR-110 (timestamp collisions), CR-111 (malformed checkpoint filenames), CR-112 (checkpoint trust), CR-113 (no vectorization), CR-114 (variable shadowing), CR-115 (fopen unchecked)

### Security (7)
SEC-001 (str2func mitigated), SEC-002 (shell cmd safe), SEC-004 (TOCTOU race), SEC-007 (load_problems path), SEC-008 (feval test names), SEC-009 (integer %d safe), SEC-010 (results_dir symlink)

### Congruence (4)
CON-002 (8 verification helpers duplicated), CON-003 (do_small_instance duplicated), CON-005 (config error paths), CON-007 (script driver untested in CI)

---

## Comparison: v1 vs v2

| Metric | v1 (pre-fixes) | v2 (post-fixes) |
|--------|----------------|-----------------|
| Total findings | 62 | 32 |
| CRITICAL | 5 | 1 |
| Security CRITICALs | 1 | 0 |
| All-agent convergences | 2 | 0 |
| Two-agent convergences | 4 | 2 |

The v1 fixes eliminated all security-critical issues, all architecture-critical issues, and most algorithm-critical issues. The remaining CRITICAL (CR-101) is a subtle index-mismatch that was likely introduced or exposed by the v1 selection criterion fix.

---

## Prioritized Action Plan

| Priority | Finding(s) | Severity | Description |
|----------|-----------|----------|-------------|
| 1 | CR-101 | CRITICAL | Fix DE selection replacement index |
| 2 | CR-102 | HIGH | Address selective mode population freeze |
| 3 | CR-103 | HIGH | Add fallback mutation for identical parents |
| 4 | CR-112+SEC-006 | MEDIUM | Deep checkpoint validation (convergence) |
| 5 | CON-001+CON-006 | MEDIUM | run_experiment struct translation (convergence) |
| 6 | CR-107 | MEDIUM | Config pop_size >= 2 validation |
| 7 | CR-104 | MEDIUM | evaluate_makespan input validation |
| 8 | CR-105 | MEDIUM | Dynamic dimensions in generate_report |
| 9 | CR-106+115 | MEDIUM | File handle safety in generate_report |
| 10 | CR-108 | MEDIUM | Partial results on experiment failure |
| 11 | CON-004 | MEDIUM | Checkpoint acceptance coverage |
| 12 | SEC-003 | MEDIUM | addpath review |

---

## Methodology

| Decision | Rationale | Evidence |
|----------|-----------|---------|
| 3 parallel agents | Context pollution degrades mixed-concern analysis | Anthropic: "irrelevant information dilutes attention" |
| Orthogonal specialists | Swiss cheese: different failure modes | 92.1% success, 67pp error reduction |
| JSON to filesystem | Avoids telephone-game (42% of failures) | MAST Taxonomy; Manus/Anthropic/LangChain |
| Cross-reference by file+line | Same issue in 2+ agents = confirmed | Swiss cheese model |
| Max 3 agents | Coordination overhead ceiling | Microsoft: max 3; DeepMind: 3-5 optimal |

## Structured Data

- `code_review_findings.json` — 15 findings with line numbers, evidence, fixes
- `security_review_findings.json` — 10 findings with input surface map and trust boundaries
- `congruence_audit_findings.json` — 7 findings with driver parity, contract chains, coverage traceability
- `action_plan.json` — 12 prioritized actions with convergences highlighted
- `session_brief.md` — compact context recovery for future sessions
