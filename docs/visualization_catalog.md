# EvoDiff Visualization Catalog

Research-backed visualization techniques for Differential Evolution on Permutation Flow Shop Scheduling (PFSP). All techniques validated for GNU Octave feasibility.

**Context**: DE algorithm with configurable variants (normal/selective, OX1/column_diff crossover, with/without local search, with/without population reduction) solving Taillard 20x5 benchmarks.

---

## Table of Contents

1. [Animations](#a-animations)
2. [Flowshop-Specific Plots](#b-flowshop-specific-plots)
3. [Statistical / Performance Comparison](#c-statistical--performance-comparison)
4. [Advanced / Deep Analysis](#d-advanced--deep-analysis)
5. [Dashboard Layouts](#e-dashboard-layouts)
6. [Octave Technical Reference](#f-octave-technical-reference)
7. [Implementation Recommendations](#g-implementation-recommendations)
8. [Academic References](#h-academic-references)

---

## A. Animations

### A1. Fitness Distribution Ridgeline (Animated GIF)

**What it shows**: Population fitness histogram per generation, stacked/overlapping. The distribution narrows and shifts left as the algorithm converges. Premature convergence is diagnosed when the distribution collapses too early without reaching good objective values.

**Why it matters**: Reveals the *shape* of convergence — not just the best value but how the entire population behaves. Bimodal distributions indicate the population is split between two search regions. A distribution that narrows without shifting indicates stagnation.

**Data needed**: All fitness values per generation (not just best — requires storing full population fitness at each generation or sampled generations).

**Implementation**:
- X-axis: makespan (or RPD); Y-axis: frequency/density
- One frame per generation (or every N generations for long runs)
- Use `ksdensity()` (statistics package) for smooth curves
- Overlay vertical line at UB (best known solution)
- Color gradient from blue (early) to red (late)
- Export: `getframe` + `rgb2ind` + `imwrite(..., 'gif', 'WriteMode', 'append')`

**Academic usage**: Storn & Price (1997) in the original DE paper; Das & Suganthan (2011) DE survey.

---

### A2. Permutation Frequency Matrix (Animated)

**What it shows**: A 20x20 heatmap where cell(job, position) = frequency of job `j` appearing in position `p` across the entire population. Starts nearly uniform (~1/N everywhere), converges to near-binary (0 or 1) as the population agrees on job placements.

**Why it matters**: This is the most visually striking and informative animation for understanding search dynamics in permutation-based optimization. It reveals:
- Which positions converge first (often first and last jobs in PFSP)
- Whether there are "consensus positions" vs "flexible positions"
- Population diversity collapse patterns

**Data needed**: Full population at each generation (or sampled generations). For each generation, compute the N x N frequency matrix.

**Implementation**:
```matlab
freq = zeros(N_jobs, N_jobs);
for ind = 1:NP
    perm = get_job_order(population(:, ind), M, N);
    for pos = 1:N_jobs
        freq(perm(pos), pos) = freq(perm(pos), pos) + 1;
    end
end
freq = freq / NP;  % normalize to [0, 1]
imagesc(freq); colorbar; colormap(viridis);
xlabel('Position'); ylabel('Job');
```

**Related to**: Estimation of Distribution Algorithms (EDAs). Ceberio et al. (2012) "A review on estimation of distribution algorithms in permutation-based combinatorial optimization problems" uses exactly these frequency matrices.

---

### A3. Gantt Chart Evolution

**What it shows**: The best-found schedule rendered as a Gantt chart, updating each time a new best is found. Jobs shift positions, idle gaps shrink, makespan line moves left.

**Why it matters**: This is the *phenotype* visualization for PFSP. While the genotype is a permutation, the phenotype is a schedule. Watching how the Gantt chart changes reveals which jobs are being repositioned and how idle times are being eliminated.

**Data needed**: Best individual at each generation (already tracked as `best_individual`). Compute `C_mat` from `evaluate_makespan` to get start/end times.

**Implementation**:
- Show Gantt chart of best solution
- When new best found, redraw with transition
- Highlight which jobs moved positions
- Show makespan as a vertical line moving left
- Use `patch()` or `rectangle()` for job blocks

---

### A4. MDS Population Scatter (Animated)

**What it shows**: Project the entire population into 2D using Multidimensional Scaling on pairwise Kendall-tau distances. Each dot = one solution, colored by fitness. Dots cluster, merge, and collapse over generations.

**Why it matters**: You can literally *see* the population forming clusters, splitting, merging, or collapsing to a single point. This is the most direct visualization of search space exploration.

**Projection methods for permutations**:
- MDS (Multidimensional Scaling) on pairwise Kendall-tau distance matrix — `cmdscale()` in Octave
- Spearman footrule distance as an alternative (cheaper to compute)
- Cayley distance (minimum transpositions)

**Data needed**: Full population at each generation. Pairwise distance computation is O(NP^2 * N log N).

**Implementation**:
```matlab
% Compute pairwise Kendall-tau distances
D = zeros(NP);
for i = 1:NP
    for j = i+1:NP
        D(i,j) = kendall_tau(pop(:,i), pop(:,j));
        D(j,i) = D(i,j);
    end
end
coords = cmdscale(D, 2);  % project to 2D
scatter(coords(:,1), coords(:,2), 30, fitness, 'filled');
colorbar; colormap(hot);
```

**References**: Humeau et al. (2013) "ParadisEO-MO"; Ochoa et al. (2014) Local Optima Network work projects PFSP solution spaces this way.

---

### A5. NEH Construction Step-by-Step

**What it shows**: Animated Gantt chart showing the NEH heuristic building a solution incrementally — inserting jobs one by one, testing all positions, placing at the best.

**Why it matters**: Pedagogical and visually satisfying. Shows how a constructive heuristic builds a good solution from scratch, and why NEH produces strong initial solutions.

**Data needed**: Instrument `neh_heuristic.m` to emit intermediate solutions.

**Implementation**: Frame loop: at step k, show the partial schedule with k jobs placed. Highlight the newly inserted job in a brighter color.

---

## B. Flowshop-Specific Plots

### B1. Gantt Chart with Critical Path

**What it shows**: Standard schedule visualization — machines on Y-axis, time on X-axis, jobs as colored horizontal blocks. The critical path (longest path through the completion time matrix) is highlighted in red, showing exactly why the makespan is what it is.

**Why it matters**: The most iconic flowshop visualization. Immediately reveals:
- Machine utilization (gap = idle time)
- Bottleneck identification (which machine/job is on the critical path)
- Schedule quality (how tight the packing is)

**Data needed**: Processing times `P`, job permutation, completion time matrix `C_mat` (already computed in `evaluate_makespan`).

**Critical path computation**:
```matlab
% Backtrack from C_mat(M,N) to find critical path
path = [];
i = M; j = N;
while i > 1 || j > 1
    path = [path; i, j];
    if i == 1
        j = j - 1;
    elseif j == 1
        i = i - 1;
    elseif C_mat(i-1,j) >= C_mat(i,j-1)
        i = i - 1;  % same job, previous machine
    else
        j = j - 1;  % previous job, same machine
    end
end
path = [path; 1, 1];
path = flipud(path);
```

**Gantt rendering**:
```matlab
for machine = 1:M
    for job = 1:N
        start = C_mat(machine, job) - P(machine, perm(job));
        duration = P(machine, perm(job));
        rectangle('Position', [start, machine-0.4, duration, 0.8], ...
                  'FaceColor', job_colors(perm(job),:), 'EdgeColor', 'k');
    end
end
% Overlay critical path as thick red line
```

**References**: Standard in all PFSP literature. Critical path method from Taillard (1990).

---

### B2. Side-by-Side Gantt: NEH vs DE Best

**What it shows**: Two Gantt charts in one figure — the initial NEH solution and the DE-optimized solution. The makespan improvement is immediately visible.

**Why it matters**: Directly demonstrates the value of the DE optimization over the constructive heuristic. Makes the improvement tangible and visual.

**Implementation**: `subplot(1,2,1)` for NEH, `subplot(1,2,2)` for DE best. Same Y-axis scale, same color mapping. Highlight makespan line on both.

---

### B3. Machine Utilization Bars

**What it shows**: 5 horizontal bars (one per machine), each decomposed into processing time (colored) and idle time (gray). Machine 1 always has 100% utilization in PFSP.

**Why it matters**: Shows where time is wasted. If machine 3 has 30% idle time, the DE might benefit from prioritizing job orderings that reduce that specific bottleneck.

**Computation**:
```matlab
for i = 1:M
    processing(i) = sum(P(i,:));
    total_time(i) = C_mat(i, N);  % completion of last job
    idle(i) = total_time(i) - processing(i);
    utilization(i) = processing(i) / total_time(i);
end
```

**Implementation**: `barh(1:M, [processing', idle'], 'stacked')` with processing in color, idle in gray.

---

### B4. Job Waiting Time Heatmap

**What it shows**: (M-1) x N matrix where cell(transition, job) = time job waits between finishing on machine `i` and starting on machine `i+1`.

**Why it matters**: Reveals where jobs are stuck waiting — complementary to machine idle time. High waiting times on specific jobs suggest they should be repositioned in the permutation.

**Computation**:
```matlab
wait = zeros(M-1, N);
for j = 1:N
    for i = 1:M-1
        start_next = C_mat(i+1, j) - P(i+1, perm(j));
        wait(i, j) = start_next - C_mat(i, j);
    end
end
```

**Implementation**: `imagesc(wait); colorbar; xlabel('Job'); ylabel('Transition');`

---

### B5. Makespan Breakdown Stacked Bars

**What it shows**: Per-machine stacked bars decomposing total time into processing segments (one per job, in order) with idle gaps shown as gray segments interspersed.

**Why it matters**: More detailed than B3 — shows not just total idle time but *where* idle time occurs within each machine's schedule.

**Implementation**: Loop through jobs in permutation order, drawing `barh` segments with gaps.

---

## C. Statistical / Performance Comparison

### C1. Heat Matrix (Variant x Problem RPD)

**Insight rank**: 1 (most data per pixel)

**What it shows**: Matrix where rows = algorithm variants, columns = problem instances, cell color = RPD. Annotated with numeric values.

**Why it matters**: Single most information-dense comparison plot. Immediately reveals:
- Which variant is best on which problems
- Whether certain variants are specialists vs generalists
- Whether problem difficulty follows a pattern
- Overall performance patterns

**Implementation**:
```matlab
imagesc(rpd_matrix);
colorbar;
colormap(hot);
% Annotate with values
for i = 1:num_variants
    for j = 1:num_problems
        text(j, i, sprintf('%.2f', rpd_matrix(i,j)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
end
set(gca, 'YTick', 1:num_variants, 'YTickLabel', variant_names);
set(gca, 'XTick', 1:num_problems, 'XTickLabel', problem_ids);
```

**Enhancement**: Add a final column for ARPD (average) and a final row for instance average. Use a diverging colormap (blue-white-red) centered on median RPD.

---

### C2. Convergence with Confidence Bands

**Insight rank**: 2 (direct upgrade of current `generate_report.m`)

**What it shows**: Mean convergence curve per variant as a solid line, with shaded band showing the 10th-90th percentile range across runs.

**Why it matters**: The current report plots only `mean(vals, 1)`. This hides variance. Adding confidence bands shows whether a "better mean" is statistically meaningful or within noise.

**Implementation**:
```matlab
x = 1:max_gen;
upper = prctile(vals, 90, 1);
lower = prctile(vals, 10, 1);
mu = mean(vals, 1);
% Use lighter tint for band (no alpha in Octave)
band_color = color * 0.3 + 0.7;  % lighten toward white
patch([x, fliplr(x)], [upper, fliplr(lower)], band_color, 'EdgeColor', 'none');
hold on;
plot(x, mu, 'Color', color, 'LineWidth', 2);
```

**Note**: Octave `FaceAlpha` is unreliable. Use lighter RGB tint colors instead.

---

### C3. Performance Profiles (Dolan-More)

**Insight rank**: 3 (gold standard for benchmarking)

**What it shows**: For each variant, CDF of the performance ratio tau = result / best_result across all instances. X-axis = tau (how far from best), Y-axis = fraction of problems solved within that ratio.

**Why it matters**: Integrates both "how often is it best?" (value at tau=1) and "how bad is it when it's not best?" (curve shape). The variant whose curve reaches 1.0 earliest is the most robust.

**Construction**:
```matlab
% For each variant v, on each problem p:
ratio(v,p) = rpd(v,p) / min(rpd(:,p));  % if using RPD
% Or for makespan:
ratio(v,p) = makespan(v,p) / min(makespan(:,p));

% Sort ratios and plot as step function
for v = 1:num_variants
    sorted = sort(ratio(v,:));
    stairs(sorted, (1:num_problems)/num_problems, 'LineWidth', 2);
end
```

**Reference**: Dolan & More (2002) "Benchmarking optimization software with performance profiles." Standard in mathematical programming, increasingly used in metaheuristics.

---

### C4. Ablation Waterfall

**Insight rank**: 4 (answers "why is this variant better?")

**What it shows**: Starting from a baseline (random init, column_diff, no LS, no pop reduction), each bar shows the ARPD delta from adding one component: +NEH → +OX1 → +local search → +pop reduction.

**Why it matters**: Directly quantifies each component's contribution. Essential for algorithm design justification.

**Data needed**: Run each ablation configuration (2^4 = 16 variants for a full factorial, or 5 cumulative additions for a waterfall).

**Implementation**:
```matlab
baseline = 5.2;   % ARPD with no improvements
deltas = [-1.8, -0.9, -0.4, -0.3];  % NEH, OX1, LS, pop_red
labels = {'Baseline', '+NEH', '+OX1', '+LS', '+PopRed'};
cumulative = cumsum([baseline, deltas]);

% Draw floating bars
for i = 2:length(cumulative)
    if deltas(i-1) < 0  % improvement
        rectangle('Position', [i-0.4, cumulative(i), 0.8, abs(deltas(i-1))], ...
                  'FaceColor', [0.2 0.7 0.3]);
    end
end
% Add connector lines between bars
```

**Design note**: Component addition order matters. For rigor, use Shapley values (average marginal contribution across all orderings) or present multiple orderings.

---

### C5. Violin Plots

**Insight rank**: 5 (shows distribution, not just mean)

**What it shows**: Full probability density of final fitness values per variant, mirrored symmetrically. Reveals bimodality, skewness, and outliers that box plots hide.

**Why it matters**: If the DE sometimes finds the global optimum and sometimes gets stuck, a box plot shows a misleading "average" while a violin reveals the bimodal distribution.

**Implementation**:
```matlab
pkg load statistics;
data = [variant1_rpd, variant2_rpd, variant3_rpd];
violin(data);
set(gca, 'XTickLabel', {'normal', 'selective', 'no-LS'});
ylabel('RPD (%)');
```

**Enhancement**: Overlay jittered raw data points for a poor-man's raincloud plot:
```matlab
hold on;
for col = 1:num_variants
    jitter = 0.1 * (rand(num_runs, 1) - 0.5);
    scatter(col + jitter, data(:, col), 15, 'k', 'filled');
end
```

---

### C6. Interaction Effect Heatmap

**Insight rank**: 6 (reveals synergies/conflicts between components)

**What it shows**: 2D matrix where rows and columns are algorithm components. Cell value = interaction effect magnitude: does component A help more when combined with component B?

**Why it matters**: Main effects (does OX1 help?) are interesting, but interactions (does OX1 help *more* with local search?) are where real algorithmic insights live.

**Computation**: Full factorial experiment (2^4 = 16 variants). For each pair (A, B):
```
interaction(A,B) = mean(A1B1) - mean(A1B0) - mean(A0B1) + mean(A0B0)
```

**Implementation**: Same `imagesc` + `text` approach as C1. Use diverging colormap (negative = synergy, positive = conflict).

---

### C7. Win/Tie/Loss Matrix

**Insight rank**: 7 (pairwise dominance at a glance)

**What it shows**: NxN matrix where cell(i,j) = "W/T/L" count of variant i against variant j across all problems. Color by win ratio.

**Why it matters**: Shows pairwise dominance relationships that ARPD averages can hide.

**Computation**: For each pair of variants on each problem, compare mean RPD. Use Wilcoxon signed-rank test for statistical significance (win if p < 0.05 and better, tie if not significant, loss if worse).

**Implementation**: `imagesc(win_ratio_matrix)` for background, `text()` for "W/T/L" strings.

---

### C8. Bump Chart (Rank Across Problems)

**Insight rank**: 8 (rank stability visualization)

**What it shows**: X-axis = problem instance, Y-axis = rank (inverted, rank 1 at top). Each variant is a line connecting its ranks. Crossings show rank instability.

**Why it matters**: Reveals whether rankings are stable (parallel lines) or volatile (many crossings). If variant A is always rank 1, the story is simple. If ranks swap, it's nuanced.

**Implementation**:
```matlab
% Compute ranks per problem
for p = 1:num_problems
    [~, idx] = sort(rpd(:, p));
    ranks(idx, p) = 1:num_variants;
end
% Plot with inverted Y
for v = 1:num_variants
    plot(1:num_problems, ranks(v,:), '-o', 'LineWidth', 2);
end
set(gca, 'YDir', 'reverse');
ylabel('Rank (1 = best)');
```

---

### C9. Phase Portrait (Diversity vs Fitness)

**Insight rank**: 9 (exploration/exploitation dynamics)

**What it shows**: Trajectory through diversity-fitness space. X = population diversity (Kendall-tau or entropy), Y = best fitness. One point per generation, colored by generation number. The trajectory should move right-to-left (decreasing diversity) and downward (improving fitness).

**Why it matters**: Reveals pathological search behaviors:
- Premature convergence: diversity crashes while fitness is still poor
- Stagnation: horizontal trajectory (no progress)
- Cycling: trajectory loops

**Diversity metrics for permutations**:
- Average pairwise Kendall-tau distance
- Positional entropy: H = -(1/n) * sum_i sum_j [p(j,i) * log2(p(j,i))]
- Fitness variance (phenotypic diversity)

**Data needed**: Population diversity at each generation. Requires adding diversity tracking to `de_flowshop.m`.

**Implementation**: `scatter(diversity, fitness, 30, generation_number, 'filled'); colorbar;`

---

### C10. Radar / Spider Chart

**Insight rank**: 10 (multi-metric executive summary)

**What it shows**: Polygon per variant on 5-7 axes: mean RPD, best RPD, convergence speed, consistency (1/std), evaluation efficiency. Normalized to [0,1].

**Why it matters**: Single-glance multi-dimensional comparison. Shows whether one variant dominates all dimensions or makes tradeoffs.

**Implementation**:
```matlab
categories = 5;
angles = linspace(0, 2*pi, categories + 1);
values_closed = [values, values(1)];  % close the polygon
polar(angles, values_closed, '-o');
```

**Caveat**: Radar charts are sensitive to axis ordering (area is an artifact). Keep to 5-7 axes, max 4-5 variants overlaid.

---

## D. Advanced / Deep Analysis

### D1. Time-to-Target (TTT) Plots

**What it shows**: Empirical CDF of the time (function evaluations) needed to first reach a target solution quality. For a fixed target RPD (e.g., 2.0%), run 100+ times, record time to reach target, plot sorted times as CDF.

**Why it matters**: Reveals the *distribution* of runtime — heavy tails indicate some runs are very slow. Can fit theoretical distributions to predict optimal restart strategies. Allows fair comparison: "Algorithm A reaches RPD=2 in 90% of runs within 10^5 evaluations."

**Reference**: Aiex, Resende & Ribeiro (2007) "TTT plots: a perl program to create time-to-target plots."

**Implementation**: `stairs(sorted_times, (1:R)/R)` for each variant.

---

### D2. Population Entropy Over Generations

**What it shows**: Time series of positional entropy. For each position i, compute entropy of the job distribution across the population. Average across positions. Maximum = log2(N), minimum = 0.

**Why it matters**: Reveals *which positions converge first*. In PFSP, often the first and last positions converge earliest (most impact on makespan). Also shows overall convergence speed.

**Enhancement**: Heatmap with positions on Y, generations on X, color = per-position entropy. Reveals spatial convergence patterns.

**Implementation**:
```matlab
for pos = 1:N_jobs
    for job = 1:N_jobs
        p(job) = sum(population_order(:, pos) == job) / NP;
    end
    p = p(p > 0);  % remove zeros for log
    H(pos) = -sum(p .* log2(p));
end
mean_entropy = mean(H);
```

---

### D3. Operator Contribution Tracking

**What it shows**: Timeline marking when each component (DE crossover, local search, population reduction) triggered an improvement to the best fitness.

**Why it matters**: Reveals temporal dynamics — does local search only help early? Does population reduction trigger improvement bursts? This directly informs algorithm design decisions.

**Data needed**: Instrument `de_flowshop.m` to log improvement events: `(generation, operator, old_fitness, new_fitness)`.

**Implementation**: Stem plot with different markers per operator. Or stacked area chart showing fraction of improvements per component over time.

---

### D4. Critical Difference Diagram (Demsar)

**What it shows**: Horizontal axis = average ranks. Variant names positioned at their rank. Horizontal bars connect groups that are NOT significantly different (Nemenyi post-hoc test after Friedman test).

**Why it matters**: The gold standard for statistical comparison in algorithm benchmarking. Shows not just "who is best" but "who is *statistically distinguishably* best."

**Construction**:
1. Rank variants per instance
2. Compute average ranks
3. Friedman test for overall significance
4. Nemenyi post-hoc: CD = q_alpha * sqrt(k*(k+1)/(6*N))
5. Connect groups within one CD

**Reference**: Demsar (2006) "Statistical Comparisons of Classifiers over Multiple Data Sets." Required by many top journals (EJOR, etc.).

**Implementation**: Moderate difficulty — the hardest part is the connecting bar layout algorithm.

---

### D5. Job-Position Consensus Heatmap (Static)

**What it shows**: Across 30 runs of a single variant: which jobs are consistently placed in which positions? 20x20 heatmap, cell = frequency.

**Why it matters**: Reveals the "consensus" of the search — which positions are strongly determined vs. flexible. Strong consensus positions suggest structural features of the optimal solution.

**Implementation**: Same as A2 but static (aggregated across runs, not animated across generations).

---

### D6. ECDF of Final Fitness Values

**What it shows**: Empirical CDF of final fitness values across all runs for each variant, overlaid. A variant whose curve is further left dominates stochastically.

**Implementation**: `stairs()` or `cdfplot()` (from nan package).

---

### D7. Fitness Distance Correlation (FDC)

**What it shows**: Scatter plot of fitness vs distance to nearest known optimum. Strong positive correlation = "big valley" structure (landscape favors local search).

**Why it matters**: Predicts whether local search will be effective on this landscape. PFSP is known to have moderate-to-strong FDC.

**Reference**: Jones & Forrest (1995); applied to PFSP by Reeves (1999).

---

### D8. Local Optima Networks (LONs)

**What it shows**: Graph where nodes = local optima, edges = transitions between them. Reveals the "funnel" structure of the fitness landscape.

**Why it matters**: Shows whether the search space has one big funnel (easy) or multiple competing funnels (hard, prone to premature convergence).

**Reference**: Ochoa & Veerapen (2016) applied LONs to PFSP specifically.

**Implementation**: High effort — requires sampling many local optima and their transitions. Better suited for offline analysis with graph visualization tools (GraphViz, Gephi).

---

## E. Dashboard Layouts

### E1. "At-a-Glance" Summary (6-panel)

One figure that tells the full story of variant comparison.

```
+---------------------------+---------------------------+
| (A) Heat Matrix           | (B) Convergence w/ Bands  |
| Variant x Problem RPD     | All variants, one problem |
| [imagesc + text]          | [patch + plot]            |
+---------------------------+---------------------------+
| (C) Violin Plots          | (D) Performance Profiles  |
| Final RPD distributions   | Dolan-More curves         |
| [violin()]                | [stairs()]                |
+---------------------------+---------------------------+
| (E) Ablation Waterfall    | (F) Win/Tie/Loss Matrix   |
| Component contributions   | Pairwise comparison       |
| [bar + line]              | [imagesc + text]          |
+---------------------------+---------------------------+
```

**Implementation**: `figure('Position', [100 100 1200 900]); subplot(3, 2, k)`.

---

### E2. "Per-Problem Deep Dive" (4-panel)

Detailed view for a single problem instance.

```
+---------------------------+---------------------------+
| (A) Gantt w/ Critical Path| (B) Convergence w/ Bands  |
| Best solution schedule    | All variants overlaid     |
+---------------------------+---------------------------+
| (C) Job-Position Frequency| (D) Machine Utilization   |
| Consensus heatmap         | Processing vs idle bars   |
+---------------------------+---------------------------+
```

---

### E3. "Statistical Rigor" (4-panel)

For publications requiring rigorous statistical comparison.

```
+---------------------------+---------------------------+
| (A) Critical Diff Diagram | (B) Performance Profiles  |
| Nemenyi post-hoc          | Dolan-More curves         |
+---------------------------+---------------------------+
| (C) Bootstrap CI Forest   | (D) Interaction Heatmap   |
| Mean RPD per variant      | Component interactions    |
+---------------------------+---------------------------+
```

---

### E4. "Algorithm Dynamics" (4-panel)

Understanding how the DE behaves during the search.

```
+---------------------------+---------------------------+
| (A) Phase Portrait        | (B) Population Entropy    |
| Diversity vs Fitness traj | Per-position over gens    |
+---------------------------+---------------------------+
| (C) Operator Contribution | (D) Ridgeline Fitness     |
| Which component improves  | Distribution evolution    |
+---------------------------+---------------------------+
```

---

## F. Octave Technical Reference

### F1. Animation (Animated GIF)

```matlab
filename = 'animation.gif';
fig = figure('Visible', 'off');

for frame = 1:num_frames
    % Draw frame content
    clf;
    plot(...);
    drawnow;

    fr = getframe(fig);
    im = frame2im(fr);
    [imind, cm] = rgb2ind(im);

    if frame == 1
        imwrite(imind, cm, filename, 'gif', ...
                'LoopCount', Inf, 'DelayTime', 0.2);
    else
        imwrite(imind, cm, filename, 'gif', ...
                'WriteMode', 'append', 'DelayTime', 0.2);
    end
end
close(fig);
```

### F2. MP4 Video

```matlab
pkg load video;
writer = VideoWriter('output.mp4');
writer.FrameRate = 15;
open(writer);
for frame = 1:num_frames
    % Draw frame
    writeVideo(writer, getframe(gcf));
end
close(writer);
```

### F3. Heatmap (since no `heatmap()` in Octave)

```matlab
imagesc(data_matrix);
colorbar;
colormap(viridis);
% Annotate cells
for i = 1:rows
    for j = 1:cols
        text(j, i, sprintf('%.2f', data_matrix(i,j)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8, ...
             'Color', pick_contrast_color(data_matrix(i,j)));
    end
end
set(gca, 'YTick', 1:rows, 'YTickLabel', row_labels);
set(gca, 'XTick', 1:cols, 'XTickLabel', col_labels);
```

### F4. Confidence Band (no alpha transparency)

```matlab
% Lighten color for band instead of using FaceAlpha
band_color = color * 0.3 + 0.7;  % shift toward white
x = 1:n;
upper = prctile(data, 90, 1);
lower = prctile(data, 10, 1);
mu = mean(data, 1);
patch([x, fliplr(x)], [upper, fliplr(lower)], band_color, 'EdgeColor', 'none');
hold on;
plot(x, mu, 'Color', color, 'LineWidth', 2);
```

### F5. Violin Plots

```matlab
pkg load statistics;
violin(data_matrix, 'Nbins', 50, 'Width', 0.5);
```

### F6. Available Colormaps

Perceptually uniform: `viridis` (default), `turbo`

Sequential: `hot`, `cool`, `gray`, `bone`, `copper`, `pink`, `ocean`, `cubehelix`

Diverging: construct manually:
```matlab
n = 256;
half = n/2;
blue_to_white = [linspace(0.2,1,half)', linspace(0.3,1,half)', linspace(0.7,1,half)'];
white_to_red = [linspace(1,0.8,half)', linspace(1,0.2,half)', linspace(1,0.2,half)'];
diverging = [blue_to_white; white_to_red];
colormap(diverging);
```

### F7. Export Formats

| Format | Command | Notes |
|---|---|---|
| PNG 300dpi | `print(fig, 'file.png', '-dpng', '-r300')` | Raster, good for web |
| PDF | `print(fig, 'file.pdf', '-dpdf')` | Vector, good for papers |
| SVG | `print(fig, 'file.svg', '-dsvg')` | Vector, editable |
| EPS | `print(fig, 'file.eps', '-depsc2')` | Vector, LaTeX-friendly |
| TikZ | `print(fig, 'file.tex', '-dtikz')` | Native LaTeX |
| Animated GIF | See F1 above | Via `imwrite` loop |

### F8. Key Limitations

- **`FaceAlpha` on patches**: Works on this Octave installation (tested). Use `'FaceAlpha', 0.25` for translucent confidence bands
- **No `heatmap()`**: Use `imagesc()` + annotation loops
- **No `swarmchart()`**: Use `scatter()` with manual jitter
- **No `tiledlayout()`**: Use `subplot()` or `subplot('Position', [x y w h])`
- **LaTeX interpreter**: Works in `print()` exports only, not on-screen
- **`getframe()` in headless mode**: Use `figure('Visible', 'off')` — works but some toolkits may have quirks

---

## G. Implementation Recommendations

### Priority Order

| Priority | ID | Plot | Why first | Effort |
|---|---|---|---|---|
| 1 | B1 | Gantt chart with critical path | Most iconic PFSP visualization, immediately useful | Medium |
| 2 | A2 | Animated permutation frequency matrix | Revives old per-generation distribution spirit, visually striking | Medium |
| 3 | C1 | Heat matrix (variant x problem) | Most insight per pixel, trivial to implement | Low |
| 4 | C2 | Convergence with confidence bands | Direct upgrade of existing `generate_report.m` | Low |
| 5 | C4 | Ablation waterfall | Answers "why is this variant config better?" | Medium |
| 6 | C5 | Violin plots | Built-in, shows full distributions | Low |
| 7 | C3 | Performance profiles (Dolan-More) | Gold standard for benchmarking | Medium |
| 8 | B3 | Machine utilization bars | Simple, informative for flowshop understanding | Low |
| 9 | C8 | Bump chart | Easy to implement, shows rank stability | Low |
| 10 | D4 | Critical difference diagram | Statistical rigor for publications | High |

### Data Collection Requirements

Several visualizations require data not currently collected by `de_flowshop.m`:

| Data | Currently collected? | Needed by | Collection cost |
|---|---|---|---|
| Best fitness per generation | Yes (`best_per_gen`) | C2, most convergence plots | None |
| Final fitness per run | Yes (`vals(:, end)`) | C1, C3, C5, C7 | None |
| Best individual | Yes (`best_individual`) | B1, B2 | None |
| Full population fitness per generation | No | A1 (ridgeline) | Low (store vector per gen) |
| Full population per generation | No | A2, A4, D2 | High (NP * M*N per gen) |
| Improvement events with operator tag | No | D3 | Low (log events) |
| Population diversity per generation | No | C9 (phase portrait) | Medium (pairwise distances) |

### Integration with Existing Code

The recommended approach is to extend `generate_report.m` with new plot functions, keeping each visualization as an independent function that takes `results` and `config` structs:

```
src/visualization/
    plot_gantt.m              — B1: Gantt chart with critical path
    plot_gantt_comparison.m   — B2: Side-by-side NEH vs DE
    plot_machine_utilization.m — B3: Machine utilization bars
    plot_heat_matrix.m        — C1: Variant x problem heatmap
    plot_convergence_bands.m  — C2: Convergence with confidence bands
    plot_performance_profile.m — C3: Dolan-More curves
    plot_ablation_waterfall.m — C4: Ablation waterfall
    plot_violin_comparison.m  — C5: Violin plots
    plot_bump_chart.m         — C8: Rank stability
    animate_frequency_matrix.m — A2: Animated permutation frequency
```

---

## H. Academic References

### Visualization Methodology

- Dolan & More (2002). "Benchmarking optimization software with performance profiles." Mathematical Programming.
- Demsar (2006). "Statistical Comparisons of Classifiers over Multiple Data Sets." JMLR.
- Aiex, Resende & Ribeiro (2007). "TTT plots: a perl program to create time-to-target plots." Optimization Letters.
- Benavoli et al. (2017). "Time for a Change: a Tutorial for Comparing Multiple Classifiers Through Bayesian Analysis." JMLR.

### Evolutionary Algorithm Visualization

- Storn & Price (1997). "Differential Evolution — A Simple and Efficient Heuristic for Global Optimization." Journal of Global Optimization.
- Das & Suganthan (2011). "Differential Evolution: A Survey of the State-of-the-Art." IEEE Trans. Evolutionary Computation.
- Ceberio et al. (2012). "A review on estimation of distribution algorithms in permutation-based combinatorial optimization problems." Progress in Artificial Intelligence.
- Ochoa et al. (2014). "Understanding Phase Transitions with Local Optima Networks." Evolutionary Computation in Combinatorial Optimization (EvoCOP).

### Flow Shop Scheduling

- Taillard (1993). "Benchmarks for basic scheduling problems." European Journal of Operational Research.
- Ruiz & Stutzle (2007). "A simple and effective iterated greedy algorithm for the permutation flowshop scheduling problem." European Journal of Operational Research.
- Pan, Tasgetiren & Liang (2008). "A discrete differential evolution algorithm for the permutation flowshop scheduling problem." Computers & Industrial Engineering.
- Reeves (1999). "Landscapes, operators and heuristic search." Annals of Operations Research.
- Jones & Forrest (1995). "Fitness Distance Correlation as a Measure of Problem Difficulty for Genetic Algorithms." ICGA.
- Ochoa & Veerapen (2016). "Local Optima Networks for Flowshop Scheduling." Applied to PFSP in EvoCOP and CEC venues.

### Diversity and Landscape Analysis

- Humeau et al. (2013). "ParadisEO-MO: From Fitness Landscape Analysis to Efficient Local Search Algorithms." Metaheuristics for Bi-level Optimization.
- Bosman & Thierens (2001). "Crossing the Road to Efficient IDEAs for Permutation Problems." GECCO.
- Ceberio et al. (2014). "A Distance-based Ranking Model Estimation of Distribution Algorithm for the Flowshop Scheduling Problem." IEEE CEC.

### Benchmarking Frameworks

- Hansen et al. (2021). "COCO: A Platform for Comparing Continuous Optimizers in a Black-Box Setting." Journal of Machine Learning Research.
- Doerr et al. (2018). "IOHprofiler: A Benchmarking and Profiling Tool for Iterative Optimization Heuristics." arXiv.
- Lopez-Ibanez et al. (2016). "The irace package: Iterated Racing for Automatic Algorithm Configuration." Operations Research Perspectives.
