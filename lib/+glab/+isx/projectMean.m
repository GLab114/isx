function [] = projectMean(inputFilePaths, outputFilePath)
%PROJECTMEAN A thin wrapper around the Inscopix MATLAB API's mean projection calls.
% v0.1.0 | nGelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.projectMean( ...
%       inputFilePaths::cell(string), ...
%       outFilePath::string ...
%   )
%   `inputFilePaths` should be a cell of paths to .isxd files to operate 
%   on. `outputFilePath` should be a path to an .isxd file to output.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofp = '~/mov-mean.isxd';
%   >> [nPixels2, nFrames] = glab.isx.fileMetadata(ifps{1});
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
%   >> [] = glab.isx.projectMean(ifps, ofp);
%   >> nPixels2 = glab.isx.imageMetadata(ofp);
%   >> nPixels2
%
%   ans =
%
%       300     400

%%
warning('off', 'MATLAB:DELETE:FileNotFound');
delete(outputFilePath);
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
isx.project_movie(inputFilePaths, outputFilePath, 'stat_type', 'mean');

end

