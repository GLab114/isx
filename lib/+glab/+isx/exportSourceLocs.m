function [] = exportSourceLocs(outputFilePath, srcLocs)
%EXPORTSOURCELOCS Export source localizaitons from memory to an Inscopix datafile.
% v0.1.0 | N Gelwan | 2020-05
%
%   Usage:
%   [] = glab.isx.exportSources( ...
%       outputFilePath::string, ...
%       srcLocs::double(ns, nx, ny) ...
%   )
%   Export source locales to a datafile specified by the file path given in
%   the string `outputFilePath`. `srcLocs` should be an array; it is
%   indexed in the first dimension by source; it is indexed in the second
%   dimension by pixel "x" value; it is indexed in the third dimension by
%   pixel "y" value.
%
%   Examples:
%   >> ofp = '~/mov-PCAICA-PROC-LOCS.isxd';
%   >> nSrcs = 75;
%   >> nPixels2 = [300 400];
%   >> srcLocs = rand(nSrcs, nPixels2(1), nPixels2(2));
%   >> glab.isx.exportSources(ofp, srcLocs);
%   >> [nPixels2, ~, nSrcs] = glab.isx.cellSetMetadata(ofp);
%   >> nPixels2
%
%   ans =
%
%       300     400
%
%   >> nSrcs
%
%   ans =
%
%       75

%%
warning('off', 'MATLAB:DELETE:FileNotFound');
delete(outputFilePath);
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
nPixels2 = [size(srcLocs, 1) size(srcLocs, 2)];
nSrcs = size(srcLocs, 3);

m = isx.CellSet.write( ...
    outputFilePath, ...
    isx.Timing('num_samples', 1), ...
    isx.Spacing('num_pixels', nPixels2) ...
);

for i = 1:nSrcs
    m.set_cell_data( ...
        i - 1, ...
        single(srcLocs(:, :, i)), ...
        single(0), ...
        num2str(i) ...
    );
end
m.flush();

end

