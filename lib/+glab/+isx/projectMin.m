function [] = projectMin(inputFilePaths, outputFilePath)
%PROJECTMIN A thin wrapper around the Inscopix MATLAB API's min projection calls.
% v0.1.0 | nGelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.projectMin( ...
%       inputFilePaths::cell(string), ...
%       outFilePath::string ...
%   )
%   `inputFilePaths` should be a cell of paths to .isxd files to operate 
%   on. `outputFilePath` should be a path to an .isxd file to output.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofp = '~/mov-min.isxd';
%   >> [nPixels2, nFrames] = glab.isx.movieMetadata(ifps{1});
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
%   >> [] = glab.isx.projectMin(ifps, ofp);
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
isx.project_movie(inputFilePaths, outputFilePath, 'stat_type', 'min');

end

