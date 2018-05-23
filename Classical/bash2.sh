#!/bin/bash
for i in {31..45}
do
	Rscript --vanilla fmri_meta_random.R $i
done