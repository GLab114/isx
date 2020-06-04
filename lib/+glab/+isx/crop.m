function [] = crop(inputFilePaths, outputFilePaths, rect, varargin)
% CROP A thin wrapper around the Inscopix MATLAB API's cropping calls.
% v0.2.0 | nGelwan | 2019
%
%   Usage:
%   [] = glab.isx.crop(inputFilePaths, outFilePaths, rect)
%   Provides naive parallelization of Inscopix's API. `inputFilePaths`
%   should be a cell of paths to .isxd files to operate on. 
%   `outputFilePaths` should be a cell of paths to .isxd files to output.
%   `rect` should provide the location of the corners of the cropping
%   rectangle arranged like [top left bottom right]. 
%
%   _ = glab.isx.crop(_, 'useParallel', x::bool)
%   Provide naive parallelization of the routine across files. Defaults to 
%   `true`.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofps = {'~/mov1-CROP.isxd', '~/mov2-CROP.isxd'};
%   >> nPixels2 = glab.isx.movieMetadata(ifps{1});
%   >> nPixels2
%
%   ans =
%
%       300     400
%
%   >> rect = [50 50 100 150];
%   >> glab.isx.crop(ifps, ofps, rect);
%   >> nPixels2 = glab.isx.movieMetadata(ofps{1});
%   >> nPixels2
%
%   ans =
%
%       150     200

%% Input parsing
defaultUseParallel = true;

p = inputParser();
addParameter(p, 'useParallel', defaultUseParallel, ...
    @(x)isscalar(x) && islogical(x));
parse(p, varargin{:});

useParallel = p.Results.useParallel;

%%
nFiles = length(inputFilePaths);

%%
warning('off', 'MATLAB:DELETE:FileNotFound');
for i = 1:nFiles
    delete(outputFilePaths{i});
end
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
if useParallel
    for i = 1:nFiles
        % Async submit
        % 0-based indexing, per Inscopix API
        fResults(i) = parfeval(...
            @isx.preprocess, 0, ...
            inputFilePaths(i), ...
            outputFilePaths(i), ...
            'crop_rect', rect - 1 ...
        ); %#ok<AGROW>
    end
else
    % 0-based indexing, per Inscopix API
    isx.preprocess(...
        inputFilePaths, ...
        outputFilePaths, ...
        'crop_rect', rect - 1 ...
    );
end
if useParallel
    % Async wait
    for i = 1:nFiles
        fetchNext(fResults);
    end
end

