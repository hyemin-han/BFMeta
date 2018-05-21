import glob
import os

# import required nifti processing functions
from nilearn.datasets import load_mni152_template
from nilearn.image import resample_to_img
from nilearn.image import load_img

# create a 91x109x91 MNI template
template = load_mni152_template()

# open all nii files in the current folder
originalfiles = glob.glob('./*.nii')
filecount = len(originalfiles)

# make a folder for outputs
os.mkdir('transformed')

# transform (Affine) all current nii files into MNI 152
for x in range (0,filecount):
	resampled_localizer_tmap = resample_to_img(originalfiles[x], template)
	resampled_localizer_tmap.to_filename('./transformed/%s' % (originalfiles[x]))