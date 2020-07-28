%%% get mean pixel values within delineated areas of series of input images  
% input table or name of excel file with at least the following variables:
%   exposure_sec = exposure time; values will be converted to equivalent as if exposure time = 1s
%   proj_file = image with pixel values to be averaged
%   roi_rile = image with white areas indicating ROI, other areas black  
%   sub (optional) = subject; if included, normalization will use the max value of each subject, not of the whole table
%   
% two options for table variable 'baseline_file'
%       1. filename of .mat file with struct 'baseline' for normalizing to baseline (filename must have extension .mat):
%           baseline.baselineImage = filename of image to get baseline from
%           baseline.baseLineArea = filename of image in white indicating where to analyze baselineImage
%           baseline.exposure_sec = exposure time
%       2. filename of BW image indicating baseline area; use proj_file as intensity image  
%
% only file paths listed in the 'directory' variable will be considered; paths in other table variables will be ignored
%
%%%% last upated 2020/02/02

function outtable = areaDensity(intable)

sectionthickness = 40; % microns
show_plot = 1; 

if ischar(intable) % intable assumed to be excel filename
    filetable = readtable(intable);
else % intable assumed to be table variable
    filetable = intable;
end
nimages = height(filetable);
outtable = filetable;
outtable.roitotalpix = NaN(nimages,1);
outtable.intensPerPix = NaN(nimages,1);



for ifile = 1:nimages
    %%% load proj file and roi file from the directories listed
    projFileToLoad = [filetable.directory{ifile}, filesep, getfname(filetable.proj_file{ifile}, 'extension')];
    projimg = imread(projFileToLoad);
    projimg = projimg(:,:,1); % in case image is rgb, take only first channel
    roiFileToLoad = [filetable.directory{ifile}, filesep, getfname(filetable.roi_file{ifile}, 'extension')];
    roiimg = loadbw(roiFileToLoad);
    
    if any(size(projimg) ~= size(roiimg))
        error([outtable.proj_file{ifile} ' and ' outtable.roi_rile{ifile} ' are different sizes.'])
    end
     
    roi_vals = projimg(roiimg);
    raw_roi_mean = mean(roi_vals);
    
    baseFileToLoad = [filetable.directory{ifile}, filesep, getfname(filetable.baseline_file{ifile}, 'extension')];
    if strcmp(baseFileToLoad(end-3:end), '.mat')   % if baseline input is a .mat file with baseline struct
        baseline = load(baseFileToLoad,'baseline'); baseline = baseline.baseline; % load baseline struct for use with this image
        baseimg = imread(baseline.baselineImage);
        baseimg = baseimg(:,:,1); % in case image is rgb, take only first channel
        baseAreaImg = loadbw(baseline.baselineAreaImage);
        baseVals = baseimg(baseAreaImg);
        outtable.baseline(ifile) = mean(baseVals) / baseline.exposure_sec;
        outtable.intensPerPixRaw(ifile) = outtable.intensPerPix(ifile) / outtable.exposure_sec(ifile); % record exposure-normed raw val before subtracting baseline
        outtable.intensPerPix(ifile) = outtable.intensPerPix(ifile) - outtable.baseline(ifile);
    elseif ~strcmp(baseFileToLoad(end-3:end), '.mat')    % if baseline input is a BW image file
        baseAreaImg = loadbw(baseFileToLoad);
        baseVals = projimg(baseAreaImg);
        outtable.intensPerPixRaw(ifile) = raw_roi_mean / outtable.exposure_sec(ifile); % record exposure-normed raw val before subtracting baseline
        raw_roi_mean = raw_roi_mean - mean(baseVals); % subtract baseline
        outtable.baseline(ifile) = mean(baseVals) / outtable.exposure_sec(ifile); 
    end

    outtable.intensPerPix(ifile) = raw_roi_mean / outtable.exposure_sec(ifile); % normalize to simulated exposure time of 1s
    outtable.roitotalpix(ifile) = nnz(roiimg);
end

% normalization of intensity values to maximum value within each case
if any(strcmp('sub',filetable.Properties.VariableNames)) %%% if a variable for subject is included in the table, norm using only this subject
    subs = unique(outtable.sub);
    for isub = 1:length(subs)
        thissub = subs(isub);
        these_rows = outtable.sub==thissub;
        outtable.normedIntens(these_rows) = outtable.intensPerPix(these_rows) / max(outtable.intensPerPix(these_rows));
    end
else % norm using the entire table
     outtable.normedIntens = outtable.intensPerPix / max(outtable.intensPerPix);
end
    
    
    
    
    
    
    
%%%% plotting
if show_plot && any(strcmp(outtable.Properties.VariableNames,'sec'))
    figure
    secloc = sectionthickness * outtable.sec;  %%%%% - sectionthickness/2;
    plot(secloc,outtable.normedIntens)
    xlabel('Depth (microns)')
    ylabel('Projection Intensity Per Pixel')
%     set(gca,'ylim',[0 max(get(gca,'ylim'))])
end



