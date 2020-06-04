function [nPixels2, nFrames, nBytes, fps] = movieMetadata(filePath)
%MOVIEMETADATA Quickly collect metadata from an Inscopix data file containing a movie.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [nPixels2::[int int], nFrames::int, nBytes::int, fps::double] = ...
%       glab.isx.movieMetadata(filePath::string)
%   Load metadata from file located at `filePath`. `nPixels2` is an array
%   specifying the x and y pixel size of the movie; `nFrames` contains the
%   number of frames of the movie; `nBytes` is the estimated byte-size of 
%   the data-structure; `fps` is the recording rate of the movie.
% 
%   Example:
%   >> fp = '~/data/mov.isxd';
%   >> [nPixels2, nFrames, nBytes, fps] = glab.isx.movieMetadata(fp);
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
%   >> nBytes
%
%   ans =
%
%      9.6000e+09
%
%   >> fps
%
%   ans =
%
%      20

%%
m = isx.Movie.read(filePath);
nPixels2 = m.spacing.num_pixels;
nFrames = m.timing.num_samples;
fps = 1 / m.timing.period.secs_float;
nVoxels = prod([nPixels2 nFrames]);
dtype = m.data_type;
nBytes = nVoxels * glab.util.sizeof.dtype(dtype);

end