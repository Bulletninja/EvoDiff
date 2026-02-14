function helpers = verify_helpers()
% VERIFY_HELPERS Shared verification functions for acceptance test drivers
%
% Returns a struct of function handles used by both function and script drivers.

    helpers.verify_equals = @verify_equals_impl;
    helpers.verify_within_bounds = @verify_within_bounds_impl;
    helpers.verify_improves_over_time = @verify_improves_over_time_impl;
    helpers.verify_is_valid_schedule = @verify_is_valid_schedule_impl;
    helpers.verify_less_than = @verify_less_than_impl;
    helpers.verify_has_field = @verify_has_field_impl;
    helpers.verify_has_size = @verify_has_size_impl;
    helpers.verify_is_true = @verify_is_true_impl;
end

function verify_equals_impl(actual, expected)
    assert(isequal(actual, expected), ...
        sprintf('Expected %s, got %s', mat2str(expected), mat2str(actual)));
end

function verify_within_bounds_impl(value, lo, hi)
    assert(value >= lo && value <= hi, ...
        sprintf('Value %g not in [%g, %g]', value, lo, hi));
end

function verify_improves_over_time_impl(values)
    if length(values) > 1
        diffs = diff(values);
        assert(all(diffs <= 0), ...
            sprintf('Values should be monotonically non-increasing, max increase: %g', max(diffs)));
    end
end

function verify_is_valid_schedule_impl(schedule, problem)
    [M, N] = size(problem.P);
    assert(isequal(size(schedule), [M, N]), ...
        sprintf('Schedule should be %dx%d, got %dx%d', M, N, size(schedule, 1), size(schedule, 2)));
    orig_sorted = sortrows(problem.P')';
    sched_sorted = sortrows(schedule')';
    assert(isequal(orig_sorted, sched_sorted), ...
        'Schedule columns should be a permutation of the original jobs');
end

function verify_less_than_impl(a, b)
    assert(a < b, sprintf('Expected %g < %g', a, b));
end

function verify_has_field_impl(s, field_name)
    assert(isfield(s, field_name), ...
        sprintf('Struct missing field: %s', field_name));
end

function verify_has_size_impl(x, expected_size)
    assert(isequal(size(x), expected_size), ...
        sprintf('Expected size [%s], got [%s]', ...
        num2str(expected_size), num2str(size(x))));
end

function verify_is_true_impl(condition)
    assert(condition, 'Expected condition to be true');
end
