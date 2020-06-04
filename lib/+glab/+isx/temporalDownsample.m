function [] = ...
    temporalDownsample(inputFilePaths, outputFilePaths, dsFactor, varargin)
%TEMPORALDOWNSAMPLE A thin wrapper around the Inscopix MATLAB API's downsampling calls.
% v0.1.0 | nGelwan | 2020-05
%   Usage:
%   [] = glab.isx.temporalDownsample( ...
%       inputFilePaths::cell(string), ...
%       outFilePaths::cell(string), ...
%       dsFactor::int ...
%   )
%   Provides naive parallelization of Inscopix's API. `inputFilePaths`
%   should be a cell of paths to .isxd files to operate on. 
%   `outputFilePaths` should be a cell of paths to .isxd files to 
%   output. Downsample time by a factor of `dsFactor`.
%
%   _ = glab.isx.temporalDownsample(_, 'useParallel', x::bool)
%   Disable the parallelization. Defaults to `true`.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofps = {'~/mov1-TDS.isxd', '~/mov2-TDS.isxd'};
%   >> [~, nFrames] = glab.isx.movieMetadata(ifps{1});
%   >> nFrames
%
%     ans =
%       
%       1000
%
%   >> [] = glab.isx.temporalDownsample(ifps, ofps, 5);
%   >> [~, nFrames] = glab.isx.movieMetadata(ofps{1});
%   >> nFrames
%
%     ans =
%
%       200

%%
defaultUseParallel = true;

p = inputParser();
addParameter(p, 'useParallel', defaultUseParallel,...
    @(x)isscalar(x) && islogical(x));
parse(p, varargin{:});

useParallel = p.Results.useParallel;

%%
nFiles = length(inputFilePaths);

warning('off', 'MATLAB:DELETE:FileNotFound');
for i = 1:nFiles
    delete(outputFilePaths{i});
end
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
% REVIEW: Does it matter that we're calling temporal downsample on each of
% these independently? I think not, but the point was raised.
if useParallel
    parfor i = 1:length(inputFilePaths)
        isx.preprocess( ...
            inputFilePaths{i}, outputFilePaths{i}, ...
            'temporal_downsample_factor', dsFactor ...
        );
    end
else
    isx.preprocess( ...
        inputFilePaths, outputFilePaths, ...
        'temporal_downsample_factor', dsFactor ...
    );
end

end

