%%%% dendrite_density_analysis
%
% approximate dendrite lengths within quantiles by measuring area of manually traced dendrites
%
% manually traced dendrite lines are assumed to be 1 pixel thick, number of pixels = length of segments in pixels
% note: using 1-point stroke weight for lines in Adobe Illustrator with 1292x1040 images results in 1-pixel-thick lines
%
%%% updated 2020/2/27 on thermaltake

filelist_excel = 'C:\Users\Burkhalter Lab\Documents\anatomy_paper\dendrite_lengths_file_list.xlsx';
% close all

%% plotting parameters
path_to_plot = 'amyg';
% path_to_plot = 'mec';
boxplot_linewidth = 2; 
bar_face_color = [0.3 0.3 0.3]; % bar graph -  bar color
bar_line_width = 3; % bar graph - bar outline line width
error_line_color = [0 0 0]; % error bars color
axes_line_width = 3;
axes_numbers_bold = 'bold'; %%% 'bold' or 'normal'
plotfont = 'Arial'; % default = Helvetica
axis_font_size = 18; 
% ylimits = [0.85, 1.89];
xlimits = [0.3, 6.6];
fig_width = 1100; % pixels... if aligned with 19105_s2d_x20, use 1200 width, 430 height
fig_height = 430; % pixels... if aligned with 19114_ctx_s3c_x10_cropped, use 1100 width, 430 height
save_dendrite_length_fig = 0; 
    savename_dendrite_lengths = ['fig_', path_to_plot, '_dendrite_lengths'];
perform_analysis = 1; % turn off if data is already loaded and analyzed
    

%% findpatches settings
findpatches_pars.minAreaPatch_squm = 0;  % min area in square microns a blob must contain to be considered a patch
findpatches_pars.maxAreaPatch_squm = field_default(findpatches_pars,'maxAreaPatch_squm',inf);
findpatches_pars.blur_using_only_roi = field_default(findpatches_pars,'blur_using_only_roi',1); % if true, do not use non-roi pixels for blurring 
findpatches_pars.diskblurradius_um = field_default(findpatches_pars,'diskblurradius_um',29);
findpatches_pars.threshMode = field_default(findpatches_pars,'threshMode','intensityQuantiles');
    findpatches_pars.nQuantiles = field_default(findpatches_pars,'nQuantiles',6); % number of intensity levels to divide image into (if using 'intensityQuantiles')
    findpatches_pars.patchQuantiles = field_default(findpatches_pars,'patchQuantiles',[4 5 6]); % % quantiles selected to be counted as patches(if using 'intensityQuantiles')
findpatches_pars.include_interior_nonroi_in_roi = field_default(findpatches_pars,'include_interior_nonroi_in_roi',1); 
findpatches_pars.show_plots = field_default(findpatches_pars,'show_plots',0);



%% analyze dendrite lengths for each case
if perform_analysis
    filelist = readtable(filelist_excel); % import list of images to analyze
    nfiles = height(filelist);
    filelist.dend_um_per_quant = NaN(nfiles, findpatches_pars.nQuantiles); % microns of labeled dendrites in each quantile
    filelist.dend_proportion_per_quant = NaN(nfiles, findpatches_pars.nQuantiles); % proportion of total labeled dendrites from this case in each quantile
    for ifile = 1:nfiles
        this_roi_image = loadbw(filelist.roi_file{ifile}); % load the area roi
        this_dend_image = loadbw(filelist.dendrite_file{ifile}); % load the labeled dendrites image
        this_dend_image = this_dend_image & this_roi_image; % only analyze dendrites that fall within the roi
        total_dend_pix_this_case = nnz(this_dend_image); 
        %%% get m2 quantiles data for this case
        filelist.patchdata{ifile} = findpatches(filelist.m2_file{ifile},filelist.roi_file{ifile},filelist.zoom(ifile),filelist.scope{ifile}, findpatches_pars); 
        for quant = 1:findpatches_pars.nQuantiles
            this_quant_area = filelist.patchdata{ifile}.quantile_table.quantimage{quant};
            n_dend_pix_this_quant = nnz(this_dend_image & this_quant_area); %%% number of labeled dendrite pixels that overlap with this quantile
            filelist.dend_um_per_quant(ifile, quant) = umPerPix(filelist.zoom(ifile),filelist.scope{ifile}) * n_dend_pix_this_quant; % convert pix to um
            filelist.dend_proportion_per_quant(ifile, quant) = n_dend_pix_this_quant / total_dend_pix_this_case; % proportion of total labeled dendrites from this case in this quantile
        end
    end  
end


%% plotting
% get data to plot
rows_to_plot = strcmp(filelist.pathway,path_to_plot);
data_to_plot = [filelist.dend_proportion_per_quant(rows_to_plot,:)]'; % dend lengths for this pathway
dendlengths = table; [dendlengths.mean, dendlengths.sem] = grpstats(data_to_plot(:),repmat([1:6]',nnz(rows_to_plot),1),{'mean','sem'}); % organize data
% plot proportion of dendrite lengths in each quantile with standard error
fig_dendrite_lengths = figure;
nquants = height(dendlengths); 
bg = bar(1:height(dendlengths),dendlengths.mean);
hold on
eb = errorbar(1:nquants, dendlengths.mean, dendlengths.sem,'LineStyle','none');
hold off
plot_formatting()
hax = gca;
hax.XAxis.TickLength = [0 0];
hax.XTick = 1:nquants;
hax.XTickLabel = num2str([1:nquants]');

%%% correlation stats
[~,quantmat] = meshgrid(1:size(data_to_plot,2),1:size(data_to_plot,1));
[r_corr_quant_dendlengths, p_corr_quant_dendlengths] = corrcoef(quantmat,data_to_plot)  
    
%%% save figure
set(fig_dendrite_lengths,'Renderer', 'painters', 'Position', [200 200 fig_width fig_height]) % set figure length and width
if save_dendrite_length_fig
    print(fig_dendrite_lengths,savename_dendrite_lengths, '-dtiffn','-r300') %%% save image as file
end
