function name = recName(filePath)
%RECNAME Extract the base name from a traditionally-name Inscopix data file.
% v0.1.0 | N Gelwan | 2020-05
%
%   NOTE: This works with the Inscopix hardware and software provided as of
%   2020-05. It could change in the future, although I don't expect it
%   will.
%
%   Usage:
%   name::string = glab.isx.util.recName(filePath::string)
%
%   Examples:
%   >> ifp = 'recording_20200501_140722-SDS-CROP-BP-MC-DFF.isxd';
%   >> name = glab.isx.util.recName(ifp);
%   >> name
%
%   ans =
%
%       'recording_20200501_140522'

%%
[~, longName] = fileparts(filePath);
name = longName(1:25);

end

