#!/bin/bash
for i in {61..91}
do
	Rscript --vanilla fmri_bmeta_random1.R $i
done