function problems = load_problems(filepath)
% LOAD_PROBLEMS Load flow shop problem instances from a JSON file
%
% Args:
%   filepath - Path to JSON file containing problem definitions
%
% Returns:
%   problems - Struct array with fields:
%              .P  - Processing times matrix (machines x jobs)
%              .lb - Lower bound (optimal or best known)
%              .ub - Upper bound

    if ~exist(filepath, 'file')
        error('load_problems:fileNotFound', 'Problem file not found: %s', filepath);
    end

    text = fileread(filepath);
    data = jsondecode(text);

    if ~isfield(data, 'problems')
        error('load_problems:invalidFormat', 'JSON must contain a "problems" field');
    end

    n = length(data.problems);
    for i = 1:n
        p = data.problems(i);

        if iscell(p.processing_times)
            P = cell2mat(p.processing_times);
        else
            P = p.processing_times;
        end

        [M, N] = size(P);
        if M ~= p.machines || N ~= p.jobs
            error('load_problems:dimensionMismatch', ...
                'Problem %d: expected %dx%d, got %dx%d', ...
                i, p.machines, p.jobs, M, N);
        end

        problems(i).P  = P;
        problems(i).lb = p.lower_bound;
        problems(i).ub = p.upper_bound;
    end
end
