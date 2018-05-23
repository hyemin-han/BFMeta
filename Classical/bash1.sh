#!/bin/bash
for i in {1..30}
do
	Rscript --vanilla fmri_meta_random.R $i
done