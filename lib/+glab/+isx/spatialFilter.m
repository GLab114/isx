function [] = spatialFilter(inputFilePaths, outputFilePaths, varargin)
%SPATIALFILTER A thin wrapper around the Inscopix MATLAB API's spatial bandpass filtering calls.
% v0.1.0 | nGelwan | 2020-05
%   Usage:
%   [] = glab.isx.spatialFilter( ...
%       inputFilePaths::cell(string), ...
%       outFilePaths::cell(string), ...
%   )
%   `inputFilePaths` should be a cell of paths to .isxd files to operate 
%   on. `outputFilePaths` should be a cell of paths to .isxd files to 
%   output.
%
%   _ = glab.isx.spatialFilter(_, 'lowCutoff', x::float)
%   The low spatial frequency cutoff, in units of pixels^(-1). Defaults to
%   `0.005`.
%
%   _ = glab.isx.spatialFilter(_, 'highCutOff', x::float)
%   The high spatial frequency cutoff, in units of pixels^(-1). Defaults to
%   `0.500`.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofps = {'~/mov1-BP.isxd', '~/mov2-BP.isxd'};
%   >> [] = glab.isx.spatialFilter(ifps, ofps);

%%
defaultLowCutoff = 0.005;
defaultHighCutoff = 0.500;

p = inputParser();
addParameter(p, 'lowCutoff', defaultLowCutoff ...
    );
addParameter(p, 'highCutoff', defaultHighCutoff ...
    );
parse(p, varargin{:});

lowCutoff = p.Results.lowCutoff;
highCutoff = p.Results.highCutoff;

%%
nFiles = length(inputFilePaths);

%%
warning('off', 'MATLAB:DELETE:FileNotFound');
for i = 1:nFiles
    delete(outputFilePaths{i});
end
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
isx.spatial_filter( ...
    inputFilePaths, outputFilePaths,...
    'low_cutoff', lowCutoff,...
    'high_cutoff', highCutoff ...
);

end

