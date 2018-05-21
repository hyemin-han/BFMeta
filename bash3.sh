#!/bin/bash
for i in {46..60}
do
	Rscript --vanilla fmri_bmeta_random1.R $i
done