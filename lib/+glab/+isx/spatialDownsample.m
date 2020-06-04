function [] = ...
    spatialDownsample(inputFilePaths, outputFilePaths, dsFactor, varargin)
%SPATIALDOWNSAMPLE A thin wrapper around the Inscopix MATLAB API's downsampling calls.
% v0.1.0 | nGelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.spatialDownsample( ...
%       inputFilePaths::cell(string), ...
%       outFilePaths::cell(string), ...
%       dsFactor::int ...
%   )
%   Provides naive parallelization of Inscopix's API. `inputFilePaths`
%   should be a cell of paths to .isxd files to operate on. 
%   `outputFilePaths` should be a cell of paths to .isxd files to 
%   output. Downsample both spatial dimensions by a factor of `dsFactor`.
%
%   _ = glab.isx.spatialDownsample(_, 'useParallel', x::bool)
%   Disable the parallelization. Defaults to `true`.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofps = {'~/mov1-TDS.isxd', '~/mov2-SDS.isxd'};
%   >> nPixels2 = glab.isx.movieMetadata(ifps{1});
%   >> nPixels2
%
%   ans =
%       
%       300     400
%
%   >> [] = glab.isx.spatialDownsample(ifps, ofps, 2);
%   >> nPixles2 = glab.isx.movieMetadata(ofps{1});
%   >> nPixels2
%
%     ans =
%
%       150     200

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
    parfor i = 1:nFiles
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

