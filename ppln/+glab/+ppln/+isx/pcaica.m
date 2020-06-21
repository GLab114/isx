function [outPath, itmdPath] = pcaica(dffOutPath, varargin)
%PCAICA A pre-made PCA/ICA pipeline wrapping the Inscopix Data Processing Software.
% v0.5.0 | N Gelwan | 2020-05
%
%   Usage:
%   [outPath::string, itmdPath::string] = ...
%       glab.ppln.isx.pcaica(dffOutPath::string)
%   Run a pre-made pipeline which processes a DF/F time-series found in
%   in `dffOutPath` into an array-formatted collection of sources.
%
%   _ = glab.ppln.isx.pcaica(_, 'nICs', x::int)
%   Specify the number of independent components to expect from the movie
%   manually. Otherwise, an automatic estimation scheme is used.
%
%   _ = glab.ppln.isx.pcaica(_, 'outPath', x::string)
%   Specify the directory containing output sources.
%   Defaults to `fullfile(dffOutPath, '../../pcaica/out')`.
%
%   _ = glab.ppln.isx.pcaica(_, 'itmdPath', x::string)
%   Specify the directory where intermediate products of the pipeline will
%   be stored. Defaults to `fullfile(dffOutPath, '../../pcaica/itmd')`.
%
%   _ = glab.ppln.isx.pcaica(_, 'useCached', x::bool)
%   Whether or not to use the results of intermediate files from a previous
%   computation where possible. Note that `itmdPath' must be consistent
%   between attempts in order for this to work. Also note that this system
%   is not atomic; if outputs have been produced but are incomplete, and
%   this is set to true, the system will attempt to use those incomplete
%   files. You must delete these bad actors manually, or turn this off.
%   Defaults to `true`.
%
%   _ = glab.ppln.isx.pcaica(_, 'useParallel', x::bool)
%   Use naive parallelization where possible. This may require a parallel
%   computing environment to have been started. See glab.parenv for
%   options. Defaults to `true`.
%
%   Examples:
%   >> dffOutPath = '~/data/dff/out';
%   >> glab.util.regex.dir(isxPath, 'isxd$')
%
%   ans =
%
%     2x1 cell array
%
%       {'~/data/dff/out/rec1-DFF.isxd'}
%       {'~/data/dff/out/rec2-DFF.isxd'}
%
%   >> [outPath, itmdPath] = glab.ppln.isx.pcaica(dffOutPath);
%   >> outPath
%
%   ans =
%
%       '~/data/pcaica/out'
%
%   >> glab.util.regex.dir(outPath, '*')
%
%   ans =
%
%     1x1 cell array
%
%       {'~/data/pcaica/out/sources.mat'}
%
%   >> itmdPath
%
%   ans =
%
%       '~/data/pcaica/itmd'
%
%   >> glab.util.regex.dir(itmdPath, '*')
%
%   ans =
%
%     13x1 cell array
%
%       {'~/data/pcaica/itmd/srcLocs.isxd'            }
%       {'~/data/pcaica/itmd/sortStatus.mat'          }
%       {'~/data/pcaica/itmd/rec1-DFF-TDS-PCAICA.isxd'}
%       {'~/data/pcaica/itmd/rec1-DFF-TDS.isxd'       }
%       {'~/data/pcaica/itmd/rec1-DFF-SRCS.isxd'      }
%       {'~/data/pcaica/itmd/rec1-DFF-NPL.isxd'       }
%       {'~/data/pcaica/itmd/rec2-DFF-TDS-PCAICA.isxd'}
%       {'~/data/pcaica/itmd/rec2-DFF-TDS.isxd'       }
%       {'~/data/pcaica/itmd/rec2-DFF-SRCS.isxd'      }
%       {'~/data/pcaica/itmd/rec2-DFF-NPL.isxd'       }
%       {'~/data/pcaica/itmd/nplLoc.isxd'             }
%       {'~/data/pcaica/itmd/minProj.isxd'            }
%       {'~/data/pcaica/itmd/maxProj.isxd'            }
%
%   >> isxPath = '~/data/dcmp';
%   >> pcaicaOutPath = glab.ppln.isx.pcaica(glab.ppln.isx.dff(isxPath));

%% Input parsing
defaultNICs = [];
defaultOutPath = [];
defaultItmdPath = [];
defaultUseCached = true;
defaultUseParallel = true;
defaultLogger = glab.util.defaultLogger();

p = inputParser();
addParameter(p, 'nICs', defaultNICs ...
    );
addParameter(p, 'outPath', defaultOutPath ...
    );
addParameter(p, 'itmdPath', defaultItmdPath ...
    );
addParameter(p, 'useCached', defaultUseCached, ...
    @(x)isscalar(x) && islogical(x));
addParameter(p, 'useParallel', defaultUseParallel, ...
    @(x)isscalar(x) && islogical(x));
addParameter(p, 'logger', defaultLogger ...
    );
parse(p, varargin{:});

nICs = p.Results.nICs;
outPath = p.Results.outPath;
itmdPath = p.Results.itmdPath;
useCached = p.Results.useCached;
useParallel = p.Results.useParallel;
l = p.Results.logger;

%%
% Set up the ouput paths
if isempty(outPath)
    upDir = fileparts(fileparts(dffOutPath));
    pcaicaPath = fullfile(upDir, 'pcaica');

    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    mkdir(pcaicaPath);
    warning('on', 'MATLAB:MKDIR:DirectoryExists');

    outPath = fullfile(pcaicaPath, 'out');
end
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(outPath);
warning('on', 'MATLAB:MKDIR:DirectoryExists');

if isempty(itmdPath)
    upDir = fileparts(fileparts(dffOutPath));
    pcaicaPath = fullfile(upDir, 'pcaica');

    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    mkdir(pcaicaPath);
    warning('on', 'MATLAB:MKDIR:DirectoryExists');

    itmdPath = fullfile(pcaicaPath, 'itmd');
end
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(itmdPath);
warning('on', 'MATLAB:MKDIR:DirectoryExists');

% Turn on/off cache validation 
if useCached
    chkCached = @(x)glab.util.filePathsPresent(x);
else
    chkCached = @(x)false;
end

%%
dffFilePaths = glab.util.regex.dir(dffOutPath, 'DFF.isxd$');

% tds
tdsFilePaths = glab.util.txFilePaths( ...
    dffFilePaths, ...
    'pathTx', @(path)itmdPath, ...
    'nameTx', @(name)[name '-TDS'] ...
);

tdsComp = glab.proc.CachedComp( ...
    @glab.isx.temporalDownsample, 0, ...
    @()chkCached(tdsFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% maxProj
maxProjFilePath = fullfile(itmdPath, 'maxProj.isxd');

maxProjComp = glab.proc.CachedComp( ...
    @glab.isx.projectMax, 0, ...
    @()chkCached({maxProjFilePath}), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% minProj
minProjFilePath = fullfile(itmdPath, 'minProj.isxd');

minProjComp = glab.proc.CachedComp( ...
    @glab.isx.projectMin, 0, ...
    @()chkCached({minProjFilePath}), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% pcaica
pcaicaFilePaths = glab.util.txFilePaths( ...
    tdsFilePaths, ...
    'nameTx', @(name)[name '-PCAICA'] ...
);

pcaicaComp = glab.proc.CachedComp( ...
    @glab.isx.pcaica, 0, ...
    @()chkCached(pcaicaFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% sort
asvFilePath = fullfile(itmdPath, 'sortAsv.mat');
srcLocsFilePath = fullfile(itmdPath, 'srcLocs.isxd');
nplLocFilePath = fullfile(itmdPath, 'nplLoc.isxd');

sortComp = glab.proc.CachedComp( ...
    @glab.ppln.isx.pcaica.sort, 0, ...
    @()chkCached({srcLocsFilePath, nplLocFilePath}), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% xrctSrcs
srcTracesFilePaths = glab.util.txFilePaths( ...
    dffFilePaths, ...
    'pathTx', @(path)itmdPath, ...
    'nameTx', @(name)[name '-SRCS'] ...
);

xrctSrcTracesComp = glab.proc.CachedComp( ...
    @glab.isx.applyCellSetLocs, 0, ...
    @()chkCached(srcTracesFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% xrctNplTrace
nplTraceFilePaths = glab.util.txFilePaths( ...
    dffFilePaths, ...
    'pathTx', @(path)itmdPath, ...
    'nameTx', @(name)[name '-NPL'] ...
);

xrctNplTraceComp = glab.proc.CachedComp( ...
    @glab.isx.applyCellSetLocs, 0, ...
    @()chkCached(nplTraceFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

%%
l.debug(['useCached = ' num2str(useCached)]);
l.debug(['dffOutPath = ' dffOutPath]);
l.debug(['outPath = ' outPath]);
l.debug(['itmdPath = ' itmdPath]);
l.debug(['useParallel = ' num2str(useParallel)]);

l.infoSrE('Temporally downsampling');
glab.proc.runComp( ...
    tdsComp, 0, ...
    dffFilePaths, tdsFilePaths, 5, ...
    'useParallel', useParallel ...
);
l.srX();

l.infoSrE('Taking max projection');
glab.proc.runComp( ...
    maxProjComp, 0, ...
    tdsFilePaths, maxProjFilePath ...
);
maxProjRef = isx.Image.read(maxProjFilePath);
maxProj = maxProjRef.get_data();
l.srX();

l.infoSrE('Taking min projection');
glab.proc.runComp( ...
    minProjComp, 0, ...
    tdsFilePaths, minProjFilePath ...
);
minProjRef = isx.Image.read(minProjFilePath);
minProj = minProjRef.get_data();
l.srX();

% This is the "range projection"
ref = maxProj - minProj;

if isempty(nICs)
    l.infoSrE('Estimating number of ICs');
    nICs = glab.ca.estimateNICs(ref);
    l.debug(['Estimated ' num2str(nICs) ' ICs']);
    l.srX();
end

l.infoSrE('Using PCA/ICA to produce source localizations');
glab.proc.runComp( ...
    pcaicaComp, 0, ...
    tdsFilePaths, pcaicaFilePaths, nICs ...
);
l.srX();

l.infoSrE('Sorting');
glab.proc.runComp( ...
    sortComp, 0, ...
    pcaicaFilePaths, srcLocsFilePath, nplLocFilePath, ref, ...
    'asvFilePath', asvFilePath, ...
    'useParallel', useParallel, ...
    'logger', l ...
);
l.srX();

l.infoSrE('Extracting source traces from DF/F');
glab.proc.runComp( ...
    xrctSrcTracesComp, 0, ...
    dffFilePaths, srcLocsFilePath, srcTracesFilePaths ...
);
l.srX();

%%
l.infoSrE('Extracting neuropil trace');
glab.proc.runComp( ...
    xrctNplTraceComp, 0, ...
    dffFilePaths, nplLocFilePath, nplTraceFilePaths ...
);
l.srX();

%%
l.infoSrE('Loading extracted sources into memory');
[srcLocs, srcTrcs] = glab.isx.importSources(srcTracesFilePaths);
l.srX();

%%
l.infoSrE('Loading extracted neuropil into memory');
[nplLoc, nplTrc] = glab.isx.importSources(nplTraceFilePaths);
l.srX();

%%
l.infoSrE('Saving sources');
sourcesFilePath = fullfile(outPath, 'sources.mat');
save( ...
    sourcesFilePath, ...
    'srcLocs', ...
    'srcTrcs', ...
    'nplLoc', ...
    'nplTrc' ...
);
l.srX();

end
