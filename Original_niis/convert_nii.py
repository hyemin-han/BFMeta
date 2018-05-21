import glob
import os

from nilearn.datasets import load_mni152_template
from nilearn.image import resample_to_img
from nilearn.image import load_img

template = load_mni152_template()

originalfiles = glob.glob('./*.nii')

filecount = len(originalfiles)

os.mkdir('transformed')

for x in range (0,filecount):
	resampled_localizer_tmap = resample_to_img(originalfiles[x], template)
	resampled_localizer_tmap.to_filename('./transformed/%s' % (originalfiles[x]))