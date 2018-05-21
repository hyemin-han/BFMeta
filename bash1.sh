#!/bin/bash
for i in {1..30}
do
	Rscript --vanilla fmri_bmeta_random1.R $i
done