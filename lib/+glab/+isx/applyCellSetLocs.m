function [] = applyCellSetLocs(inputMovieFilePaths, inputCellSetFilePath, ...
    outputCellSetFilePaths)
%APPLYCELLSETLOCS Extract traces from a movie using the localizations of soures from an Inscopix cell set.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.applyCellSetLocs( ...
%       inputMovieFilePaths::cell(string), ...
%       inputCellSetFilePath::string, ...
%       outputCellSetFilePaths::cell(string) ...
%   );
%   Extract traces from a movie whose series is specified by
%   `inputMovieFilePaths`, a cell array of file paths. Specify the 
%   localizations to extract with a single cell set, specified by the 
%   file path string `inputCellSetFilePath`. Save the resulting traces
%   and the original localizations in the cell set specified by the cell 
%   array of file paths `outputCellSetFilePaths`.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> csfp = '~/mov1-PROCD-PCAICA.isxd';
%   >> ofps = {'~/mov1-XRCTD.isxd', '~/mov2-XRCTD.isxd'};
%   >> [~, nFrames] = cellfun( ...
%          @glab.isx.movieMetadata, ...
%          ifps, ...
%          'UniformOutput', false ...
%      );
%   >> cell2mat(nFrames)
%
%   ans =
%
%       1000     2000
%
%   >> [~, ~, nSrcs] = glab.isx.cellSetMetadata(csfp);
%   >> nSrcs
%
%   ans =
%
%       75
%
%   >> [] = glab.isx.applyCellSetLocs(ifps, csfp, ofps);
%   >> [~, nFrames, nSrcs] = cellfun( ...
%         @glab.isx.cellSetMetadata, ...
%         ofps, ...
%         'UniformOutput', false ...
%      );
%   >> cell2mat(nFrames)
%
%   ans =
%
%       1000     2000
%
%   >> cell2mat(nSrcs)
%
%   ans =
%
%       75     75


%%
warning('off', 'MATLAB:DELETE:FileNotFound');
for i = 1:length(outputCellSetFilePaths)
    delete(outputCellSetFilePaths{i});
end
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
threshold = 0;
isx.apply_cell_set( ...
    inputMovieFilePaths, ...
    inputCellSetFilePath, ...
    outputCellSetFilePaths, ...
    threshold ...
);

end

