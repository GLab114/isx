function filePaths = baseSeriesInDir(path)
%BASESERIESINDIR Collect the "least-processed" Inscopix data files in a directory.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   filePaths::cell(string) = glab.isx.util.baseSeriesInDir(path::string)
%
%   Examples:
%   >> path = '~/data';
%   >> allIsxds = glab.util.regex.dir(path, 'isxd$');
%   >> allIsxds
%
%   ans =
%
%     8x1 cell array
%
%       {'~/data/dcmp/rec1-SDS.isxd'               }
%       {'~/data/dcmp/rec1-SDS.isxd'               }
%       {'~/data/dcmp/rec1-SDS-CROP.isxd'          }
%       {'~/data/dcmp/rec1-SDS-CROP.isxd'          }
%       {'~/data/dcmp/rec1-SDS-CROP-BP.isxd'       }
%       {'~/data/dcmp/rec1-SDS-CROP-BP.isxd'       }
%       {'~/data/dcmp/rec1-SDS-CROP-BP-MC.isxd'    }
%       {'~/data/dcmp/rec1-SDS-CROP-BP-MC.isxd'    }
%
%   >> leastProcd = glab.isx.util.baseSeriesInDir(path);
%   >> leastProcd
%
%   ans =
%
%     2x1 cell array
%
%       {'~/data/dcmp/rec1-SDS.isxd'}
%       {'~/data/dcmp/rec1-SDS.isxd'}

%%
allISXDs = glab.util.regex.dir(path, 'isxd$');
nameLengths = cellfun(@length, allISXDs);
filePaths = allISXDs(nameLengths == min(nameLengths));

end

