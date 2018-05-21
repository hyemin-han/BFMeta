# BFMeta
BFMeta program

This project intends to implement Bayesian random-effect meta-analysis for fMRI studies. fmri_bmeta_random1.R performs voxelwise Bayesian random-effect meta-analysis of included fMRI studies (in list.csv) to examine the mean and median effect size (+ BF, Bayes factors) in each voxel in a specific task comparison. It gets nifti file inputs in SPM-MNI format (91x109x91). All input nifti files should contain either t or z scores with thresholding. File names, type of statistics (t vs z), and sample size (how many subject?) should be specified in list.csv.

fmri_bmeta_random1.R requires one parameter, X (1 to 91) coordinate to be analyzed. In order to facilitate the parallelization of computing processes, fmri_bmeta_random1.R performs Bayesian random-effect meta-analysis for only one X. Thus, it should be executed like this:

Rscript --vanilla fmri_bmeta_random1.R 1
(to perform analysis for X = 1)

Bayes factors represent whther observed evidence support H1 (effect size != 0) in favor of H0 (effect size ~ 0). For Bayesian analysis, these priors are used:

When theta_i(th study) ~ N (d, tau^2), y_i|theta_i ~ N (theta_i, SE_i^2)

d ~ Cauchy (1/sqrt(2))
tau ~ beta (1,2) (following suggestions in Gronau et al. (2017)

fmri_bmeta_random1.R automatically creates an output folder, "Outputs." Under this folder, three different types of files will be created. BFX.RData, MeanX.RData, and MedianX.Rdata (X = entered X value as a parameter). Each contains Bayes factors, mean posterior and median posterior effect size value in "r" in a specific X, repsectively. Once fmri_bmeta_random1.R performed for all Xs, 1 to 91, BF1.RData-BF91.RData, Mean1.RData-Mean91.RData, and Median1.RData-Median91.RData are created. 

Once all RData files are created for X to 91, integrate_result.R should be executed to create result nifti files. Bayes factors will be reported in BFs.nii. Mean posterior effect size values will be stored in Means.nii. Finally, Median posterior effect size values will be saved in Medians.nii

To facilitate parallel processing, four bash scripts (*.sh) are also provided. These files are provided to perform fmri_bmeta_random1.R for X 1 to 91 with four cores.
