function [] = ...
    sort(pcaicaFilePaths, srcFilePath, nplFilePath, ref, varargin)
%SORT Summary of this function goes here
%   Detailed explanation goes here

%%
defaultAsvFilePath = [];
defaultUseParallel = false;
defaultLogger = glab.util.defaultLogger();

p = inputParser();
addParameter(p, 'asvFilePath', defaultAsvFilePath ...
    );
addParameter(p, 'useParallel', defaultUseParallel ...
    );
addParameter(p, 'logger', defaultLogger ...
    );
parse(p, varargin{:});

asvFilePath = p.Results.asvFilePath;
l = p.Results.logger;

%%
l.infoSrE('Loading sources into memory');
[icLocs, icTraces] = glab.isx.importSources( ...
    pcaicaFilePaths, ...
    'useParallel', false ...
);
l.srX();

l.infoSrE('Thresholding source localizations');
locMinZ = 5;
icLocs = glab.ca.preprocessSrcLocs.thresh(icLocs, locMinZ);
l.srX();

l.infoSrE('Pruning source localizations');
% Any component of a source localization which represent less than 
% `locMinCompWeight` of the total pixel-value which contributes to the
% source will be dropped. In particular, if the source is so non-localized
% that *no* component contributes more than `locMinCompWeight` to the total
% pixel-value, then *the entire source* will be discarded.
locMinCompWeight = 0.50;
icLocs = glab.ca.preprocessSrcLocs.prune(icLocs, locMinCompWeight);
l.srX();

l.infoSrE('Discarding insignificant sources');
noSrcMask = all(icLocs == 0, [1 2]);
icLocs(:, :, noSrcMask) = [];
icTraces(:, noSrcMask) = [];
l.debug(['Removed ' num2str(sum(noSrcMask)) ' sources; '...
    num2str(size(icLocs, 3)) ' remain']);
l.srX();

l.infoSrE('Calculating neuropil localization');
nplLoc = glab.ca.locReducedComplement(5, icLocs);
l.srX();

l.infoSrE('Doing some automatic preliminary sorting');
status = glab.ca.sort.autoSort(icLocs, icTraces, 'logger', l);
l.srX();

l.infoSrE('Providing sorting UI');

% Gaps, for marking on the sort ui
nFiles = length(pcaicaFilePaths);
[~, nFrames] = cellfun( ...
    @glab.isx.cellSetMetadata, ...
    pcaicaFilePaths, ...
    'UniformOutput', false ...
);
gapStarts = [nFrames{1}; zeros(nFiles - 1, 1)];
for i = 2:nFiles
    gapStarts(i) = gapStarts(i - 1) + nFrames{i};
end
gapStarts(1) = [];

status = glab.ca.sortUI( ...
    ref, icLocs, icTraces, ...
    'status', status, ...
    'asvFilePath', asvFilePath, ...
    'trcMarks', gapStarts ...
);
statusMask = status ~= glab.ca.sort.status.REJECTED;
srcLocs = icLocs(:, :, statusMask);

l.srX();

l.infoSrE('Exporting sources to Inscopix cellset');
glab.isx.exportSourceLocs(srcFilePath, srcLocs);
l.srX();

l.infoSrE('Exporting neuropil to Inscopix cellset');
glab.isx.exportSourceLocs(nplFilePath, nplLoc);
l.srX();

end

