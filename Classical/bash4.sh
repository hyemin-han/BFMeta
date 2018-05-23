#!/bin/bash
for i in {61..91}
do
	Rscript --vanilla fmri_meta_random.R $i
done