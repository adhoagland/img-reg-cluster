This document explains how to setup the parallel image registration step by step.

Cluster Requirements
  SLURM Scheduler
  MATLAB R2015a or older
  Minimum 20 cores available simultaneously, preferably more.

Setting up the git repository
  Make sure git is installed
    On the cluster terminal type git. If you get a command not found error then install git.
    Instructions for installing git on Linux are available here: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git 
  Clone the repository
    Go to the directory where you would like the registration code to be
    Type git clone https://github.com/bernaljg/img-reg-cluster.git 
    A directory called img-reg-cluster should be in the directory you chose
    
Setting up data storage and data paths
  Berkeley Research Computing gives 10GB of free storage to every user
  Make a folders called data and output within your free storage
  Inside each of these make a folder with the name img-reg.
  Go back to your main user directory (typing cd into terminal) 
  Open .bashrc file using your favorite text editor and add these three lines to the file, replacing each path with the correct path to your storage folders
    export DATA_PATH="path to the data folder which contains img-reg"
    export OUTPUT_PATH="path to the output folder which contains img-reg"
    export CODE_PATH=”path to the git repository which contains img-reg-cluster"
    
Transferring data
  For best user experience, run preSelectMovReg in a local computer to select ROI’s
  Follow cluster guidelines to transfer all resulting movie and ROI data you want to register into your img-reg folder inside your data folder.
  
Running Program
  Type sbatch scripts/run_img_reg.sh into the terminal in your log in node
  
Program Workflow Explained

scripts/run_img_reg.sh
	Slurm command to start a MATLAB job to run registration on multiple movies
functions/postSelectMovReg
	matlab function which runs through a whole movie and computes tracking for all nmjs
	it then loads these nmjs and saves them into batches
	finds sample affine transforms to make registration robust
functions/run_demons_bash
	writes and runs slurm script for each batch to parallelize registration
functions/postSelectMovReg
	Runs join_movies in background while run_demons_reg runs
functions/join_movies
	Functions that concatenates batches and saves fullMovie
Saves times
Finishes
fullMovie is a cell object with nNmjs cells
