#!/bin/bash -l
# Job name
#SBATCH -J Img_Reg
#
# Partition:
#SBATCH -p cortex
#
# Wall clock limit:
#SBATCH --time=2:00:00
#
# Memory:
#SBATCH --mem-per-cpu=5000
#
# Constraint:
#SBATCH --constraint=cortex_nogpu

module load matlab/R2016a
matlab -nosplash -nodisplay << EOF\n
skipTrack=true;\n
skipAffine=true;\n
[moviesToRegisterDir,outputDir] = choose_dirs();\n
[fileNames,roiFullFiles,cziFullFiles,nMovies] = load_mov_names(moviesToRegisterDir);\n
\n
if exist('skipAffine');\n
	skipAffine = skipAffine;\n
else;\n
	skipAffine = false;\n
end;\n
\n
for movieNum=1:nMovies;\n
	fileName = fileNames{movieNum};\n
	roiFile = roiFullFiles{movieNum};\n
	cziFile = cziFullFiles{movieNum};\n
	postSelectMovReg(moviesToRegisterDir,outputDir,fileName,roiFile,cziFile,skipTrack,skipAffine);\n
end;\n
exit\n
EOF\n
