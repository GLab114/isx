function [nPixels2, nBytes] = imageMetadata(filePath)
%IMAGEMETADATA Quickly collect metadata from an Inscopix data file conatining an image.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [nPixels2::[int int], nBytes::int] = ...
%       glab.isx.imageMetadata(filePath::string)
%   Load metadata from file located at `filePath`. `nPixels2` is an array
%   specifying the x and y pixel size of the image; `nBytes` is the 
%   estimated byte-size of the data-structure;
% 
%   Example:
%   >> fp = '~/data/img.isxd';
%   >> [nPixels2, nBytes] = glab.isx.imageMetadata(fp);
%   >> nPixels2
%   
%   ans =
%      
%      300     500
%
%   >> nBytes
%
%   ans =
%
%      9.6000e+06

%%
m = isx.Image.read(filePath);
nPixels2 = m.spacing.num_pixels;
dtype = m.data_type;
nBytes = prod(nPixels2) * glab.util.sizeof.dtype(dtype);

end