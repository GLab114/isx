function [] = motionCorrect(inputFilePaths, outputFilePaths, ...
    tslnFilePaths)
% MOTIONCORRECT A thin wrapper around the Inscopix MATLAB API's motion-correcting calls.
% v0.1.0 | nGelwan | 2020
%
% REVIEW: As of now, this wrapper has the parameters which we've been using
% exclusively hard-coded in. This may deserve to be changed later.
% NOTE: This wrapper basically does nothing expect change the call
% signature and hard-code in those params. I made it for scheme's sake,
% because one day we may want these to be switches against alternatives to
% Inscopix's stuff, and because I'm not sure if Inscopix's API will stay
% stable-- this is a layer of insulation on the pipeline.
%
%   Usage:
%   [] = glab.isx.motionCorrect( ...
%       inputFilePaths::cell(string), ...
%       outputFilePaths::cell(string), ...
%       tslnFilePaths::cell(string) ...
%   )
%   Motion corrects an inscopix movie. `inputFilePaths` should be a cell 
%   of paths to .isxd files to operate on. `outputFilePaths` should be a 
%   cell of paths to .isxd files to output the motion-corrected movies to. 
%   `tslnFilePaths` should be a cell of paths to .csv files to output the 
%   translation traces to.
%
%   Examples:
%   >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
%   >> ofps = {'~/mov1-MC.isxd', '~/mov2-MC.isxd'};
%   >> tfps = {'~/mov1-MC-tsln.csv', '~/mov2-MC-tsln.csv'};
%   >> [] = glab.isx.motionCorrect(ifps, ofps, tfps);

%%
warning('off', 'MATLAB:DELETE:FileNotFound');
for i = 1:length(inputFilePaths)
    delete(outputFilePaths{i});
end
warning('on', 'MATLAB:DELETE:FileNotFound');

%%
isx.motion_correct( ...
    inputFilePaths, outputFilePaths, ...
    'output_translation_files', tslnFilePaths, ...
    'max_translation', 20,...
    'low_bandpass_cutoff', 0,...
    'high_bandpass_cutoff', 0 ...
);

end

