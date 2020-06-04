function [nPixels2, nFrames, nSrcs] = cellSetMetadata(filePath)
%CELLSETMETADATA Quickly collect metadata from an Inscopix data file conatining a cell set.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [nPixels2::[int int], nFrames::int, nSrcs::int] = ...
%       glab.isx.cellSetMetadata(filePath::string)
%   Load metadata from file located at `filePath`. `nPixels2` is an array
%   specifying the x and y pixel size of the source localizations; 
%   `nFrames` contains the number of frames in the source traces; `nSrcs`
%   is the number of sources in the cell set.
% 
%   Example:
%   >> fp = '~/data/cellset.isxd';
%   >> [nPixels2, nFrames, nSrcs] = glab.isx.cellSetMetadata(fp);
%   >> nPixels2
%   
%   ans =
%      
%      300     500
%
%   >> nFrames
%
%   ans =
%
%      1000
%
%   >> nSrcs
%
%   ans =
%
%       15

%%
m = isx.CellSet.read(filePath);
nPixels2 = m.spacing.num_pixels;
nFrames = m.timing.num_samples;
nSrcs = m.num_cells;

end