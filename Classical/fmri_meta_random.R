#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

require("oro.nifti")
require("metafor")

# Create output dir
dir.create("Outputs")

# Get parameter (# of X)
if (length(args)==0){
	stop("X should be provided!")
}
X = strtoi(args[1])
if ((X < 1 )|(X > 91)){
	stop ("X out of range! (1 to 91)")
}

# Read filelist
data<-read.csv("list.csv")
filecount <-nrow(data)

# Create 4D space
AllImg = array(0.0,c(filecount,91,109,91))

# Read each nifti file
for (i in 1:filecount)  {
	filename <- toString(data[i,1])
	# Read the current nifti
	Img <- readNIfTI(filename)
	
	# Extract current image data
	ImgData = oro.nifti::img_data(Img)
	
	# T or Z
	Type <- toString(data[i,3])
	# n size
	N <- data[i,2]
	
	# Transform to Fisher's Z
	for (x in X:X) {
		for (y in 1:109) {
			for (z in 1:91)  {

				# If NaN
				if (is.nan(ImgData[x,y,z])){
					AllImg[i,x,y,z] = NaN
					next
				}
				# If zero
				if (ImgData[x,y,z] == 0){
					AllImg[i,x,y,z] = NaN
					next
				}				
				# T?
				if (Type == 'T'){
					# AllImg[i,x,y,z] = 2.0 * ImgData[x,y,z] / sqrt(N - 2.0)
					# AllImg[i,x,y,z] = sqrt(ImgData[x,y,z]*ImgData[x,y,z]/(ImgData[x,y,z]*ImgData[x,y,z]+N-1))*sign(ImgData[x,y,z])
					AllImg[i,x,y,z] = ImgData[x,y,z]
					AllImg[i,x,y,z] = sqrt((AllImg[i,x,y,z]*AllImg[i,x,y,z])/(AllImg[i,x,y,z]*AllImg[i,x,y,z]+N-1))*sign(AllImg[i,x,y,z])
					AllImg[i,x,y,z] = atanh(AllImg[i,x,y,z])
				}
				# Z?
				else {
					AllImg[i,x,y,z] = ImgData[x,y,z] / sqrt(N) * sqrt(N-2.0)
					# AllImg[i,x,y,z] = sqrt(ImgData[x,y,z]*ImgData[x,y,z]/(ImgData[x,y,z]*ImgData[x,y,z]+N-1))*sign(ImgData[x,y,z])
					
					AllImg[i,x,y,z] = sqrt((AllImg[i,x,y,z]*AllImg[i,x,y,z])/(AllImg[i,x,y,z]*AllImg[i,x,y,z]+N-1))*sign(AllImg[i,x,y,z])
					AllImg[i,x,y,z] = atanh(AllImg[i,x,y,z])
				}
			}
		}
	}

}

# Create SE stuff
SE = array (0.0,c(filecount))
for (i in 1:filecount){
	SE[i] = 1/sqrt(data[i,2]-3.0)
}

# Then, perform bayesmeta for each voxel
# When a voxel value in a specific voxel in all images <> 0 or NaN
BFs = array(0.0,c(109,91))
Means = array(0.0,c(109,91))
Medians = array(0.0,c(109,91))

# Current voxel values
voxels = array(filecount)

for (x in X:X)  {
	for (y in 1:109){
		for (z in 1:91){
			# Check NaN
			flag <- 0
			for (i in 1:filecount){
				if (is.nan(AllImg[i,x,y,z])){
					flag <- 1
				}
			}
			# NaN found?
			if (flag){
				# Write NaN and exit
				BFs[y,z] <- NaN
				Means[y,z] <- NaN
				Medians[y,z] <- NaN
				next
			}
			# Do Bayesian Analysis
			# Create an array of voxel values
			for (i in 1:filecount){
				voxels[i] = AllImg[i,x,y,z]
			}
			# do random-effect meta-analysis (classical)
			df = data.frame(as.vector(voxels),as.vector(SE))
			control=list(maxiter=3000)
			tryCatch({
			test<-rma(as.vector.voxels.,as.vector.SE.,data=df, measure="GEN", method="ML")},
			# if error occurs, NaN
			error = function(err)
			{
				cat("ML Convergence error at",x,",",y,",",z,"!")
				BFs[y,z]<- NaN
				Means[y,z]<-NaN
			}
			)

			# If OK,
			if (!is.nan(BFs[y,z])){
				BFs[y,z] <- test$z
				Means[y,z] <- test$beta[1,1]

				# From Fisher's z to r
				Means[y,z] <- tanh(Means[y,z])
			}

		}
	}
	# Notify that x/91 done.
	cat(x,"/ 91 Done. ")
	write(c(x,"/ 91 Done."), file="log_classical.txt",append=TRUE)
}

# Write results in binary files

save(BFs,file=sprintf("./Outputs/Z%d.Rdata",X))
save(Means,file=sprintf("./Outputs/Est%d.Rdata",X))
