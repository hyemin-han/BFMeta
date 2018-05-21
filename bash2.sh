#!/bin/bash
for i in {31..45}
do
	Rscript --vanilla fmri_bmeta_random1.R $i
done