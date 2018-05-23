#!/bin/bash
for i in {46..60}
do
	Rscript --vanilla fmri_meta_random.R $i
done