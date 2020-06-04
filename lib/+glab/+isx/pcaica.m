function [] = pcaica(inputFilePaths, outputFilePaths, nICs, varargin)
% PCAICA A thin wrapper around the Inscopix MATLAB API's PCA/ICA source-extraction routine.
% v0.3.0 | N Gelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.pcaica( ...
%       inputFilePaths::cell(string), ...
%       outputFilePaths::cell(string), ...
%       nICs::int ...
%   )
%   Runs the Inscopix API's PCAICA routines. `inputFilePaths` should be a
%   cell array of file paths to Inscopix movie files constituting a time
%   series. `outputFilePaths` will specify the output cell sets for each
%   movie input in a cell array of file paths. `nICs` should be entered to
%   estimate the number of independent components PCAICA should produce.
%   See glab.ca.estimateNICs for a potential automated solution.
%
%   The following keyword arguments are well-documented in the Inscopix API
%   https://support.inscopix.com/sites/default/files/sphinx/2679/algorithms/cellID/PCA_ICA.html#pca-ica
%
%   _ = glab.isx.pcaica(_, 'nPCs', x::int)
%   See Inscopix API docs. This is set to a default of `0.8 * nICs`.
%
%   _ = glab.isx.pcaica(_, 'unmixType', x::string)
%   See Inscopix API docs. Must be one of `{'spatial', 'tempora', 'both'}`.
%   This defaults to `'spatial'`.
%
%   _ = glab.isx.pcaica(_, 'icaTemporalWeight', x::float)
%   See Inscopix API docs. Should be a float from `0.0` to `1.0`. Defaults
%   to `0.1`.
%
%   _ = glab.isx.pcaica(_, 'maxIterations', x::int)
%   Icrease the number of iterations of the PCA/ICA algorithm. Defaults to
%   `100`. If PCA/ICA is not converging in 100 iterations, then your input
%   or your `nICs` value is outside an empirically-established (thus-far)
%   range of reasonable-ness/usefulness.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofps = {'~/mov1-PCAICA.isxd', '~/mov2-PCAICA.isxd'};
%   >> [nPixels2, nFrames] = glab.isx.movieMetadata(ifps{1});
%   >> nPixels2
%
%   ans =
%       
%       300     400
%
%   ans =
%
%       1000
%
%   >> [] = glab.isx.pcaica(ifps, ofps, 150);
%   >> [nPixles2, nFrames, nSrcs] = glab.isx.cellSetMetadata(ofps{1});
%   >> nPixels2
%
%   ans =
%
%       300     400
%
%   >> nFrames
%
%   ans =
%
%       1000
%
%   >> nSrcs
%
%   ans =
%
%       150

%% Input parsing
defaultNPCs = [];
defaultUnmixType = 'spatial';
expectedUnmixType = {'spatial' 'temporal' 'both'};
defaultICATemporalWeight = 0.1;
defaultBlockSize = 1000;
defaultMaxIterations = 100;

p = inputParser();
addParameter(p, 'nPCs', defaultNPCs, ...
    @(x)isscalar(x) && isinteger(x));
addParameter(p, 'unmixType', defaultUnmixType, ...
    @(x)validstring(x, expectedUnmixType));
addParameter(p, 'icaTemporalWeight', defaultICATemporalWeight, ...
    @(x)isscalar(x) && (x >= 0) && (x <= 1));
addParameter(p, 'blockSize', defaultBlockSize, ...
    @(x)isscalar(x) && (x > 0));
addParameter(p, 'maxIterations', defaultMaxIterations, ...
    @(x)(x > 0) && (round(x) == x));
parse(p, varargin{:})

nPCs = p.Results.nPCs;
unmixType = p.Results.unmixType;
icaTemporalWeight = p.Results.icaTemporalWeight;
blockSize = p.Results.blockSize;
maxIterations = p.Results.maxIterations;

%%
if isempty(nPCs)
    nPCs = floor(0.8 * nICs);
end

warning('off', 'MATLAB:DELETE:FileNotFound');
for i = 1:length(outputFilePaths)
    delete(outputFilePaths{i});
end
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
isx.pca_ica(...
    inputFilePaths, outputFilePaths, nPCs, nICs, ...
    'unmix_type', unmixType, ...
    'ica_temporal_weight', icaTemporalWeight, ...
    'block_size', blockSize, ...
    'max_iterations', maxIterations ...
);

end