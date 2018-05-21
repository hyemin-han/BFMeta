import glob
import os
import math
import numpy as np

# threshold Means.nii or Medians.nii based on a given BF threshold
# it is to find out which voxel showed significant r != 0 supported by evidence

# import required nifti processing function(s)
import nibabel as nib

# load BFs.nii
BFimg = nib.load('BFs.nii')
BFdata = BFimg.get_data()

# get some parameters
# 1. BF threshold (in 2logBF)
# 2. Mean or median?

BF = float(input('1. BF threshold in 2logBF? (Guideline: 2: Positive, 6: Strong, 10: Very strong (Kass & Raftery, 1995)'))
logBF = BF

# transform from 2logBF to BF
BF = math.exp(BF / 2.0)

# use Mean or median?
MM = int(input('1. Use Mean(1) or Median(2)?'))


if MM == 1:
	# Threshold Means.nii
	# load image
	Curimg = nib.load('Means.nii')
	Type = 'Mean'

if MM == 2:
	# load image
	Curimg = nib.load('Medians.nii')
	Type = 'Median'

Curdata = Curimg.get_data()

# Create result image
Result = np.zeros((91,109,91))

# treshold image. if current voxel BF < threshold, mark it with zero.
for x in xrange(1,91):
	for y in xrange(1,109):
		for z in xrange(1,91):

			# is NaN?
			if (np.isnan(BFdata[x][y][z])):
				# Then, mark the current voxel as NaN
				Result[x][y][z]=np.nan
				continue

			# Smaller than the threshold or not
			if (BFdata[x][y][z] < BF):
				Result[x][y][z] = 0
			else:
				Result[x][y][z] = Curdata[x][y][z]
	
# create resultant image
array_img = nib.Nifti1Image(Result, BFimg.affine)
# save thresholded image
filename =('2logBF_%f_%s.nii' %(logBF,Type))
nib.save(array_img, filename)