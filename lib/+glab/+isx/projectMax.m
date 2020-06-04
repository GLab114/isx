function [] = projectMax(inputFilePaths, outputFilePath)
%PROJECTMAX A thin wrapper around the Inscopix MATLAB API's max projection calls.
% v0.1.0 | nGelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.projectMax( ...
%       inputFilePaths::cell(string), ...
%       outFilePath::string ...
%   )
%   `inputFilePaths` should be a cell of paths to .isxd files to operate 
%   on. `outputFilePath` should be a path to an .isxd file to output. 
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofp = '~/mov-max.isxd';
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
%   >> [] = glab.isx.projectMax(ifps, ofp);
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
isx.project_movie(inputFilePaths, outputFilePath, 'stat_type', 'max');

end

