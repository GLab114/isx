function [outPath, itmdPath] = dff(isxPath, varargin)
%DFF A pre-made DF/F pipeline wrapping the Inscopix Data Processing Software.
% v0.5.0 | N Gelwan | 2020-05
%
%   Usage:
%   [outPath::string, itmdPath::string] = ...
%       glab.ppln.isx.dff(isxPath::string)
%   Run a pre-made pipeline which processes the calcium movie series found
%   in `isxPath` into a DF/F time series. If the time-series is produced
%   with the nVista 2 hardware, i.e. is in the form of decompressed .hdf5
%   files and associated .xml header files, this needs to be indicated
%   using the `'isxVer'` keyword argument; see below.
%
%   _ = glab.ppln.isx.dff(_, 'outPath', x::string)
%   Specify the directory containing the DF/F time series manually.
%   Defaults to `fullfile(isxPath, '../dff/out')`.
%
%   _ = glab.ppln.isx.dff(_, 'itmdPath', x::string)
%   Specify the directory where intermediate products of the pipeline will
%   be stored. Defaults to `fullfile(isxPath, '../dff/itmd')`.
%
%   _ = glab.ppln.isx.dff(_, 'isxVer', x::string)
%   Specify the hardware version of the nVista system used to produce the
%   input movies. This is associated with the file-format of the movie. If
%   `'nVista2'` is specified, the input movies are expected to be .hdf5
%   files and their associated .xml header files. Note that without the
%   associated header files THIS WILL NOT WORK. Additionally, it is
%   expected that spatial downsampling by a factor of 2 WILL ALREADY HAVE 
%   BEEN PERFORMED DURING THE DECOMPRESSEION STEP. If `'nVista3'` is
%   specified, the input movies are expected to be .isxd files, and are
%   expected to have not bee downsampled or compressed.
%
%   _ = glab.ppln.isx.dff(_, 'useCached', x::bool)
%   Whether or not to use the results of intermediate files from a previous
%   computation where possible. Note that `itmdPath` must be consistent
%   between attempts in order for this to work. Also note that this system
%   is not atomic; if outputs have been produced but are incomplete, and
%   this is set to true, the system will attempt to use those incomplete
%   files. You must delete these bad actors manually, or turn this off.
%   Defaults to `true`.
%
%   _ = glab.ppln.isx.dff(_, 'useParallel', x::bool)
%   Use naive parallelization where possible. This may require a parallel
%   computing environment to have been started. See glab.parenv for
%   options. Defaults to `true`.
%
%   Examples:
%   >> isxPath = '~/data/dcmp';
%   >> glab.util.regex.dir(isxPath, 'isxd$')
%
%   ans =
%
%     2x1 cell array
%
%       {'~/data/dcmp/rec1.isxd'}
%       {'~/data/dcmp/rec2.isxd'}
%
%   >> isxVer = 'nVista3';
%   >> [outPath, itmdPath] = glab.ppln.isx.dff(isxPath, 'isxVer', isxVer);
%   >> outPath
%
%   ans =
%
%       '~/data/dff/out'
%
%   >> glab.util.regex.dir(outPath, '*')
%
%   ans =
%
%     2x1 cell array
%
%       {'~/data/dff/out/rec1-SDS-CROP-BP-MC-DFF.isxd'}
%       {'~/data/dff/out/rec2-SDS-CROP-BP-MC-DFF.isxd'}
%
%   >> itmdPath
%
%   ans =
%
%       '~/data/dff/itmd'
%
%   >> glab.util.regex.dir(itmdPath, '*')
%
%   ans =
%
%     12x1 cell array
%
%       {'~/data/dff/itmd/maxProj.isxd'                      }
%       {'~/data/dff/itmd/cromRect.mat'                      }
%       {'~/data/dff/itmd/rec1-SDS.isxd'                     }
%       {'~/data/dff/itmd/rec2-SDS.isxd'                     }
%       {'~/data/dff/itmd/rec1-SDS-CROP.isxd'                }
%       {'~/data/dff/itmd/rec2-SDS-CROP.isxd'                }
%       {'~/data/dff/itmd/rec1-SDS-CROP-BP.isxd'             }
%       {'~/data/dff/itmd/rec2-SDS-CROP-BP.isxd'             }
%       {'~/data/dff/itmd/rec1-SDS-CROP-BP-MC.isxd'          }
%       {'~/data/dff/itmd/rec2-SDS-CROP-BP-MC.isxd'          }
%       {'~/data/dff/itmd/rec1-SDS-CROP-BP-translations.isxd'}
%       {'~/data/dff/itmd/rec2-SDS-CROP-BP-translations.isxd'}

%% Input parsing
defaultOutPath = [];
defaultItmdPath = [];
expectedIsxVers = {'nVista2' 'nVista3'};
defaultIsxVer = 'nVista3';
defaultUseCached = true;
defaultUseParallel = true;
defaultLogger = glab.util.defaultLogger();

p = inputParser();
addParameter(p, 'outPath', defaultOutPath ...
    );
addParameter(p, 'itmdPath', defaultItmdPath ...
    );
addParameter(p, 'isxVer', defaultIsxVer,...
    @(x)any(validatestring(x, expectedIsxVers)));
addParameter(p, 'useCached', defaultUseCached, ...
    @(x)isscalar(x) && islogical(x));
addParameter(p, 'useParallel', defaultUseParallel, ...
    @(x)isscalar(x) && islogical(x));
addParameter(p, 'logger', defaultLogger ...
    );
parse(p, varargin{:});

outPath = p.Results.outPath;
itmdPath = p.Results.itmdPath;
isxVer = p.Results.isxVer;
useCached = p.Results.useCached;
useParallel = p.Results.useParallel;
l = p.Results.logger;

