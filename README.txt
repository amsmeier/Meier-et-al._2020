README for functions used in Meier et al. 2021 - Modular network between postrhinal visual cortex, amygdala and entorhinal cortex

-patchcounting_analysis.m was used to find spatial distribution and shape features of M2+ patches (Figure 2)
-draw_major_xis.m was used to find the major axis of both cortical areas and M2+ patches (Figure 2)
-patch_shape_plotting.m was run to create plots shown in Figure 2 after patchcounting_analysis.m had been run
-analyze_patchiness.m is the main function used for extracting M2+ patch/quantile boundaries and quantifying viral expression intensities in different compartments (Figures 6-7)
---see the folder 'sample_data_for_analyze_patchiness.m' for a sample case on which to use _analyze_patchiness
---this function will find quantile boundaries and then quantify viral expression intensity in each quantile
---resultant data can be found in the 'analysis_results.mat' file
-module_ratio_plotting.m was used to create plots for comparing module intensity ratios across paths after analyze_patchines.m had been run (Figure 7)
-laminar_density_plotting.m was used to create plots of viral expression intensities across multiple tissue depths (Figure 7)
-laminar_cells_plotting.m was used to create plots of cell counts across multiple tissue depths (Figure 8)
-dendrite_density_analysis.m was used for quantification of dendrite lengths and cell densities (Figures 8-9)
-circNormalize.m was used for spatial normalization preprocessing of tissue images 