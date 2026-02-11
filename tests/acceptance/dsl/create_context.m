function ctx = create_context(driver)
% CREATE_CONTEXT Layer 2 DSL: builds ctx struct from driver
%
% Pure delegation. Each method is a closure capturing the driver.
% Zero business logic. Organizes driver actions into domain sub-structs.

    % Solver — schedule evaluation and optimization
    ctx.solver.evaluate_schedule = driver.evaluate_schedule;
    ctx.solver.optimize = driver.optimize;
    ctx.solver.create_random_schedule = driver.create_random_schedule;

    % Problems — loading and creation
    ctx.problems.taillard = driver.load_taillard;
    ctx.problems.taillard_instance = driver.load_taillard_instance;
    ctx.problems.small_instance = driver.small_instance;
    ctx.problems.dimensions = driver.problem_dimensions;
    ctx.problems.bounds = driver.problem_bounds;

    % Configuration
    ctx.config.defaults = driver.load_defaults;
    ctx.config.from_file = driver.load_config_file;
    ctx.config.quick_test = @() driver.load_config_file('config/quick_test.json');

    % Experiment orchestration
    ctx.experiment.run = driver.run_experiment;

    % Verification helpers
    ctx.verify.equals = driver.verify_equals;
    ctx.verify.within_bounds = driver.verify_within_bounds;
    ctx.verify.improves_over_time = driver.verify_improves_over_time;
    ctx.verify.is_valid_schedule = driver.verify_is_valid_schedule;
    ctx.verify.less_than = driver.verify_less_than;
    ctx.verify.has_field = driver.verify_has_field;
    ctx.verify.has_size = driver.verify_has_size;
    ctx.verify.is_true = driver.verify_is_true;
end
