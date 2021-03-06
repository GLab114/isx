function [recs, fps] = overview(path)
%OVERVIEW Provide an overview of a base Inscopix time series.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [recs::table, fps::double] = glab.isx.overview(path::string)
%   Create an overview of the base Inscopix time series located in the
%   directory specified by `path`. Produces a table `recs` and a double
%   `fps` which specifies the framerate common to series.
%
%   Errors:
%   - InputError: when the base series in `path` contains different
%   framerates
%
%   Examples:
%   >> path = '~/data';
%   >> glab.util.regex.dir(path, 'isxd$');
%
%   ans =
% 
%     4�1 cell array
% 
%       {'~/data/mov1.isxd'      }
%       {'~/data/mov2.isxd'      }
%       {'~/data/mov1-PROCD.isxd'}
%       {'~/data/mov2-PROCD.isxd'}
%
%   >> [recs, fps] = glab.isx.overview(path);
%   >> recs
%
%   ans =
% 
%     9�10 table
% 
%        name       idxStart     idxLength    idxStop         timeStart          timeLength          timeStop          tsStart    tsStop    dropped
%       ______    __________    _________    _______    ____________________    __________    ____________________    _______    ______    _______
% 
%       'mov1'             1      12080        12080    30-Nov-2017 10:06:49     00:10:04     30-Nov-2017 10:16:53      NaN       NaN        []   
%       'mov2'         12081      12033        24113    30-Nov-2017 10:20:24     00:10:01     30-Nov-2017 10:30:25      NaN       NaN        []   

%% 
recPaths = glab.isx.util.baseSeriesInDir(path);
nFiles = length(recPaths);

recs = table(...
    cell(nFiles, 1), ...
    zeros(nFiles, 1), ...
    zeros(nFiles, 1), ...
    zeros(nFiles, 1), ...
    NaT(nFiles, 1), ...
    duration(NaN(nFiles, 3)), ...
    NaT(nFiles, 1), ...
    zeros(nFiles, 1), ...
    zeros(nFiles, 1), ...
    cell(nFiles, 1), ...
    'VariableNames', { ...
        'name' ...
        'idxStart' ...
        'idxLength' ...
        'idxStop' ...
        'timeStart' ...
        'timeLength' ...
        'timeStop' ...
        'tsStart' ...
        'tsStop' ...
        'dropped' ...
    } ...
);

framerates = zeros(nFiles, 1);

for i = 1:nFiles
    [row, framerate] = toRow(recPaths{i});
    recs(i, :) = row;
    framerates(i) = framerate;
end

fps = unique(framerates);
if length(fps) ~= 1
    error('InputError', 'Recordings have differing framerates');
end

accum = 0;
for i = 1:nFiles
    recs.idxStart(i) = accum + 1;
    accum = accum + recs.idxLength(i);
    recs.idxStop(i) = accum;
end

end

function [row, fps] = toRow(filePath)
    [~, nFrames, ~, fps] = glab.isx.fileMetadata(filePath);
    mov = isx.Movie.read(filePath);
    
    name = glab.isx.util.recName(filePath);
    idxStart = NaN;
    idxLength = nFrames;
    idxStop = NaN;
    timeStart = mov.timing.start.datetime;
    timeLength = duration(...
        0, ...
        0, ...
        nFrames * mov.timing.period.secs_float ...
    );
    timeStop = timeStart + timeLength;
    tsStart = NaN;
    tsStop = NaN;
    dropped = {mov.timing.dropped};
    
    row = {...
        name ...
        idxStart ...
        idxLength ...
        idxStop ...
        timeStart ...
        timeLength ...
        timeStop ...
        tsStart ...
        tsStop ...
        dropped ...
    };
end

