function [] = dff(inputFilePaths, outputFilePaths, varargin)
%DFF A thin wrapper around the Inscopix MATLAB API's DF/F routines.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.dff( ...
%       inputFilePaths::cell(string), ...
%       outputFilePaths::cell(string) ...
%   );
%   Calculate the DF/F on the series specified by `inputFilePaths` using
%   mean projections as a reference.
%
%   _ = glab.isx.dff(_, 'perRecording', x::bool)
%   If true, calculate the reference for each recording indepedently. This
%   can lead to different scales for each recording, and thus is not
%   recommended. Note that false will disable the parallel wrapping,
%   regardless of what the 'useParallel' kwarg is set to. Defaults to 
%   false.
%
%   _ = glab.isx.dff(_, 'useParallel', x::bool)
%   If false, will disable parallel wrapping. Defaults to true.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofps = {'~/mov1-DFF.isxd', '~/mov2-DFF.isxd'};
%   >> [] = glab.isx.dff(ifps, ofps);

%%
defaultPerRecording = false;
defaultUseParallel = true;

p = inputParser();
addParameter(p, 'useParallel', defaultUseParallel, ...
    @(x)isscalar(x) && islogical(x));
addParameter(p, 'perRecording', defaultPerRecording, ...
    @(x)isscalar(x) && islogical(x));
parse(p, varargin{:});

useParallel = p.Results.useParallel;
perRecording = p.Results.perRecording;

%%
nFiles = length(inputFilePaths);

%%
warning('off', 'MATLAB:DELETE:FileNotFound');
for i = 1:nFiles
    delete(outputFilePaths{i});
end
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
futures = parallel.FevalFuture;
if perRecording
    if useParallel
        for i = 1:nFiles
            % Async submit
            futures(i) = parfeval(...
                @isx.dff, 0, ...
                inputFilePaths{i}, ...
                outputFilePaths{i}, ...
                'f0_type', 'mean' ...
            );
        end
        for i = 1:nFiles
            % Async wait
            fetchNext(futures);
        end
    else
        for i = 1:nFiles
            isx.dff(...
                inputFilePaths{i}, ...
                outputFilePaths{i}, ...
                'f0_type', 'mean' ...
            );
        end
    end
else
    isx.dff(inputFilePaths, outputFilePaths, 'f0_type', 'mean');
end

end