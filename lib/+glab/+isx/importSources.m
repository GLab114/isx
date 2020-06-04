function [srcLocs, srcTraces] = importSources(inputFilePaths, varargin)
%IMPORTSOURCES Import sources to memory from Inscopix datafiles.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [srcLocs::double(ns, nx, ny), srcTraces::double(ns, nt)] = ...
%       glab.isx.importSources(inputFilePaths::cell(string))
%   Import data into memory from Inscopix cell sets specified by
%   `inputFilePaths`, a cell array of file paths. `srcLocs` will be an
%   array containing the localizations of those sources; it is indexed in
%   the first dimension by source; it is indexed in the second dimension by
%   pixel "x" value; it is indexed in the third dimension by pixel "y"
%   value. `srcTraces` will be an array containing the traces of those
%   sources; it is indexed in the first dimension by source; it is indexed
%   in the second dimension by frame.
%
%   _ = glab.isx.importSources(_, 'useParallel', b::bool)
%   Use a naive form of parallelization to accelerate reading from file.
%   Defaults to `true`.
%
%   Examples:
%   >> ifps = {'mov1-PCAICA.isxd', 'mov2-PCAICA.isxd'};
%   >> [nPixels2, nFrames, nSrcs] = cellfun( ...
%        @glab.isx.cellSetMetadata, ...
%        ifps, ...
%        'UniformOutput', false ...
%      );
%   >> nPixels2{1}
%
%   ans =
%
%       300     400
%
%   >> sum(cell2mat(nFrames))
%
%   ans = 
%
%       1000
%
%   >> nSrcs{1}
%
%   ans =
%
%       75
%
%   >> [srcLocs, srcTraces] = glab.isx.importSources(ifps);
%   >> size(srcLocs)
%
%   ans =
%   
%       75     300     400
%
%   >> size(srcTraces)
%
%   ans =
%
%       75     1000

%%
defaultUseParallel = true;

p = inputParser();
addParameter(p, 'useParallel', defaultUseParallel, ...
    @(x)islogical(x) && isscalar(x));
parse(p, varargin{:});

useParallel = p.Results.useParallel;

%%
nFiles = length(inputFilePaths);

[nPixels2, nFrames, nSrcs] = cellfun( ...
    @glab.isx.cellSetMetadata, ...
    inputFilePaths, ...
    'UniformOutput', false ...
);

% Ugh matlab cell arrays suck
consistentNPixels2 = all(cell2mat(cellfun( ...
    @(x)all(x == nPixels2{1}), nPixels2, ...
    'UniformOutput', false ...
)));
consistentNSrcs = all(cell2mat(cellfun( ...
    @(x)x == nSrcs{1}, nSrcs, ...
    'UniformOutput', false ...
)));
if ~consistentNPixels2 || ~consistentNSrcs
    error('GLaB:InputError', 'Cellset files are not consistent');
end
nPixels2 = nPixels2{1};
nSrcs = nSrcs{1};

refCellSet = isx.CellSet.read(inputFilePaths{1});
globalFrameIdcs = cell(nFiles, 1);
for i = 1:nFiles
    if i == 1
        accum = 0;
    else
        lastIdcs = globalFrameIdcs{i - 1};
        accum = lastIdcs(end);
    end
    globalFrameIdcs{i} = (1:nFrames{i}) + accum;
end
nTotalFrames = sum(cell2mat(nFrames));

srcNames = cell(nSrcs, 1);
srcLocs = zeros([nPixels2 nSrcs]);
srcTraces = zeros([nTotalFrames nSrcs]);

%%
for i = 1:nSrcs
    % 0-based indexing, per Inscopix API
    srcNames{i} = refCellSet.get_cell_name(i - 1);
    srcLocs(:, :, i) = refCellSet.get_cell_image_data(i - 1);
end

for i = 1:nFiles
    if useParallel
        % Async submit
        future(i) = parfeval(@loadTrace, 1, inputFilePaths{i}, nSrcs); %#ok<AGROW>
    else
        srcTraces(globalFrameIdcs{i}, :) = ...
            loadTrace(inputFilePaths{i}, nSrcs);
    end
end

if useParallel
    % ASync fetch
    for i = 1:nFiles
        [j, result] = fetchNext(future);
        srcTraces(globalFrameIdcs{j}, :) = result;
    end
end

end


function srcTraces = loadTrace(inputFilePath, nSrcs)
c = isx.CellSet.read(inputFilePath);
nFrames = c.timing.num_samples;

srcTraces = zeros(nFrames, nSrcs);
for i = 1:nSrcs
    srcTraces(:, i) = c.get_cell_trace_data(i - 1);
end
end