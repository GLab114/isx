# GLab114/isx
www.github.com/GLab114/isx
This repository depends upon the following resources to work properly:
- Inscopix IDPS API (https://support.inscopix.com/support/products/data-processing-software/inscopix-data-processing-v131)
- GLab114/lib (www.github.com/GLab114/lib)
- GLab114/ppln (www.github.com/GLab114/ppln)

In order to use any of the following features, the above resoures must be properly available, and the two folders in the base of the repo, lib and ppln, must be added to the MATLAB path.

The "Usage" portions of the following document use an extended form of MATLAB syntax in function signatures to indicate expected argument types. These constraints are rarely enforced at runtime; the burden is on the user to make sure a function is operating on the appropriate type.

Details on the contents of the repository follow.

## Namespace: glab.isx

This namespace contains. A library of functions useful for interacting with Inscopix datafiles (.isxd) in any context. Most of the functions in this library are thin wrappers around Inscopix API calls. The best documentation for these routines can be found on the Inscopix website (https://support.inscopix.com/inscopix-data-processing-131-user-guide-html). As of 2020-05, this API was at version 1.3.1; I don't expect Inscopix to have many major version updates in the near-future, but keep the possibility of change in mind.

Many of these functions don't do much except provide GLab-canonical defaults and coerce the syntax into one consistent with the rest of *glab* (especially with respect to 0-based indexing). There are some that provide naive parallelization which improves performance in a MATLAB parallel environment (see *glab.parenv* in www.github.com/GLab114/lib). Almost all of the wrapper functions will **delete specified output files without confirmation** before running the routine; the default behavior by the Inscopix API is to throw a violent error if any output files are already present. Do not pass paths as output files to these functions without careful consideration or programmatic safeguards on the frontend.

### Function: glab.isx.temporalDownsample

    A thin wrapper around the Inscopix MATLAB API's downsampling calls.
     v0.1.0 | nGelwan | 2020-05
       Usage:
       [] = glab.isx.temporalDownsample( ...
           inputFilePaths::cell(string), ...
           outFilePaths::cell(string), ...
           dsFactor::int ...
       )
       Provides naive parallelization of Inscopix's API. `inputFilePaths`
       should be a cell of paths to .isxd files to operate on. 
       `outputFilePaths` should be a cell of paths to .isxd files to 
       output. Downsample time by a factor of `dsFactor`.
    
       _ = glab.isx.temporalDownsample(_, 'useParallel', x::bool)
       Disable the parallelization. Defaults to `true`.

Examples:

    >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
    >> ofps = {'~/mov1-TDS.isxd', '~/mov2-TDS.isxd'};
    >> [~, nFrames] = glab.isx.movieMetadata(ifps{1});
    >> nFrames
    
    ans =

        1000

    >> [] = glab.isx.temporalDownsamples(ifps, ofps, 5);
    >> [~, nFrames] = glab.isx.movieMetadata(ofps{1});
    >> nFrames

    ans =

        200

### Function: glab.isx.spatialFilter

    SPATIALFILTER A thin wrapper around the Inscopix MATLAB API's spatial bandpass filtering calls.
     v0.1.0 | nGelwan | 2020-05
       Usage:
       [] = glab.isx.spatialFilter( ...
           inputFilePaths::cell(string), ...
           outFilePaths::cell(string), ...
       )
       `inputFilePaths` should be a cell of paths to .isxd files to operate 
       on. `outputFilePaths` should be a cell of paths to .isxd files to 
       output.
    
       _ = glab.isx.spatialFilter(_, 'lowCutoff', x::float)
       The low spatial frequency cutoff, in units of pixels^(-1). Defaults to
       `0.005`.
    
       _ = glab.isx.spatialFilter(_, 'highCutOff', x::float)
       The high spatial frequency cutoff, in units of pixels^(-1). Defaults to
       `0.500`.
    
       Examples:

    >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
    >> ofps = {'~/mov1-BP.isxd', '~/mov2-BP.isxd'};
    >> [] = glab.isx.spatialFilter(ifps, ofps);

### Function: glab.isx.spatialDownsample

    SPATIALDOWNSAMPLE A thin wrapper around the Inscopix MATLAB API's downsampling calls.
     v0.1.0 | nGelwan | 2020-05
    
       Usage:
       [] = glab.isx.spatialDownsample( ...
           inputFilePaths::cell(string), ...
           outFilePaths::cell(string), ...
           dsFactor::int ...
       )
       Provides naive parallelization of Inscopix's API. `inputFilePaths`
       should be a cell of paths to .isxd files to operate on. 
       `outputFilePaths` should be a cell of paths to .isxd files to 
       output. Downsample both spatial dimensions by a factor of `dsFactor`.
    
       _ = glab.isx.spatialDownsample(_, 'useParallel', x::bool)
       Disable the parallelization. Defaults to `true`.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofps = {'~/mov1-TDS.isxd', '~/mov2-SDS.isxd'};
       >> nPixels2 = glab.isx.movieMetadata(ifps{1});
       >> nPixels2
    
       ans =
           
           300     400
    
       >> [] = glab.isx.spatialDownsample(ifps, ofps, 2);
       >> nPixles2 = glab.isx.movieMetadata(ofps{1});
       >> nPixels2
    
         ans =
    
           150     200

### Function: glab.isx.projectMin

    PROJECTMIN A thin wrapper around the Inscopix MATLAB API's min projection calls.
     v0.1.0 | nGelwan | 2020-05
    
       Usage:
       [] = glab.isx.projectMin( ...
           inputFilePaths::cell(string), ...
           outFilePath::string ...
       )
       `inputFilePaths` should be a cell of paths to .isxd files to operate 
       on. `outputFilePath` should be a path to an .isxd file to output.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofp = '~/mov-min.isxd';
       >> [nPixels2, nFrames] = glab.isx.movieMetadata(ifps{1});
       >> nPixels2
    
       ans =
           
           300     400
    
       >> nFrames
    
       ans =
    
           1000
    
       >> [] = glab.isx.projectMin(ifps, ofp);
       >> nPixels2 = glab.isx.imageMetadata(ofp);
       >> nPixels2
    
       ans =
    
           300     400

### Function: glab.isx.projectMean

    PROJECTMEAN A thin wrapper around the Inscopix MATLAB API's mean projection calls.
     v0.1.0 | nGelwan | 2020-05
    
       NOTE: The Inscopix MATLAB API must be on the MATLAB path for this to
       work.
    
       Usage:
       [] = glab.isx.projectMean( ...
           inputFilePaths::cell(string), ...
           outFilePath::string ...
       )
       `inputFilePaths` should be a cell of paths to .isxd files to operate 
       on. `outputFilePath` should be a path to an .isxd file to output.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofp = '~/mov-mean.isxd';
       >> [nPixels2, nFrames] = glab.isx.fileMetadata(ifps{1});
       >> nPixels2
    
       ans =
           
           300     400
    
       >> nFrames
    
       ans =
    
           1000
    
       >> [] = glab.isx.projectMean(ifps, ofp);
       >> nPixels2 = glab.isx.imageMetadata(ofp);
       >> nPixels2
    
       ans =
    
           300     400

### Function: glab.isx.projectMax

    PROJECTMAX A thin wrapper around the Inscopix MATLAB API's max projection calls.
     v0.1.0 | nGelwan | 2020-05
    
       NOTE: The Inscopix MATLAB API must be on the MATLAB path for this to
       work.
    
       Usage:
       [] = glab.isx.projectMax( ...
           inputFilePaths::cell(string), ...
           outFilePath::string ...
       )
       `inputFilePaths` should be a cell of paths to .isxd files to operate 
       on. `outputFilePath` should be a path to an .isxd file to output. 
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofp = '~/mov-max.isxd';
       >> [nPixels2, nFrames] = glab.isx.fileMetadata(ifps{1});
       >> nPixels2
    
       ans =
           
           300     400
    
       >> nFrames
    
       ans =
    
           1000
    
       >> [] = glab.isx.projectMax(ifps, ofp);
       >> nPixels2
    
       ans =
    
           300     400

### Function: glab.isx.pcaica

     PCAICA A thin wrapper around the Inscopix MATLAB API's PCA/ICA source-extraction routine.
     v0.3.0 | N Gelwan | 2020-05
    
       Usage:
       [] = glab.isx.pcaica( ...
           inputFilePaths::cell(string), ...
           outputFilePaths::cell(string), ...
           nICs::int ...
       )
       Runs the Inscopix API's PCAICA routines. `inputFilePaths` should be a
       cell array of file paths to Inscopix movie files constituting a time
       series. `outputFilePaths` will specify the output cell sets for each
       movie input in a cell array of file paths. `nICs` should be entered to
       estimate the number of independent components PCAICA should produce.
       See glab.ca.estimateNICs for a potential automated solution.
    
       The following keyword arguments are well-documented in the Inscopix API
       https://support.inscopix.com/sites/default/files/sphinx/2679/algorithms/cellID/PCA_ICA.html#pca-ica
    
       _ = glab.isx.pcaica(_, 'nPCs', x::int)
       See Inscopix API docs. This is set to a default of `0.8 * nICs`.
    
       _ = glab.isx.pcaica(_, 'unmixType', x::string)
       See Inscopix API docs. Must be one of `{'spatial', 'tempora', 'both'}`.
       This defaults to `'spatial'`.
    
       _ = glab.isx.pcaica(_, 'icaTemporalWeight', x::float)
       See Inscopix API docs. Should be a float from `0.0` to `1.0`. Defaults
       to `0.1`.
    
       _ = glab.isx.pcaica(_, 'maxIterations', x::int)
       Icrease the number of iterations of the PCA/ICA algorithm. Defaults to
       `100`. If PCA/ICA is not converging in 100 iterations, then your input
       or your `nICs` value is outside an empirically-established (thus-far)
       range of reasonable-ness/usefulness.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofps = {'~/mov1-PCAICA.isxd', '~/mov2-PCAICA.isxd'};
       >> [nPixels2, nFrames] = glab.isx.movieMetadata(ifps{1});
       >> nPixels2
    
       ans =
           
           300     400
    
       ans =
    
           1000
    
       >> [] = glab.isx.pcaica(ifps, ofps, 150);
       >> [nPixles2, nFrames, nSrcs] = glab.isx.cellSetMetadata(ofps{1});
       >> nPixels2
    
       ans =
    
           300     400
    
       >> nFrames
    
       ans =
    
           1000
    
       >> nSrcs
    
       ans =
    
           150

### Function: glab.isx.overview

    OVERVIEW Provide an overview of a base Inscopix time series.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [recs::table, fps::double] = glab.isx.overview(path::string)
       Create an overview of the base Inscopix time series located in the
       directory specified by `path`. Produces a table `recs` and a double
       `fps` which specifies the framerate common to series.
    
       Errors:
       - InputError: when the base series in `path` contains different
       framerates
    
       Examples:
       >> path = '~/data';
       >> glab.util.regex.dir(path, 'isxd$');
    
       ans =
     
         4?1 cell array
     
           {'~/data/mov1.isxd'      }
           {'~/data/mov2.isxd'      }
           {'~/data/mov1-PROCD.isxd'}
           {'~/data/mov2-PROCD.isxd'}
    
       >> [recs, fps] = glab.isx.overview(path);
       >> recs
    
       ans =
     
         9?10 table
     
        name       idxStart     idxLength    idxStop         timeStart          timeLength          timeStop          tsStart    tsStop    dropped
           ______    __________    _________    _______    ____________________    __________    ____________________    _______    ______    _______
     
           'mov1'             1      12080        12080    30-Nov-2017 10:06:49     00:10:04     30-Nov-2017 10:16:53      NaN       NaN        []   
           'mov2'         12081      12033        24113    30-Nov-2017 10:20:24     00:10:01     30-Nov-2017 10:30:25      NaN       NaN        []   


### Function: glab.isx.movieMetadata

    MOVIEMETADATA Quickly collect metadata from an Inscopix data file containing a movie.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [nPixels2::[int int], nFrames::int, nBytes::int, fps::double] = ...
           glab.isx.movieMetadata(filePath::string)
       Load metadata from file located at `filePath`. `nPixels2` is an array
       specifying the x and y pixel size of the movie; `nFrames` contains the
       number of frames of the movie; `nBytes` is the estimated byte-size of 
       the data-structure; `fps` is the recording rate of the movie.
     
       Example:
       >> fp = '~/data/mov.isxd';
       >> [nPixels2, nFrames, nBytes, fps] = glab.isx.movieMetadata(fp);
       >> nPixels2
       
       ans =
          
          300     500
    
       >> nFrames
    
       ans =
    
          1000
    
       >> nBytes
    
       ans =
    
          9.6000e+09
    
       >> fps
    
       ans =
    
          20

### Function: glab.isx.motionCorrect

     MOTIONCORRECT A thin wrapper around the Inscopix MATLAB API's motion-correcting calls.
     v0.1.0 | nGelwan | 2020
    
     REVIEW: As of now, this wrapper has the parameters which we've been using
     exclusively hard-coded in. This may deserve to be changed later.
     NOTE: This wrapper basically does nothing expect change the call
     signature and hard-code in those params. I made it for scheme's sake,
     because one day we may want these to be switches against alternatives to
     Inscopix's stuff, and because I'm not sure if Inscopix's API will stay
     stable-- this is a layer of insulation on the pipeline.
    
       Usage:
       [] = glab.isx.motionCorrect( ...
           inputFilePaths::cell(string), ...
           outputFilePaths::cell(string), ...
           tslnFilePaths::cell(string) ...
       )
       Motion corrects an inscopix movie. `inputFilePaths` should be a cell 
       of paths to .isxd files to operate on. `outputFilePaths` should be a 
       cell of paths to .isxd files to output the motion-corrected movies to. 
       `tslnFilePaths` should be a cell of paths to .csv files to output the 
       translation traces to.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofps = {'~/mov1-MC.isxd', '~/mov2-MC.isxd'};
       >> tfps = {'~/mov1-MC-tsln.csv', '~/mov2-MC-tsln.csv'};
       >> [] = glab.isx.motionCorrect(ifps, ofps, tfps);

### Function: glab.isx.importSources

    IMPORTSOURCES Import sources to memory from Inscopix datafiles.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [srcLocs::double(ns, nx, ny), srcTraces::double(ns, nt)] = ...
           glab.isx.importSources(inputFilePaths::cell(string))
       Import data into memory from Inscopix cell sets specified by
       `inputFilePaths`, a cell array of file paths. `srcLocs` will be an
       array containing the localizations of those sources; it is indexed in
       the first dimension by source; it is indexed in the second dimension by
       pixel "x" value; it is indexed in the third dimension by pixel "y"
       value. `srcTraces` will be an array containing the traces of those
       sources; it is indexed in the first dimension by source; it is indexed
       in the second dimension by frame.
    
       _ = glab.isx.importSources(_, 'useParallel', b::bool)
       Use a naive form of parallelization to accelerate reading from file.
       Defaults to `true`.
    
       Examples:
       >> ifps = {'mov1-PCAICA.isxd', 'mov2-PCAICA.isxd'};
       >> [nPixels2, nFrames, nSrcs] = cellfun( ...
        @glab.isx.cellSetMetadata, ...
        ifps, ...
        'UniformOutput', false ...
          );
       >> nPixels2{1}
    
       ans =
    
           300     400
    
       >> sum(cell2mat(nFrames))
    
       ans = 
    
           1000
    
       >> nSrcs{1}
    
       ans =
    
           75
    
       >> [srcLocs, srcTraces] = glab.isx.importSources(ifps);
       >> size(srcLocs)
    
       ans =
       
           75     300     400
    
       >> size(srcTraces)
    
       ans =
    
           75     1000

### Function: glab.isx.imageMetadata

    IMAGEMETADATA Quickly collect metadata from an Inscopix data file conatining an image.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [nPixels2::[int int], nBytes::int] = ...
           glab.isx.imageMetadata(filePath::string)
       Load metadata from file located at `filePath`. `nPixels2` is an array
       specifying the x and y pixel size of the image; `nBytes` is the 
       estimated byte-size of the data-structure;
     
       Example:
       >> fp = '~/data/img.isxd';
       >> [nPixels2, nBytes] = glab.isx.imageMetadata(fp);
       >> nPixels2
       
       ans =
          
          300     500
    
       >> nBytes
    
       ans =
    
          9.6000e+06

### Function: glab.isx.exportSourceLocs

    EXPORTSOURCELOCS Export source localizaitons from memory to an Inscopix datafile.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [] = glab.isx.exportSources( ...
           outputFilePath::string, ...
           srcLocs::double(ns, nx, ny) ...
       )
       Export source locales to a datafile specified by the file path given in
       the string `outputFilePath`. `srcLocs` should be an array; it is
       indexed in the first dimension by source; it is indexed in the second
       dimension by pixel "x" value; it is indexed in the third dimension by
       pixel "y" value.
    
       Examples:
       >> ofp = '~/mov-PCAICA-PROC-LOCS.isxd';
       >> nSrcs = 75;
       >> nPixels2 = [300 400];
       >> srcLocs = rand(nSrcs, nPixels2(1), nPixels2(2));
       >> glab.isx.exportSources(ofp, srcLocs);
       >> [nPixels2, ~, nSrcs] = glab.isx.cellSetMetadata(ofp);
       >> nPixels2
    
       ans =
    
           300     400
    
       >> nSrcs
    
       ans =
    
           75

### Function: glab.isx.dff

    DFF A thin wrapper around the Inscopix MATLAB API's DF/F routines.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [] = glab.isx.dff( ...
           inputFilePaths::cell(string), ...
           outputFilePaths::cell(string) ...
       );
       Calculate the DF/F on the series specified by `inputFilePaths` using
       mean projections as a reference.
    
       _ = glab.isx.dff(_, 'perRecording', x::bool)
       If true, calculate the reference for each recording indepedently. This
       can lead to different scales for each recording, and thus is not
       recommended. Note that false will disable the parallel wrapping,
       regardless of what the 'useParallel' kwarg is set to. Defaults to 
       false.
    
       _ = glab.isx.dff(_, 'useParallel', x::bool)
       If false, will disable parallel wrapping. Defaults to true.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofps = {'~/mov1-DFF.isxd', '~/mov2-DFF.isxd'};
       >> [] = glab.isx.dff(ifps, ofps);

### Function: glab.isx.crop

     CROP A thin wrapper around the Inscopix MATLAB API's cropping calls.
     v0.2.0 | nGelwan | 2019
    
       Usage:
       [] = glab.isx.crop(inputFilePaths, outFilePaths, rect)
       Provides naive parallelization of Inscopix's API. `inputFilePaths`
       should be a cell of paths to .isxd files to operate on. 
       `outputFilePaths` should be a cell of paths to .isxd files to output.
       `rect` should provide the location of the corners of the cropping
       rectangle arranged like [top left bottom right]. 
    
       _ = glab.isx.crop(_, 'useParallel', x::bool)
       Provide naive parallelization of the routine across files. Defaults to 
       `true`.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> ofps = {'~/mov1-CROP.isxd', '~/mov2-CROP.isxd'};
       >> nPixels2 = glab.isx.movieMetadata(ifps{1});
       >> nPixels2
    
       ans =
    
           300     400
    
       >> rect = [50 50 100 150];
       >> glab.isx.crop(ifps, ofps, rect);
       >> nPixels2 = glab.isx.movieMetadata(ofps{1});
       >> nPixels2
    
       ans =
    
           150     200

### Function: glab.isx.cellSetMetadata

    CELLSETMETADATA Quickly collect metadata from an Inscopix data file conatining a cell set.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [nPixels2::[int int], nFrames::int, nSrcs::int] = ...
           glab.isx.cellSetMetadata(filePath::string)
       Load metadata from file located at `filePath`. `nPixels2` is an array
       specifying the x and y pixel size of the source localizations; 
       `nFrames` contains the number of frames in the source traces; `nSrcs`
       is the number of sources in the cell set.
     
       Example:
       >> fp = '~/data/cellset.isxd';
       >> [nPixels2, nFrames, nSrcs] = glab.isx.cellSetMetadata(fp);
       >> nPixels2
       
       ans =
          
          300     500
    
       >> nFrames
    
       ans =
    
          1000
    
       >> nSrcs
    
       ans =
    
           15

### Function: glab.isx.applyCellSetLocs

    APPLYCELLSETLOCS Extract traces from a movie using the localizations of soures from an Inscopix cell set.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       [] = glab.isx.applyCellSetLocs( ...
           inputMovieFilePaths::cell(string), ...
           inputCellSetFilePath::string, ...
           outputCellSetFilePaths::cell(string) ...
       );
       Extract traces from a movie whose series is specified by
       `inputMovieFilePaths`, a cell array of file paths. Specify the 
       localizations to extract with a single cell set, specified by the 
       file path string `inputCellSetFilePath`. Save the resulting traces
       and the original localizations in the cell set specified by the cell 
       array of file paths `outputCellSetFilePaths`.
    
       Examples:
       >> ifps = {'~/mov1.isxd', '~/mov2.isxd'};
       >> csfp = '~/mov1-PROCD-PCAICA.isxd';
       >> ofps = {'~/mov1-XRCTD.isxd', '~/mov2-XRCTD.isxd'};
       >> [~, nFrames] = cellfun( ...
          @glab.isx.movieMetadata, ...
          ifps, ...
          'UniformOutput', false ...
          );
       >> cell2mat(nFrames)
    
       ans =
    
           1000     2000
    
       >> [~, ~, nSrcs] = glab.isx.cellSetMetadata(csfp);
       >> nSrcs
    
       ans =
    
           75
    
       >> [] = glab.isx.applyCellSetLocs(ifps, csfp, ofps);
       >> [~, nFrames, nSrcs] = cellfun( ...
         @glab.isx.cellSetMetadata, ...
         ofps, ...
         'UniformOutput', false ...
          );
       >> cell2mat(nFrames)
    
       ans =
    
           1000     2000
    
       >> cell2mat(nSrcs)
    
       ans =
    
           75     75

### Namespace: glab.isx.util

Several utility functions for working with Inscopix data files and folders containing Inscopix data files.

### Function: glab.isx.util.recName

    RECNAME Extract the base name from a traditionally-name Inscopix data file.
     v0.1.0 | N Gelwan | 2020-05
    
       NOTE: This works with the Inscopix hardware and software provided as of
       2020-05. It could change in the future, although I don't expect it
       will.
    
       Usage:
       name::string = glab.isx.util.recName(filePath::string)
    
       Examples:
       >> ifp = 'recording_20200501_140722-SDS-CROP-BP-MC-DFF.isxd';
       >> name = glab.isx.util.recName(ifp);
       >> name
    
       ans =
    
           'recording_20200501_140522'

### Function: glab.isx.util.baseSeriesInDir

    BASESERIESINDIR Collect the "least-processed" Inscopix data files in a directory.
     v0.1.0 | N Gelwan | 2020-05
    
       Usage:
       filePaths::cell(string) = glab.isx.util.baseSeriesInDir(path::string)
    
       Examples:
       >> path = '~/data';
       >> allIsxds = glab.util.regex.dir(path, 'isxd$');
       >> allIsxds
    
       ans =
    
         8x1 cell array
    
           {'~/data/dcmp/rec1-SDS.isxd'               }
           {'~/data/dcmp/rec1-SDS.isxd'               }
           {'~/data/dcmp/rec1-SDS-CROP.isxd'          }
           {'~/data/dcmp/rec1-SDS-CROP.isxd'          }
           {'~/data/dcmp/rec1-SDS-CROP-BP.isxd'       }
           {'~/data/dcmp/rec1-SDS-CROP-BP.isxd'       }
           {'~/data/dcmp/rec1-SDS-CROP-BP-MC.isxd'    }
           {'~/data/dcmp/rec1-SDS-CROP-BP-MC.isxd'    }
    
       >> leastProcd = glab.isx.util.baseSeriesInDir(path);
       >> leastProcd
    
       ans =
    
         2x1 cell array
    
           {'~/data/dcmp/rec1-SDS.isxd'}
           {'~/data/dcmp/rec1-SDS.isxd'}

## Namespace: glab.ppln.isx

This namespace contains two pre-made pipelines which process calcium imaging data produced by Inscopix using building blocks in *glab.isx*, i.e. using function provided by the Inscopix Data Processing API.

These two pipelines can actually be chained together; the output of *glab.ppln.isx.dff* can be used as the first input argument to *glab.ppln.isx.pcaica*.

### Function: glab.ppln.isx.dff

    DFF A pre-made DF/F pipeline wrapping the Inscopix Data Processing Software.
     v0.5.0 | N Gelwan | 2020-05
    
       Usage:
       [outPath::string, itmdPath::string] = ...
           glab.ppln.isx.dff(isxPath::string)
       Run a pre-made pipeline which processes the calcium movie series found
       in `isxPath` into a DF/F time series. If the time-series is produced
       with the nVista 2 hardware, i.e. is in the form of decompressed .hdf5
       files and associated .xml header files, this needs to be indicated
       using the `'isxVer'` keyword argument; see below.
    
       _ = glab.ppln.isx.dff(_, 'outPath', x::string)
       Specify the directory containing the DF/F time series manually.
       Defaults to `fullfile(isxPath, '../dff/out')`.
    
       _ = glab.ppln.isx.dff(_, 'itmdPath', x::string)
       Specify the directory where intermediate products of the pipeline will
       be stored. Defaults to `fullfile(isxPath, '../dff/itmd')`.
    
       _ = glab.ppln.isx.dff(_, 'isxVer', x::string)
       Specify the hardware version of the nVista system used to produce the
       input movies. This is associated with the file-format of the movie. If
       `'nVista2'` is specified, the input movies are expected to be .hdf5
       files and their associated .xml header files. Note that without the
       associated header files THIS WILL NOT WORK. Additionally, it is
       expected that spatial downsampling by a factor of 2 WILL ALREADY HAVE 
       BEEN PERFORMED DURING THE DECOMPRESSEION STEP. If `'nVista3'` is
       specified, the input movies are expected to be .isxd files, and are
       expected to have not bee downsampled or compressed.
    
       _ = glab.ppln.isx.dff(_, 'useCached', x::bool)
       Whether or not to use the results of intermediate files from a previous
       computation where possible. Note that `itmdPath` must be consistent
       between attempts in order for this to work. Also note that this system
       is not atomic; if outputs have been produced but are incomplete, and
       this is set to true, the system will attempt to use those incomplete
       files. You must delete these bad actors manually, or turn this off.
       Defaults to `true`.
    
       _ = glab.ppln.isx.dff(_, 'useParallel', x::bool)
       Use naive parallelization where possible. This may require a parallel
       computing environment to have been started. See glab.parenv for
       options. Defaults to `true`.
    
       Examples:
       >> isxPath = '~/data/dcmp';
       >> glab.util.regex.dir(isxPath, 'isxd$')
    
       ans =
    
         2x1 cell array
    
           {'~/data/dcmp/rec1.isxd'}
           {'~/data/dcmp/rec2.isxd'}
    
       >> isxVer = 'nVista3';
       >> [outPath, itmdPath] = glab.ppln.isx.dff(isxPath, 'isxVer', isxVer);
       >> outPath
    
       ans =
    
           '~/data/dff/out'
    
       >> glab.util.regex.dir(outPath, '*')
    
       ans =
    
         2x1 cell array
    
           {'~/data/dff/out/rec1-SDS-CROP-BP-MC-DFF.isxd'}
           {'~/data/dff/out/rec2-SDS-CROP-BP-MC-DFF.isxd'}
    
       >> itmdPath
    
       ans =
    
           '~/data/dff/itmd'
    
       >> glab.util.regex.dir(itmdPath, '*')
    
       ans =
    
         12x1 cell array
    
           {'~/data/dff/itmd/maxProj.isxd'                      }
           {'~/data/dff/itmd/cromRect.mat'                      }
           {'~/data/dff/itmd/rec1-SDS.isxd'                     }
           {'~/data/dff/itmd/rec2-SDS.isxd'                     }
           {'~/data/dff/itmd/rec1-SDS-CROP.isxd'                }
           {'~/data/dff/itmd/rec2-SDS-CROP.isxd'                }
           {'~/data/dff/itmd/rec1-SDS-CROP-BP.isxd'             }
           {'~/data/dff/itmd/rec2-SDS-CROP-BP.isxd'             }
           {'~/data/dff/itmd/rec1-SDS-CROP-BP-MC.isxd'          }
           {'~/data/dff/itmd/rec2-SDS-CROP-BP-MC.isxd'          }
           {'~/data/dff/itmd/rec1-SDS-CROP-BP-translations.isxd'}
           {'~/data/dff/itmd/rec2-SDS-CROP-BP-translations.isxd'}

### Function: glab.ppln.isx.pcaica

    PCAICA A pre-made PCA/ICA pipeline wrapping the Inscopix Data Processing Software.
     v0.5.0 | N Gelwan | 2020-05
    
       Usage:
       [outPath::string, itmdPath::string] = ...
           glab.ppln.isx.pcaica(dffOutPath::string)
       Run a pre-made pipeline which processes a DF/F time-seties found in
       in `dffOutPath` into an array-formatted collection of sources.
    
       _ = glab.ppln.isx.pcaica(_, 'nICs', x::int)
       Specify the number of independent components to expect from the movie
       manually. Otherwise, an automatic estimation scheme is used.
    
       _ = glab.ppln.isx.pcaica(_, 'outPath', x::string)
       Specify the directory containing output sources.
       Defaults to `fullfile(dffOutPath, '../../pcaica/out')`.
    
       _ = glab.ppln.isx.pcaica(_, 'itmdPath', x::string)
       Specify the directory where intermediate products of the pipeline will
       be stored. Defaults to `fullfile(dffOutPath, '../../pcaica/itmd')`.
    
       _ = glab.ppln.isx.pcaica(_, 'useCached', x::bool)
       Whether or not to use the results of intermediate files from a previous
       computation where possible. Note that `itmdPath' must be consistent
       between attempts in order for this to work. Also note that this system
       is not atomic; if outputs have been produced but are incomplete, and
       this is set to true, the system will attempt to use those incomplete
       files. You must delete these bad actors manually, or turn this off.
       Defaults to `true`.
    
       _ = glab.ppln.isx.pcaica(_, 'useParallel', x::bool)
       Use naive parallelization where possible. This may require a parallel
       computing environment to have been started. See glab.parenv for
       options. Defaults to `true`.
    
       Examples:
       >> dffOutPath = '~/data/dff/out';
       >> glab.util.regex.dir(isxPath, 'isxd$')
    
       ans =
    
         2x1 cell array
    
           {'~/data/dff/out/rec1-DFF.isxd'}
           {'~/data/dff/out/rec2-DFF.isxd'}
    
       >> [outPath, itmdPath] = glab.ppln.isx.pcaica(dffOutPath);
       >> outPath
    
       ans =
    
           '~/data/pcaica/out'
    
       >> glab.util.regex.dir(outPath, '*')
    
       ans =
    
         1x1 cell array
    
           {'~/data/pcaica/out/sources.mat'}
    
       >> itmdPath
    
       ans =
    
           '~/data/pcaica/itmd'
    
       >> glab.util.regex.dir(itmdPath, '*')
    
       ans =
    
         13x1 cell array
    
           {'~/data/pcaica/itmd/srcLocs.isxd'            }
           {'~/data/pcaica/itmd/sortStatus.mat'          }
           {'~/data/pcaica/itmd/rec1-DFF-TDS-PCAICA.isxd'}
           {'~/data/pcaica/itmd/rec1-DFF-TDS.isxd'       }
           {'~/data/pcaica/itmd/rec1-DFF-SRCS.isxd'      }
           {'~/data/pcaica/itmd/rec1-DFF-NPL.isxd'       }
           {'~/data/pcaica/itmd/rec2-DFF-TDS-PCAICA.isxd'}
           {'~/data/pcaica/itmd/rec2-DFF-TDS.isxd'       }
           {'~/data/pcaica/itmd/rec2-DFF-SRCS.isxd'      }
           {'~/data/pcaica/itmd/rec2-DFF-NPL.isxd'       }
           {'~/data/pcaica/itmd/nplLoc.isxd'             }
           {'~/data/pcaica/itmd/minProj.isxd'            }
           {'~/data/pcaica/itmd/maxProj.isxd'            }
    
       >> isxPath = '~/data/dcmp';
       >> pcaicaOutPath = glab.ppln.isx.pcaica(glab.ppln.isx.dff(isxPath));

### Namespace: glab.ppln.isx.pcaica

This namespace contains a helper function for the function *glab.ppln.isx.pcaica*, *glab.ppln.isx.pcaica.sort*. This isn't generally meant for human consumption, and won't be expounded upon here, but it isn't dangerous or anything like that.

### Function: glab.ppln.isx.pcaica.sort

See above.