%%
% Set up the ouput paths
if isempty(outPath)
    upDir = fileparts(isxPath);
    dffPath = fullfile(upDir, 'dff');
    
    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    mkdir(dffPath);
    warning('on', 'MATLAB:MKDIR:DirectoryExists');

    outPath = fullfile(dffPath, 'out');
end
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(outPath);
warning('on', 'MATLAB:MKDIR:DirectoryExists');

if isempty(itmdPath)
    upDir = fileparts(isxPath);
    dffPath = fullfile(upDir, 'dff');
    
    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    mkdir(dffPath);
    warning('on', 'MATLAB:MKDIR:DirectoryExists');

    itmdPath = fullfile(dffPath, 'itmd');
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
% sds
if strcmp(isxVer, 'nVista3')
    isxFilePaths = glab.util.regex.dir(isxPath, 'isxd$');

    sdsFilePaths = glab.util.txFilePaths( ...
        isxFilePaths, ...
        'nameTx', @(name)[name '-SDS'] ...
    );
    
    sdsComp = glab.proc.CachedComp( ...
        @glab.isx.spatialDownsample, 0, ...
        @()chkCached(sdsFilePaths), ...
        @()[], ...
        @(x)[], ...
        'logger', l ...
    );

else
    isxFilePaths = glab.util.regex.dir(isxPath, 'xml$');
    sdsFilePaths = isxFilePaths;
    sdsComp = @(varargin)[];

end

% maxProj
maxProjFilePath = fullfile(itmdPath, 'maxProj.isxd');

maxProjComp = glab.proc.CachedComp( ...
    @glab.isx.projectMax, 0, ...
    @()chkCached({maxProjFilePath}), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% rect
rectFilePath = fullfile(itmdPath, 'cropRect.mat');

rectComp = glab.proc.CachedComp( ...
    @glab.ca.cropUI, 1, ...
    @()chkCached({rectFilePath}), ...
    @()glab.util.matLoad(rectFilePath), ...
    @(x)glab.util.matSave(rectFilePath, x), ...
    'logger', l ...
);

% crop
cropFilePaths = glab.util.txFilePaths( ...
    sdsFilePaths, ...
    'pathTx', @(path)itmdPath, ...
    'nameTx', @(name)[name '-CROP'], ...
    'extnTx', @(extn)'.isxd' ...
);

cropComp = glab.proc.CachedComp( ...
    @glab.isx.crop, 0, ...
    @()chkCached(cropFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% bp
bpFilePaths = glab.util.txFilePaths( ...
    cropFilePaths, ...
    'nameTx', @(name)[name '-BP'] ...
);

bpComp = glab.proc.CachedComp( ...
    @glab.isx.spatialFilter, 0, ...
    @()chkCached(bpFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% mc
mcFilePaths = glab.util.txFilePaths( ...
    bpFilePaths, ...
    'nameTx', @(name)[name '-MC'] ...
);
tslnFilePaths = glab.util.txFilePaths( ...
    bpFilePaths, ...
    'nameTx', @(name)[name '-translations'], ...
    'extnTx', @(extn)'.csv' ...
);

mcComp = glab.proc.CachedComp( ...
    @glab.isx.motionCorrect, 0, ...
    @()chkCached(mcFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

% dff
dffFilePaths = glab.util.txFilePaths( ...
    mcFilePaths, ...
    'pathTx', @(path)outPath, ...
    'nameTx', @(name)[name '-DFF'] ...
);

dffComp = glab.proc.CachedComp( ...
    @glab.isx.dff, 0, ...
    @()chkCached(dffFilePaths), ...
    @()[], ...
    @(x)[], ...
    'logger', l ...
);

%%
l.debug(['isxVer = ' isxVer]);
l.debug(['useCached = ' num2str(useCached)]);
l.debug(['isxPath = ' isxPath]);
l.debug(['outPath = ' outPath]);
l.debug(['itmdPath = ' itmdPath]);
l.debug(['useParallel = ' num2str(useParallel)]);

l.infoSrE('Spatially downsampling');
glab.proc.runComp( ...
    sdsComp, 0, ...
    isxFilePaths, sdsFilePaths, 2, ...
    'useParallel', useParallel ...
);
l.srX();

l.infoSrE('Taking maximum projection for use as cropping reference');
glab.proc.runComp( ...
    maxProjComp, 0, ...
    sdsFilePaths, maxProjFilePath ...
);
maxProjRef = isx.Image.read(maxProjFilePath);
maxProj = maxProjRef.get_data();
l.srX();

l.infoSrE('Providing crop UI');
rect = glab.proc.runComp( ...
    rectComp, 1, ...
    maxProj ...
);
% We have to destructure results from runComp
rect = rect{1}{1};
l.srX();

l.infoSrE('Cropping');
glab.proc.runComp( ...
    cropComp, 0, ...
    sdsFilePaths, cropFilePaths, rect, ...
    'useParallel', useParallel ...
);
l.srX();

l.infoSrE('Spatial-bandpass filtering')
glab.proc.runComp( ...
    bpComp, 0, ...
    cropFilePaths, bpFilePaths,...
    'lowCutoff', 0.005,...
    'highCutoff', 0.500 ...
);
l.srX();

l.infoSrE('Motion-correcting movie');
glab.proc.runComp( ...
    mcComp, 0, ...
    bpFilePaths, mcFilePaths, tslnFilePaths ...
);
l.srX();

l.infoSrE('Calculating DF/F');
glab.proc.runComp( ...
    dffComp, 0, ...
    mcFilePaths, dffFilePaths ...
);
l.srX()

end

