function FS = load_taillard_problems()
% LOAD_TAILLARD_PROBLEMS Load Taillard 20x5 Flowshop benchmark problems
%
% Convenience wrapper around load_problems() for the standard benchmarks.
%
% Returns:
%   FS - Struct array with 10 problems, each containing:
%        .P  - Processing times matrix (5 machines x 20 jobs)
%        .lb - Lower bound (optimal or best known)
%        .ub - Upper bound

    json_path = find_data_file('taillard_20x5.json');

    if ~isempty(json_path)
        FS = load_problems(json_path);
    else
        error('load_taillard_problems:dataNotFound', ...
            'Could not find taillard_20x5.json. Run setup_paths() first.');
    end
end


function filepath = find_data_file(filename)
    candidates = {
        fullfile('data', filename),
        fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', filename),
        filename
    };
    filepath = '';
    for i = 1:length(candidates)
        if exist(candidates{i}, 'file')
            filepath = candidates{i};
            return;
        end
    end
end
